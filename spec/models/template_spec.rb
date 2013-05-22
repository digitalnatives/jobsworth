require 'spec_helper'

describe Template do

  it { should be_an AbstractTask }

  describe '#clone_todos' do
    let(:template_with_todos) { FactoryGirl.create :template_with_todos, todos_count: 3 }
    subject { template_with_todos.clone_todos }

    it 'should clone todos with all attributes' do
      original_attributes = template_with_todos.todos.map do |t|
        t.attributes.except(*%w[id task_id created_at updated_at])
      end
      cloned_attributes = subject.map do |t|
        t.attributes.except(*%w[id task_id created_at updated_at])
      end

      expect(cloned_attributes).to match_array original_attributes
    end

    it 'should clone todos detached from task' do
      expect(subject.map(&:task_id)).to match_array [nil, nil, nil]
    end
  end

  describe '#duplicate' do
    let(:owners)   { [stub_model(User)] }
    let(:watchers) { [stub_model(User)] }
    let(:users)    { [stub_model(User)] }
    let(:todos)    { [stub_model(Todo)] }
    let(:cloned_todos) { [stub_model(Todo)] }
    let(:template) { FactoryGirl.build :template,
                                        owners: owners, users: users,
                                        watchers: watchers, todos: todos,
                                        due_at: 2.days.from_now }
    let(:ajustment_days) { 1.day }

    before(:each)  { template.stub clone_todos: cloned_todos }

    subject { template.duplicate ajustment_days }

    it('should not equal with the original') { expect(subject).to_not eql template }
    it('should return a TaskRecord') { expect(subject).to be_a TaskRecord }

    it('should have the same owners') {
      expect(subject.owners).to match_array owners }
    it('should have the same watchers') {
      expect(subject.watchers).to match_array watchers }
    it('should have the same users') {
      expect(subject.users).to match_array users }
    it('should have cloned todos') {
      expect(subject.todos).to match_array cloned_todos }
    it('should have cloned properties') { pending }

    it('should have ajusted due at date') {
      expect(subject.due_at).to eql(template.due_at + ajustment_days) }
  end

  describe 'dependencies validation' do
    let(:project) { mock_model(Project) }
    let(:dep1) { stub_model Template, project: project_dep }
    subject { FactoryGirl.build :task_template, project: project, dependencies: [dep1] }

    context 'when dependency belongs to other project' do
      let(:project_dep) { mock_model(Project) }
      it { should_not be_valid }
    end

    context 'when dependency belongs to the same project' do
      let(:project_dep) { project }
      it { should be_valid }
    end
  end

end
