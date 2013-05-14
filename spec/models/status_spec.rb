require 'spec_helper'

describe Status do
  it { should belong_to :company }
  it { should validate_presence_of :company }
  it { should validate_presence_of :name }
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

