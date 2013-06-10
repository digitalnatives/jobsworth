require 'spec_helper'

describe Status do
  it { should belong_to :company }
  it { should validate_presence_of :company }
  it { should validate_presence_of :name }

  it { should respond_to :resolved? }
  it { should respond_to :open? }
  it { should respond_to :closed? }
  it { should respond_to :will_not_fix? }
  it { should respond_to :not_valid? }
  it { should respond_to :duplicate? }

  describe '.create_default_statuses' do
    let(:company) { FactoryGirl.create :company_without_callbacks }

    context 'when no status exists' do
      it 'should create new statuses for company' do
        expect(described_class.by_company(company).count).to eql 0

        expect { described_class.create_default_statuses(company) }
        .to change { described_class.by_company(company).count }
            .by(Status::DEFAULT_RESOLUTIONS.size)
      end
    end

    context 'when default statuses exists' do
      before { described_class.create_default_statuses(company) }

      it 'should not change existing statuses' do
        expect { described_class.create_default_statuses(company) }
        .to_not change { described_class.by_company(company).all }
      end
    end

    context 'when company is nil' do
      specify { expect { described_class.create_default_statuses(nil) }.to raise_error(ArgumentError) }
    end
  end

end

# == Schema Information
#
# Table name: statuses
#
#  id         :integer(4)      not null, primary key
#  company_id :integer(4)
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

