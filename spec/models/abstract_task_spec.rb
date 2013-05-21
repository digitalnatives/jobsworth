require 'spec_helper'

describe AbstractTask do

  it { should belong_to :status }
  it { should belong_to :company }
  it { should belong_to :project }
  it { should belong_to :milestone }
  it { should belong_to :creator }
  it { should have_many :users }
  it { should have_many :owners }
  it { should have_many :watchers }
  it { should have_many :task_users }
  it { should have_many :task_watchers }
  it { should have_many :task_owners }

  describe 'assocated user' do
    subject { FactoryGirl.create :task }

    it 'owners is a subset of users' do
      some_user = FactoryGirl.create(:user)
      subject.owners << some_user

      subject.users.should include(some_user)
    end

    it 'watchers is a subset of users' do
      some_user = FactoryGirl.create(:user)
      subject.watchers << some_user

      subject.users.should include(some_user)
    end
  end

  describe '.status_types' do
    pending
  end

  describe '.accessed_by' do
    before { create_test_data_for_assess_scopes }

    it "should return tasks only from user's company" do
      company_tasks           = @user.company.tasks
      tasks_accessed_by_user  = TaskRecord.accessed_by(@user)
      company_tasks.should include *tasks_accessed_by_user
    end

    it "should the tasks from completed projects" do
      completed_project = @user.projects.first
      completed_project.update_attributes(:completed_at => 1.day.ago.utc)
      tasks_accessed_by_user = TaskRecord.accessed_by(@user)

      tasks_accessed_by_user.should include *completed_project.tasks
    end

    context "when the user doesn't have can_see_unwatched permission" do
      it "should return only watched tasks" do
        permission = @user.project_permissions.first
        permission.update_attributes(:can_see_unwatched => 0)
        @user.reload
        TaskRecord.accessed_by(@user).each do |task|
          @user.should be_can(task.project, 'see_unwatched') unless task.users.include?(@user)
        end
      end
    end
  end

  describe '.all_accessed_by' do
    before { create_test_data_for_assess_scopes }

    it "should return tasks only from user's company" do
      TaskRecord.all_accessed_by(@user).each do |task|
        @user.company.tasks.should include(task)
      end
    end

    it "should return only watched tasks if user not have can_see_unwatched permission" do
      permission=@user.project_permissions.first
      permission.remove('see_unwatched')
      permission.save!
      @user.reload
      TaskRecord.all_accessed_by(@user).each do |task|
        @user.should be_can(task.project, 'see_unwatched') unless task.users.include?(@user)
      end
    end

    it "should return tasks from all users projects, even completed" do
      project= @user.projects.first
      project.completed_at= Time.now.utc
      project.save!
      TaskRecord.all_accessed_by(@user).should ==
        TaskRecord.all(:conditions=> ["tasks.project_id in(?)", @user.all_project_ids])
    end
  end

  describe "add users, resources, dependencies to task using Task#set_users_resources_dependencies" do
    before(:each) do
      @company = Company.make
      @task = TaskRecord.make(:company=>@company)
      @user = User.make(:company=>@company, :projects=>[@task.project], :admin=>true)
      @resource = Resource.make(:company=>@company)
      @task.owners<< User.make(:company=>@company, :projects=>[@task.project])
      @task.watchers<< User.make(:company=>@company, :projects=>[@task.project])
      @task.resources<< Resource.make(:company=>@company)
      @task.dependencies<< TaskRecord.make(:company=>@company, :project=>@task.project)
      @params = {:dependencies=>[@task.dependencies.first.task_num.to_s],
                     :resource=>{:name=>'',:ids=>@task.resource_ids},
                     :assigned=>@task.owner_ids,
                     :users=>@task.user_ids}
      @task.save!
    end
    context "when task saved" do
      it "should saved new user in database if add task user" do
        @params[:users] << @user.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.users.should include(@user)
      end

      it "should saved task without user in database if delete task user" do
        @params[:users] = []
        @params[:assigned] = []
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.users.should == []
      end

      it "should saved new resource in database if add task resource" do
        @task.resource_ids.should_not include(@resource.id)
        @params[:resource][:ids] << @resource.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.resources.should include(@resource)
      end
      it "should saved task without resource in database if delete task resource" do
        @params[:resource][:ids] = []
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.resources.should == []
      end
      it "should saved new dependencies if add task dependencies" do
        dependent = TaskRecord.make(:company => @company, :project => @task.project)
        @params[:dependencies] << dependent.task_num.to_s
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.dependencies.should include(dependent)
      end
      it "should saved task without dependency if delete task dependencies" do
        @params[:dependencies]=[]
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.dependencies.should == []
      end

      it "should not change task user in database if not changed task user" do
        user_ids = @task.user_ids
        @params[:resource][:ids] << @resource.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.user_ids.should == user_ids
      end
      it "should not change task resource in database if not changed task resource" do
        resource_ids = @task.resource_ids
        @params[:users] << @user.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        @task.resource_ids.should == resource_ids
      end
      it "should not change task dependency in database if not changed task dependency" do
        dependencies = @task.dependencies
        @params[:users] << @user.id
        @params[:resource][:ids] << @resource.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.save.should == true
        @task.reload
        expect(@task.dependencies).to match_array dependencies
      end
    end

    context "when task not saved" do

      it "should build new user in memory if add task user" do
        pending
        @params[:users] << @user.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.project_id = nil
        @task.save.should == false
        @task.users.should include(@user)
        @task.reload
        @task.users.should_not include(@user)
      end

      it "should delete exist user from memory if delete task user" do
        pending
        @params[:user] = []
        @params[:assigned] = []
        @task.set_users_dependencies_resources(@params, @user)
        @task.project_id = nil
        @task.save.should == false
        @task.users.should == []
        @task.reload
        @task.users.should_not []
      end

      it "should build new resource in memory if add task resource" do
        pending
        @task.resource_ids.should_not include(@resource.id)
        @params[:resource][:ids] << @resource.id
        @task.set_users_dependencies_resources(@params, @user)
        @task.project_id = nil
        @task.save.should == false
        @task.resources.should include(@resource)
        @task.reload
        @task.resources.should_not include(@resource)
      end

      it "should delete exist resource from memory if delete task resource" do
        pending
        @task.resources.should_not be_empty
        ids= @task.resource_ids
        @params[:resource][:ids] = []
        @task.set_users_dependencies_resources(@params, @user)
        @task.project_id = nil
        @task.save.should == false
        @task.resources.should be_empty
        @task.reload
        @task.resource_ids.should == ids
      end

      it "should build new dependency in memory if add task dependency" do
        pending
        dependent = TaskRecord.make(:company => @company, :project => @task.project)
        @params[:dependencies] << dependent.task_num.to_s
        @task.set_users_dependencies_resources(@params, @user)
        @task.project_id = nil
        @task.save.should == false
        @task.dependencies.should include(dependent)
        @task.reload
        @task.dependencies.should_not include(dependent)
      end
      it "should delete exist dependency from memory if delete task dependency"

      it "should not change task user in database if not change task user"
      it "should not change task resource in database if not change task resource"
      it "should not change task dependency in database if not change task dependency"
    end
  end

  describe '#statuses_for_select_list' do
    let(:status_1) { mock_model Status, id: 1, name: 'First status' }
    let(:status_2) { mock_model Status, id: 2, name: 'Second status' }
    let(:company)  { mock_model Company, statuses: [status_1, status_2] }

    subject { described_class.new company: company }

    it 'should be a nested array with names and ids of the statuses of company' do
      expect(subject.statuses_for_select_list).to match_array [
        ['First status', 1], ['Second status', 2]
      ]
    end
  end

  describe '#issue_name' do
    subject { described_class.new task_num: 1, name: 'Task name' }
    specify { expect(subject.issue_name).to eql '[#1] Task name' }
  end

  describe '#issue_num' do
    subject { described_class.new task_num: 1 }

    context 'when task is not closed' do
      before { subject.stub closed?: false }
      specify { expect(subject.issue_num).to eql '#1' }
    end

    context 'when task is closed' do
      before { subject.stub closed?: true }
      specify { expect(subject.issue_num).to eql '<strike>#1</strike>' }
    end
  end

  describe '#owners_to_display' do
    subject { described_class.new owners: owners }

    context 'when owners exist' do
      let(:owners) { [mock_model(User, name: 'Jack'), mock_model(User, name: 'Joe')] }
      specify { expect(subject.owners_to_display).to eql 'Jack and Joe' }
    end

    context 'when owners exist' do
      let(:owners) { [] }
      specify { expect(subject.owners_to_display).to eql 'Unassigned' }
    end
  end

  def create_test_data_for_access_scopes
    company    = FactoryGirl.create :company
    p1, p2, p3 = FactoryGirl.create_list :project, 3, company: company
    p4         = FactoryGirl.create :project
    @user      = FactoryGirl.create :user, company: company

    [p1, p2].each do |project|
      @user.projects << project
      FactoryGirl.create_list(:task, 2, company: company, project: project, users: [@user])
      FactoryGirl.create_list(:task, 1, company: company, project: project)
    end
    FactoryGirl.create_list(:task, 1, company: company, project: p3)
    FactoryGirl.create_list(:task, 1, project: p4)
  end

end
