# encoding: UTF-8
class ProjectTemplatesController < ProjectsController
  def index
    @project_templates = scoped_projects
    render :layout => "admin"
  end

  def create
    @project = create_entity(params[:project])
    @project.company_id = current_user.company_id

    if @project.save
      # create a task filter for the project
      TaskFilter.create(
        :shared => true, :user => current_user, :name => @project.name,
        :qualifiers_attributes => [
          {:qualifiable => @project},
          {:qualifiable => current_user.company.statuses.first}],
      )

      create_project_permissions_for(@project, params[:copy_project_id])
      check_if_project_has_users(@project)
    else
      flash[:error] = @project.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @project = scoped_projects.find(params[:id])
  end

  def update
    @project = scoped_projects.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:success] = t('flash.notice.model_updated', model: Project.model_name.human)
      redirect_to project_templates_path
    else
      render :edit
    end
  end

  def destroy
    project = scoped_projects.find(params[:id])

    if project.destroy
      flash[:success] = t('flash.notice.model_deleted', model: Project.model_name.human)
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
   @project_relation ||= current_user.get_project_templates
  end
end
