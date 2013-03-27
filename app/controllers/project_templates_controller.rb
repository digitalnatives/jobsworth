class ProjectTemplatesController < ProjectsController
  def index
    @project_templates = scoped_projects
    render :layout => "admin"
  end

  def edit
    @project = scoped_projects.find(params[:id])
  end

  def update
    @project = scoped_projects.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:success] = _('Project was successfully updated.')
      redirect_to project_templates_path
    else
      render :edit
    end
  end

  def destroy
    project = project_relation.find(params[:id])

    if project.destroy
      flash[:success] = 'Project was deleted.'
    else
      flash[:error] = project.errors[:base].join(', ')
    end

    redirect_to project_templates_path
  end

  protected

  #  This methods inherited from ProjectsController.
  def create_entity(attributes = nil)
    # TODO: consider
    #attributes.merge!(:company => current_user.company)
    ProjectTemplate.new(attributes)
  end

  def scoped_projects
    ProjectTemplate.where(company_id: current_user.company_id)
  end
end
