require 'spec_helper'

describe TaskTemplatesCloner do

  let(:template) { FactoryGirl.create :project_template }
  let(:project)  { Project.new }

  describe '.new' do
    subject { described_class.new from: template, to: project }

    it { expect { subject }.to_not raise_error }

    context 'when a simple project passed as clone source' do
      let(:template) { project }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when a template passed as destination' do
      let(:project) { template }
      it { expect { subject }.to raise_error(ArgumentError) }
    end
  end

  describe '#perform' do
    it 'clones task templates to tasks, ajust their due dates and assign their dependencies' do
      pending 'Needs to be tested !!!!'
    end
  end

end
