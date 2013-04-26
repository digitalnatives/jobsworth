require 'spec_helper'

describe Todo do

  it { should belong_to :task }
  it { should belong_to :completed_by_user }

  describe '#done?' do
    subject { described_class.new({completed_at: completed_at}) }

    context 'when completed_at is nil' do
      let(:completed_at) { nil }
      it { expect(subject.done?).to be_false }
    end

    context 'when completed_at is a date' do
      let(:completed_at) { Time.now }
      it { expect(subject.done?).to be_true }
    end
  end

  describe '#css_classes' do
    pending 'This method should be in a helper/decorator!'
  end

  describe '#detach_from_task' do
    subject { described_class.new({task_id: 1}) }

    it 'should detach from task' do
      expect{ subject.detach_from_task }.to change{ subject.task_id }.from(1).to(nil)
    end

    it 'should return itself' do
      expect(subject.detach_from_task).to equal subject
    end
  end

end
