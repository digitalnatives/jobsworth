require 'spec_helper'

describe Status do
  it { should belong_to :company }
  it { should validate_presence_of :company }
  it { should validate_presence_of :name }

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

  describe '.get_status!' do
    let(:company) { FactoryGirl.create :company_without_callbacks }

    context 'when the status exists' do
      let!(:status) { described_class.create company: company, name: described_class::OPEN }

      it 'should return the existing status' do
        expect(described_class.get_status!(company, described_class::OPEN))
        .to eql status
      end
    end

    context 'when the status does not exists' do
      it 'should create and return it' do
        expect{ described_class.get_status!(company, described_class::OPEN) }
        .to change { Status.by_company(company).count }.by(1)
      end
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

