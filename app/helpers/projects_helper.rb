# encoding: UTF-8
module ProjectsHelper
  def start_at_title_helper
    if @project.template?
      "A default start date for project template, related milestones due date will be recalculated relative to this date when project template converted to project"
    else
      "Milestones due date will updated according the difference of the project template start date and current project start date"
    end
  end
end
