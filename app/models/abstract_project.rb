# encoding: UTF-8
class AbstractProject < ActiveRecord::Base
  self.table_name = "projects"

  # Creates a score_rules association and updates the score
  # of all the task when adding a new score rule
  include Scorable

  belongs_to    :company
  belongs_to    :customer

  has_many      :users, :through => :project_permissions, :foreign_key => 'project_id'
  has_many      :project_permissions, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :tasks, :class_name => "TaskRecord", :foreign_key => 'project_id'
  has_many      :task_templates, :class_name => "Template", :foreign_key => 'project_id'
  has_many      :sheets, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :work_logs, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :project_files, :dependent => :destroy, :foreign_key => 'project_id'
  has_many      :milestones, :dependent => :destroy, :order => "due_at asc, lower(name) asc", :foreign_key => 'project_id'

  scope :completed, where('projects.completed_at IS NOT NULL')
  scope :in_progress, where('projects.completed_at' => nil)
  scope :from_this_year, where("created_at > ?", Time.zone.now.beginning_of_year - 1.month)

  validates_length_of    :name, maximum: 200
  validates_presence_of  :name
  validates_presence_of  :customer

  validates :default_estimate,
            presence:     true,
            numericality: { greater_than_or_equal_to: 1.0 }

  after_update    :update_work_sheets
  before_destroy  :reject_destroy_if_have_tasks

  def copy_permissions_from(project_to_copy, user)
    project_to_copy.project_permissions.each do |perm|
      new_permission = perm.dup
      new_permission.project_id = id

      if new_permission.user_id == user.id
        new_permission.company_id = user.company_id
        new_permission.set('all')
      end

      new_permission.save
    end
  end

  def create_default_permissions_for(user)
    project_permission            = ProjectPermission.new
    project_permission.user_id    = user.id
    project_permission.project_id = id
    project_permission.company_id = user.company_id
    project_permission.set('all')
    project_permission.save
  end

  def has_users?
    company.users.size >= 1
  end

  def full_name
    "#{customer.name} / #{name}"
  end

  def to_s
    name
  end

  def to_css_name
    "#{self.name.underscore.dasherize.gsub(/[ \."',]/,'-')} #{self.customer.name.underscore.dasherize.gsub(/[ \.'",]/,'-')}"
  end

  def total_estimate
    tasks.sum(:duration).to_i
  end

  def work_done
    tasks.sum(:worked_minutes).to_i
  end

  def overtime
    tasks.where("worked_minutes > duration").sum('worked_minutes - duration').to_i
  end

  def total_tasks_count
    if self.total_tasks.nil?
       self.total_tasks = tasks.count
       self.save
    end
    total_tasks
  end

  def open_tasks_count
    if self.open_tasks.nil?
       self.open_tasks = tasks.where("completed_at IS NULL").count
       self.save
    end
    open_tasks
  end

  def total_milestones_count
    if self.total_milestones.nil?
       self.total_milestones = milestones.count
       self.save
    end
    total_milestones
  end

  def open_milestones_count
    if self.open_milestones.nil?
       self.open_milestones = milestones.where("completed_at IS NULL").count
       self.save
    end
    open_milestones
  end

  def progress
    done_percent = 0.0
    total_count = self.total_tasks_count * 1.0
    if total_count >= 1.0
      done_count = total_count - self.open_tasks_count
      done_percent = (done_count/total_count) * 100.0
    end
    done_percent
  end

  def complete?
    !self.completed_at.nil?
  end

  def template?
    self.class == ProjectTemplate
  end

  def completed_milestones_count
    total_milestones_count - open_milestones_count
  end

  def billing_enabled?
    company.try :use_billing
  end

  def billable?
    billing_enabled? && !suppressBilling
  end

  def no_billing?
    !billable?
  end

  ###
  # Updates the critical, normal and low counts for this project.
  # Also updates open and total tasks.
  ###
  def update_project_stats
    self.critical_count = tasks.where("task_property_values.property_value_id" => company.critical_values).includes(:task_property_values).count
    self.normal_count = tasks.where("task_property_values.property_value_id" => company.normal_values).includes(:task_property_values).count
    self.low_count = tasks.where("task_property_values.property_value_id" => company.low_values).includes(:task_property_values).count

    self.open_tasks = nil
    self.total_tasks = nil
  end

  protected

  def reject_destroy_if_have_tasks
    unless tasks.count.zero?
      errors.add(:base, I18n.t('flash.error.destroy_dependents_of_model',
                               dependents: TaskRecord.model_name.human(count: 2),
                               model: Project.model_name.human))
      return false
    end
    true
  end

  def update_work_sheets
    if self.customer_id != self.customer_id_was
      WorkLog.update_all("customer_id = #{self.customer_id}",
        "project_id = #{self.id} AND customer_id != #{self.customer_id}")
    end
  end
end

