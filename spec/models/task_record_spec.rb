require 'spec_helper'

describe TaskRecord do

  it { should be_an AbstractTask }

  describe ".public_comments_for" do
    before(:each) do
      @task       = FactoryGirl.create :task_with_customers
      @customer   = @task.customers.first

      @work_log   = FactoryGirl.create :work_log, customer: @customer
      @comment_1  = FactoryGirl.create :work_log_comment,
                                       customer:   @customer,
                                       task:       @task,
                                       started_at: 2.days.ago

      @comment_2  = FactoryGirl.create :work_log_comment,
                                       customer:   @customer,
                                       task:       @task,
                                       started_at: 1.day.ago
      @task.work_logs = [@comment_1, @comment_2, @work_log]
    end

    it "should return only comments" do
      task_comments = TaskRecord.public_comments_for(@task)
      expect(task_comments).to match_array [@comment_1, @comment_2]
    end

    it "shoud return only the comments that belong to customers of the task" do
      some_random_comment = FactoryGirl.create :work_log
      task_comments = TaskRecord.public_comments_for(@task)

      task_comments.should_not include(some_random_comment)
    end

    it "should return the comments ordered by the started_at date DESC" do
      task_comments = TaskRecord.public_comments_for(@task)
      task_comments.first.should == @comment_2
      task_comments.second.should == @comment_1
    end
  end

  describe ".open_only" do
    let!(:open_task)       { FactoryGirl.create :task, status: TaskRecord::OPEN }
    let!(:duplicated_task) { FactoryGirl.create :task, status: TaskRecord::DUPLICATE }
    let!(:closed_task)     { FactoryGirl.create :task, status: TaskRecord::CLOSED }
    subject { described_class.open_only }

    it "should only return tasks with resolution open" do
      expect(described_class.count).to eql 3
      expect(subject).to match_array [open_task]
    end
  end

  describe '.expire_hide_until' do
    before do
      FactoryGirl.create :task, hide_until: nil
      FactoryGirl.create :task, hide_until: 3.days.ago
      FactoryGirl.create :task, hide_until: 3.days.from_now
    end

    it 'should update the expired hide until dates to nil' do
      expect(described_class.count).to eql 3
      expect(described_class.where('hide_until < ?', Time.now.utc).count).to eql 1
      expect(described_class.where('hide_until IS NOT NULL').count).to eql 2

      described_class.expire_hide_until
      expect(described_class.where('hide_until < ?', Time.now.utc).count).to eql 0
      expect(described_class.where('hide_until IS NOT NULL').count).to eql 1
    end
  end

  describe "task_property_values attributes assignment using Task#properties=(params) method" do
    before(:each) do
      @task = FactoryGirl.create :task
      @attributes = @task.attributes.with_indifferent_access.except(:id, :type)
      @properties = @task.company.properties
      @task.set_property_value(@properties.first, @properties.first.property_values.first)
      @task.set_property_value(@properties[1], @properties[1].property_values.first)
      @task.save!
      @attributes[:properties]={
        @properties[0].id => @properties[0].property_values[1].id, #change value of first property
        @properties[1].id => "",   #second property is blank, so should be removed
        @properties[2].id => @properties[2].property_values[0].id # third property added
      }
      @task_property_values=@task.task_property_values
    end
    context "when attributes assigned" do
      before(:each) do
        @task.attributes= @attributes
      end

      it "should changed task_property_values with new values" do
        @task.attributes= @attributes
        @task.property_value(@properties[0]).should == @properties[0].property_values[1]
      end

      it "should not delete any task_property_values" do
        @task.property_value(@properties[1]).should_not be_nil
      end

      it "should build new task_property_values" do
        @task.property_value(@properties[2]).should == @properties[2].property_values[0]
      end
    end
    context "when task saved" do
      before(:each) do
        @task.attributes=@attributes
        @task.save!
        @task.reload
      end
      it "should changed task_property_values with new values" do
        @task.property_value(@properties[0]).should == @properties[0].property_values[1]
      end

      it "should delete task_property_values if value is blank" do
        @task.property_value(@properties[1]).should be_nil
      end
      it "should create new task_property_values" do
        @task.property_value(@properties[2]).should == @properties[2].property_values[0]
      end
    end
    context "when task not saved" do
      before(:each) do
        @attributes[:project_id]=""
        @task.attributes=@attributes
        @task.save.should == false
        @task.reload
      end

      it "should not change task_property_values in database" do
        @task.property_value(@properties[0]).should == @properties[0].property_values.first
        @task.property_value(@properties[1]).should == @properties[1].property_values.first
        @task.property_value(@properties[2]).should == nil
      end
    end
  end

  describe "when updating a task from a project that have score rules" do
    before(:each) do
      @score_rule = ScoreRule.make(:score      => 250,
                                   :score_type => ScoreRuleTypes::FIXED)

      project = Project.make(:score_rules => [@score_rule])
      @task   = TaskRecord.make(:project => project, :weight_adjustment => 10)
    end

    it "should update the weight accordantly" do
      @task.weight.should == @score_rule.score + @task.weight_adjustment
      new_weight_adjustment = 50
      @task.update_attributes(:weight_adjustment => new_weight_adjustment)
      @task.weight.should == @score_rule.score + new_weight_adjustment
    end

    it "should update the weight accordantly if company disallow use score rule" do
      @task.company.update_attribute(:use_score_rules, false)
      @task.weight.should == @score_rule.score + @task.weight_adjustment
      new_weight_adjustment = 50
      @task.update_attributes(:weight_adjustment => new_weight_adjustment)
      @task.weight.should == new_weight_adjustment
    end
  end

  describe '#user_work' do
    subject { TaskRecord.new }
    let(:user1) { stub :user1 }
    let(:user2) { stub :user2 }

    let(:user_duration1) { stub _user_: user1, duration: 1000 }
    let(:user_duration2) { stub _user_: user2, duration: 500 }

    before { subject.stub_chain('work_logs.duration_per_user' => [user_duration1, user_duration2]) }

    it 'should sum up the worked hours grouped by users' do
      expect(subject.user_work).to eql({user1 => 1000, user2 => 500})
    end
  end

  describe '#calculate_score' do
    let(:score_rule_1) { FactoryGirl.create :fixed_score_rule, score: 250 }
    let(:score_rule_2) { FactoryGirl.create :fixed_score_rule, score: 150 }
    let(:company)      { FactoryGirl.create :company, score_rules: [score_rule_1, score_rule_2]  }

    subject { FactoryGirl.create :task, weight_adjustment: 10, company: company }

    context 'when task is not closed or snoozed' do
      it('weight should be the calculated score') { expect(subject.weight).to eql 10 + 250 + 150 }
    end

    context 'when task is closed' do
      before { subject.stub closed?: true; subject.calculate_score }
      its(:weight) { should be_zero }
    end

    context 'when task is snoozed' do
      before { subject.stub snoozed?: true; subject.calculate_score }
      its(:weight) { should be_nil }
    end
  end

  describe "#snoozed?" do
    subject { described_class.new status: status, wait_for_customer: wait_for_customer }

    context "when the task is closed and waiting for customer" do
      let(:status) { described_class::CLOSED }
      let(:wait_for_customer) { true }
      it { expect(subject.snoozed?).to be_true }
    end

    context "when the task is closed and not waiting for customer" do
      let(:status) { described_class::CLOSED }
      let(:wait_for_customer) { false }
      it { expect(subject.snoozed?).to be_false }
    end

    context "when the tasks is open and waiting for customer" do
      let(:status) { described_class::OPEN }
      let(:wait_for_customer) { true }
      it { expect(subject.snoozed?).to be_true }
    end

    context "whent the task is open and not wait for customer" do
      let(:status) { described_class::OPEN }
      let(:wait_for_customer) { false }
      it { expect(subject.snoozed?).to be_false }
    end

    pending 'Many codepaths are missing from testing'
  end

  describe "#score_rules" do
    subject { described_class.new company: company }

    context 'when company does not use score rules' do
      let(:company)   { Company.new use_score_rules: true }
      it { expect(subject.score_rules).to eql [] }
    end

    context 'when company use score rules' do
      let(:score_rule_project)   { mock_model ScoreRule, id: 'project' }
      let(:score_rule_company)   { mock_model ScoreRule, id: 'company' }
      let(:score_rule_customer)  { mock_model ScoreRule, id: 'customer' }
      let(:score_rule_milestone) { mock_model ScoreRule, id: 'milestone' }
      let(:score_rule_prop_val)  { mock_model ScoreRule, id: 'property value' }

      let(:company)   { Company.new       score_rules: [score_rule_company], use_score_rules: true }
      let(:project)   { Project.new       score_rules: [score_rule_project] }
      let(:company)   { Company.new       score_rules: [score_rule_company] }
      let(:milestone) { Milestone.new     score_rules: [score_rule_milestone] }
      let(:customer)  { Customer.new      score_rules: [score_rule_customer] }
      let(:prop_val)  { PropertyValue.new score_rules: [score_rule_prop_val] }

      subject { described_class.new company: company, project: project,
                                    milestone: milestone, customers: [customer],
                                    property_values: [prop_val] }

      it "should return the score rules associated with it's company, project, milestone, customers, and property values" do
        expect(subject.score_rules).to match_array [
          score_rule_project, score_rule_company, score_rule_customer,
          score_rule_milestone, score_rule_prop_val
        ]
      end
    end
  end
end

# == Schema Information
#
# Table name: tasks
#
#  id                 :integer(4)      not null, primary key
#  name               :string(200)     default(""), not null
#  project_id         :integer(4)      default(0), not null
#  position           :integer(4)      default(0), not null
#  created_at         :datetime        not null
#  due_at             :datetime
#  updated_at         :datetime        not null
#  completed_at       :datetime
#  duration           :integer(4)      default(1)
#  hidden             :integer(4)      default(0)
#  milestone_id       :integer(4)
#  description        :text
#  company_id         :integer(4)
#  priority           :integer(4)      default(0)
#  updated_by_id      :integer(4)
#  severity_id        :integer(4)      default(0)
#  type_id            :integer(4)      default(0)
#  task_num           :integer(4)      default(0)
#  status             :integer(4)      default(0)
#  creator_id         :integer(4)
#  hide_until         :datetime
#  scheduled_at       :datetime
#  scheduled_duration :integer(4)
#  scheduled          :boolean(1)      default(FALSE)
#  worked_minutes     :integer(4)      default(0)
#  type               :string(255)     default("Task")
#  weight             :integer(4)      default(0)
#  weight_adjustment  :integer(4)      default(0)
#  wait_for_customer  :boolean(1)      default(FALSE)
#
# Indexes
#
#  index_tasks_on_type_and_task_num_and_company_id  (type,task_num,company_id) UNIQUE
#  tasks_company_id_index                           (company_id)
#  tasks_due_at_idx                                 (due_at)
#  index_tasks_on_milestone_id                      (milestone_id)
#  tasks_project_completed_index                    (project_id,completed_at)
#  tasks_project_id_index                           (project_id,milestone_id)
#

