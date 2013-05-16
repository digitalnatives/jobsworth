# encoding: UTF-8
class Status < ActiveRecord::Base

  OPEN         = 'Open'
  CLOSED       = 'Closed'
  WILL_NOT_FIX = "Won't fix"
  INVALID      = 'Invalid'
  DUPLICATE    = 'Duplicate'
  DEFAULT_RESOLUTIONS = [OPEN, CLOSED, WILL_NOT_FIX, INVALID, DUPLICATE]

  belongs_to :company
  validates_presence_of :company, :name

  scope :by_company, ->(company) { where(company_id: company) }

  def self.create_default_statuses(company)
    raise ArgumentError unless company

    transaction do
      DEFAULT_RESOLUTIONS.each do |name|
        get_status! company, name
      end
    end
  end

  def self.get_status!(company, name)
    by_company(company).where(name: name).first_or_create
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

