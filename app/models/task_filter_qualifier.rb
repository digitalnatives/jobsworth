# encoding: UTF-8
class TaskFilterQualifier < ActiveRecord::Base
  attr_accessor :task_num

  belongs_to :task_filter, :touch => true
  belongs_to :qualifiable, :polymorphic => true

  validates_presence_of :qualifiable

  before_validation :set_qualifiable_from_task_num
  before_validation :set_qualifiable_from_project

  scope :for, lambda { |type| where(:qualifiable_type => type) }
  scope :reversed, where(:reversed => true)
  scope :by_qualifiable_type, ->(qtype) { where(qualifiable_type: qtype) }
  scope :by_company, ->(company) {
    joins(:task_filter).where('task_filters.company_id' => company)
  }

  private

  def set_qualifiable_from_task_num
    return if task_num.blank?

    task = TaskRecord.accessed_by(task_filter.user).find_by_task_num(task_num)
    if task
      self.qualifiable = task
    end
  end

  def set_qualifiable_from_project
    return unless qualifiable.is_a?(AbstractProject)

    self.qualifiable_type = qualifiable.class.to_s
  end

end






# == Schema Information
#
# Table name: task_filter_qualifiers
#
#  id                 :integer(4)      not null, primary key
#  task_filter_id     :integer(4)
#  qualifiable_type   :string(255)
#  qualifiable_id     :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#  qualifiable_column :string(255)
#  reversed           :boolean(1)      default(FALSE)
#
# Indexes
#
#  fk_task_filter_qualifiers_task_filter_id  (task_filter_id)
#

