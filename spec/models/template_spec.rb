require 'spec_helper'

describe Template do

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
    pending
  end

end
