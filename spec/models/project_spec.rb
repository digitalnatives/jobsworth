require 'spec_helper'

MUTABLE_ATTRIBUTES = %w[id project_id type created_at updated_at]

describe Project do
  let(:project) { Project.make }

  it { should validate_presence_of :name }
  it { should validate_presence_of :customer }

  describe 'associations' do
    it { should belong_to(:company) }
    it { should belong_to(:customer) }
    it { should have_many(:users) }
    it { should have_many(:project_permissions) }
    it { should have_many(:tasks) }
    it { should have_many(:sheets) }
    it { should have_many(:work_logs) }
    it { should have_many(:project_files) }
    it { should have_many(:milestones) }

    it "should have a 'score_rules' association" do
      project.should respond_to(:score_rules)
    end

    it "should fetch the right Score Rule instances" do
      some_score_rule = ScoreRule.make
      project.score_rules << some_score_rule
      project.score_rules.should include(some_score_rule)
    end
  end

  describe "#default_estimate" do
    it "should have a default_estimate" do
      project.should respond_to(:default_estimate)
    end

    it "should default to 1.0" do
      project.default_estimate.should == 1.0
    end
  end

  describe "validations" do
    it "should require a 'default_estimate'" do
      project.default_estimate = nil
      project.should_not be_valid
    end

    it "should require a numeric value on 'default_estimate'" do
      project.default_estimate = 'lol'
      project.should_not be_valid
    end

    it "should require a number greater or equal to 1.0 on 'default_estimate'" do
      project.default_estimate = -1.0
      project.should_not be_valid
    end
  end

  describe '#billing_enabled?' do
    subject{ FactoryGirl.create(:project) }

    it "should return true if company allows billing use" do
      subject.company.use_billing = true
      subject.billing_enabled?.should be_true
    end

    it "should return false if company doesn't allow billing use" do
      subject.company.use_billing = false
      subject.billing_enabled?.should be_false
    end
  end

  describe "When adding a new score rule to a project that have tasks" do
    before(:each) do
      @company      = FactoryGirl.create :company
      @open_task    = TaskRecord.make :status => Status.default_open(@company)
      @closed_task  = TaskRecord.make :status => Status.default_closed(@company)
      @project      = Project.make(:tasks => [@open_task, @closed_task], company: @company)
      @score_rule   = ScoreRule.make
    end

    it "should update the score of all the open taks" do
      pending "The project model, for now, doesn't update the score of is taks"
      @project.score_rules << @score_rule
      @open_task.reload
      new_score = @open_task.weight_adjustment + @score_rule.score
      @open_task.weight.should == new_score
    end

    it "should not update the score of any closed task" do
      pending "The project model, for now, doesn't update the score of is taks"
      @project.score_rules << @score_rule
      @closed_task.reload
      calculated_score = @open_task.weight_adjustment + @score_rule.score
      @open_task.weight.should_not == calculated_score
    end
  end

  describe '#copy_template' do
    before { Timecop.freeze(Time.local(2013, 3, 23, 10, 0)) }
    after  { Timecop.return }

    let(:user)             { FactoryGirl.create(:user) }
    let(:user2)            { FactoryGirl.create(:user) }
    let(:project_template) { FactoryGirl.create(:project_template,
                                                company: user.company,
                                                start_at: Time.now.beginning_of_year.to_date) }
    let(:task_template)    { FactoryGirl.create :template,
                                                project: project_template,
                                                company: user.company,
                                                owners:  [user],
                                                users:   [user2],
                                                due_at:  task_due_at }
    let(:milestone)        { FactoryGirl.create(:milestone,
                                                project: project_template,
                                                company: user.company,
                                                due_at:  milestone_due_at) }

    subject { Project.new( project_template.attributes.except(*MUTABLE_ATTRIBUTES) ) }

    it "should be saved as a project" do
      expect { subject.save }.to change { Project.count }.by(1)
    end

    context "should clone project permissions" do
      context "with defaults" do
        before do
          project_template.create_default_permissions_for(user)

          subject.copy_template project_template
          subject.save
        end

        let(:permissions) { subject.project_permissions }
        let(:template_permissions) { project_template.project_permissions }

        it "with all necessary attributes" do
          expect(permissions.size).to eq(1)

          permissions.first.attributes.except(*MUTABLE_ATTRIBUTES).should ==
            template_permissions.first.attributes.except(*MUTABLE_ATTRIBUTES)
        end
      end

      context "with custom" do
        let(:custom_permissions) { FactoryGirl.create(:project_permission,
                                                      :project => project_template,
                                                      :user => user,
                                                      :company => project_template.company) }

        before do
          custom_permissions
          subject.copy_template project_template
          subject.save
        end

        it "with all necessary attributes" do
          subject.project_permissions.size.should eq(1)
          subject.tasks.size.should eq(0)

          subject.project_permissions.first.attributes.except(*MUTABLE_ATTRIBUTES).should ==
            custom_permissions.attributes.except(*MUTABLE_ATTRIBUTES)
        end
      end
    end

    context "when project starts after templates start_at with 1 month" do
      before do
        task_template; milestone

        project_template.create_default_permissions_for(user)
        subject.start_at = project_template.start_at + 1.month

        subject.copy_template project_template
        subject.save
      end

      let(:first_task)       { subject.tasks.first }

      context "when milestone due at nil" do
        let(:milestone_due_at) { nil }
        let(:task_due_at)      { nil }

        it "with all necessary attributes" do
          expect(subject.milestones.first.due_date).to be_nil
          expect(first_task.due_at).to be_nil
          expect(subject.tasks.size).to eq 1

          expect(first_task.owners).to match_array([user, user2])
          expect(first_task.users).to  match_array([user, user2])

          # TODO Clean this messy spec
          # first_task.attributes.except(*MUTABLE_ATTRIBUTES).should ==
            # task_template.attributes.except(*MUTABLE_ATTRIBUTES)
        end
      end

      context "when milestone due at set" do
        let(:milestone_due_at) { project_template.start_at + 6.days }
        let(:task_due_at)      { project_template.start_at + 5.days }

        it "should clone all necessary attributes" do
          expect(subject.tasks.size).to eq 1

          expect(subject.milestones.first.due_at).to eq(milestone.due_at + 1.month)
          expect(first_task.due_at).to eq(task_template.due_at + 1.month)

          expect(first_task.owners).to match_array([user, user2])
          expect(first_task.users).to  match_array([user, user2])

          # TODO Clean this messy spec
          # first_task.attributes.except(*MUTABLE_ATTRIBUTES).should ==
            # task_template.attributes.except(*MUTABLE_ATTRIBUTES)
        end
      end
    end

  end
end


# == Schema Information
#
# Table name: projects
#
#  id               :integer(4)      not null, primary key
#  name             :string(200)     default(""), not null
#  company_id       :integer(4)      default(0), not null
#  customer_id      :integer(4)      default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#  completed_at     :datetime
#  critical_count   :integer(4)      default(0)
#  normal_count     :integer(4)      default(0)
#  low_count        :integer(4)      default(0)
#  description      :text
#  open_tasks       :integer(4)
#  total_tasks      :integer(4)
#  total_milestones :integer(4)
#  open_milestones  :integer(4)
#  default_estimate :decimal(5, 2)   default(1.0)
#  neverBill        :boolean(1)
#
# Indexes
#
#  projects_company_id_index   (company_id)
#  projects_customer_id_index  (customer_id)
#

