class ProjectTemplate < AbstractProject

  validates :start_at, :presence => true

  after_initialize :set_default_start_at

private
  def set_default_start_at
    self.start_at ||= Date.current.beginning_of_year
  end

end

# == Schema Information
#
# Table name: projects
#
#  id               :integer          not null, primary key
#  name             :string(200)      default(""), not null
#  company_id       :integer          default(0), not null
#  customer_id      :integer          default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#  completed_at     :datetime
#  critical_count   :integer          default(0)
#  normal_count     :integer          default(0)
#  low_count        :integer          default(0)
#  description      :text
#  open_tasks       :integer
#  total_tasks      :integer
#  total_milestones :integer
#  open_milestones  :integer
#  default_estimate :decimal(5, 2)    default(1.0)
#  suppressBilling  :boolean          default(FALSE), not null
#
