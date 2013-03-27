class ProjectTemplatesController < ProjectsController
  def index
    @project_templates = ProjectTemplate.where(company_id: current_user.company_id)
    render :layout => "admin"
  end

  protected
  ####  This methods inherited from ProjectsController.
  ####  They modifies behavior of ProjectsController actions: new, create, edit, update etc.
  ####  Please see design pattern Template Method.
  def create_entity
    ProjectTemplate.new(:company => current_user.company)
  end
end
