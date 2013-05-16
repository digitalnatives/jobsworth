# encoding: UTF-8
class Status < ActiveRecord::Base

  OPEN         = 'Open'
  CLOSED       = 'Closed'
  WILL_NOT_FIX = "Will not fix"
  INVALID      = 'Invalid'
  DUPLICATE    = 'Duplicate'
  DEFAULT_RESOLUTIONS = [OPEN, CLOSED]

  belongs_to :company
  validates_presence_of :company, :name

  scope :by_company, ->(company) { where(company_id: company) }

  def self.create_default_statuses(company)
    raise ArgumentError unless company

    transaction do
      DEFAULT_RESOLUTIONS.each do |name|
        public_send 'default_' + name.parameterize('_'), company
      end
    end
  end

  def self.default_open(company)
    get_status! company, name: OPEN, open: true
  end

  def self.default_closed(company)
    get_status! company, name: OPEN, closed: true, resolved: true
  end

  def self.defalult_will_not_fix(company)
    get_status! company, name: WILL_NOT_FIX, will_not_fix: true, resolved: true
  end

  def self.defalult_not_valid(company)
    get_status! company, name: INVALID, not_valid: true, resolved: true
  end

  def self.defalult_duplicate(company)
    get_status! company, name: DUPLICATE, duplicate: true, resolved: true
  end

  def to_s
    name
  end

private
  def self.get_status!(company, options)
    by_company(company).where(options).first_or_create
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
#  open
#  will_not_fix
#
#

