# encoding: UTF-8
class Status < ActiveRecord::Base
  belongs_to :company
  validates_presence_of :company, :name

  scope :by_company, ->(company) { where(company_id: company) }

  # Creates the default statuses expected in the system
  def self.create_default_statuses(company)
    raise ArgumentError unless company

    transaction do
      ['Open', 'Closed', "Won't fix", 'Invalid', 'Duplicate'].each do |resolution|
        by_company(company).where(name: resolution).first_or_create
      end
    end
  end

  def to_s
    name
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

