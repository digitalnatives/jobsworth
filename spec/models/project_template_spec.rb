require 'spec_helper'

describe ProjectTemplate do

  describe 'default start_at' do
    it 'should equal to the beginning of the current year' do
      expect(subject.start_at).to eql Date.current.beginning_of_year
    end

    context 'project is persisted' do
      let(:start_date) { 3.days.ago.to_date }
      let(:template)   { FactoryGirl.create :project_template, start_at: start_date }
      subject          { described_class.find template.id }

      it 'should equal the saved start date' do
        expect(subject.start_at).to eql start_date
      end
    end
  end
end
