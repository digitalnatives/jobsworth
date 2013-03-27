class ProjectTemplatesController < ProjectsController
  def index
    @project_templates = project_relation
    render :layout => "admin"
  end

  def edit
    @project = project_relation.find(params[:id])
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

  def project_relation
    ProjectTemplate.where(company_id: current_user.company_id)
  end
end
