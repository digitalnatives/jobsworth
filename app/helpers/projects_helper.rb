# encoding: UTF-8
module ProjectsHelper
  def start_at_title_helper
    if @project.template?
      t 'hint.project.template_start_at'
    else
      t 'hint.project.project_start_at'
    end
  end
end
