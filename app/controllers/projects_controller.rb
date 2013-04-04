# encoding: UTF-8
# Handle Projects for a company, including permissions

class ProjectsController < ApplicationController
  before_filter :authorize_user_is_admin, :except => [:index, :new, :create, :show, :list_completed]
  before_filter :authorize_user_can_create_projects, :only => [:new, :create]

  def index
    @projects = scoped_projects
                .in_progress.order('customer_id')
                .includes(:customer, :milestones)
                .paginate(:page => params[:page], :per_page => 100)

    @completed_projects = scoped_projects.completed
  end

  def new
    @project = create_entity
  end

  def create
    @project = create_entity(params[:project])
    @template = @project.dup_and_get_template(params[:template_id])
    @project.company_id = current_user.company_id

    if @project.save
      # create a task filter for the project
      TaskFilter.create(
        :shared => true, :user => current_user, :name => @project.name,
        :qualifiers_attributes => [
          {:qualifiable => @project},
          {:qualifiable => current_user.company.statuses.first}],
      )

      create_project_permissions_for(@project, params[:copy_project_id]) if params[:template_id].blank?
      check_if_project_has_users(@project)
    else
      flash[:error] = @project.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @project = scoped_projects.find(params[:id])

    if @project.nil?
      flash[:error] = "You can't access the project or it doesn't exist."
      redirect_to root_path
    else
      @users = User.where("company_id = ?", current_user.company_id).order("users.name")
    end
  end

  def show
    @project = scoped_projects.find(params[:id])
    if @project.nil?
      flash[:error] = "You can't access the project or it doesn't exist."
      redirect_to root_path
    else
      @users = User.where("company_id = ?", current_user.company_id).order("users.name")
    end
  end

  def update
    @project = scoped_projects.in_progress.find(params[:id])

    if @project.update_attributes(params[:project])
      flash[:success] = _('Project was successfully updated.')
      redirect_to projects_path
    else
      render :edit
    end
  end

  def destroy
    project = scoped_projects.find(params[:id])

    if project.destroy
      flash[:success] = 'Project was deleted.'
    else
      flash[:error] = project.errors[:base].join(', ')
    end

    redirect_to projects_path
  end

  ###
  # TODO: 'complete' and 'revert' can be replaced by 'update'...
  # remove this two actions after refactoring the view
  ###
  def complete
    project = scoped_projects.in_progress.find(params[:id])

    unless project.nil?
      project.completed_at = Time.now.utc
      project.save
      flash[:success] = _("#{project.name} completed.")
    end

    redirect_to edit_project_path(project)
  end

  def revert
    project = scoped_projects.completed.find(params[:id])

    unless project.nil?
      project.completed_at = nil
      project.save
      flash[:success] = _("#{project.name} reverted.")
    end

    redirect_to edit_project_path(project)
  end

  def list_completed
    @completed_projects = scoped_projects.completed.order("completed_at DESC")
  end

  ###
  ## TODO: Move this to the ProjectsPermissions controller
  ###
  def ajax_remove_permission
    permission = ProjectPermission.where("user_id = ? AND project_id = ? AND company_id = ?", params[:user_id], params[:id], current_user.company_id).first

    if params[:perm].nil? && permission
      permission.destroy
    elsif permission
      permission.remove(params[:perm])
      permission.save
    end

    if params[:user_edit] == "true"
      @user = current_user.company.users.find(params[:user_id])
      render :partial => "/users/project_permissions"
    else
      @project = current_user.company.projects_and_project_templates.find(params[:id])
      @users = Company.find(current_user.company_id).users.order("users.name")
      render :partial => "permission_list"
    end
  end

  def ajax_add_permission
    user = User.active.where("company_id = ?", current_user.company_id).find(params[:user_id])

    if current_user.admin?
      @project = current_user.company.projects_and_project_templates.find(params[:id])
    else
      @project = current_user.projects.find(params[:id])
    end

    if @project && user && ProjectPermission.where("user_id = ? AND project_id = ?", user.id, @project.id).empty?
      permission = ProjectPermission.new
      permission.user_id = user.id
      permission.project_id = @project.id
      permission.company_id = current_user.company_id
      permission.can_comment = 1
      permission.can_work = 1
      permission.can_close = 1
      permission.save
    else
      permission = ProjectPermission.where("user_id = ? AND project_id = ?", user.id, @project.id).first
      permission.set(params[:perm])
      permission.save
    end

    if params[:user_edit] == "true" && current_user.admin?
      @user = current_user.company.users.find(params[:user_id])
      render :partial => "users/project_permissions"
    else
      @users = Company.find(current_user.company_id).users.order("users.name")
      render :partial => "permission_list"
    end
  end

  def clone
    @template = ProjectTemplate.find(params[:id])
    @project = Project.new( @template.attributes.except("id", "type") )
    @project.start_at = Date.today
    render :new
  end

  protected

  def create_entity(attributes = nil)
    @project = Project.new(attributes)
  end

  private

  def authorize_user_can_create_projects
    msg = "You're not allowed to create new projects. Have your admin give you access."
    deny_access(msg) unless current_user.create_projects?
  end

  def create_project_permissions_for(project, copy_project_id)
    if copy_project_id.to_i > 0
      project_to_copy = current_user.all_projects.find(copy_project_id)
      project.copy_permissions_from(project_to_copy, current_user)
    else
      project.create_default_permissions_for(current_user)
    end
  end

  def check_if_project_has_users(project)
    if project.has_users?
      flash[:success] = _('Project was successfully created.')
      redirect_to (project.template?) ? project_templates_path : projects_path
    else
      flash[:success] =
        _('Project was successfully created. Add users who need access to this project.')
      redirect_to edit_project_path(project)
    end
  end

  def deny_access(msg)
    flash[:error] = _(msg)
    redirect_from_last
  end

  def scoped_projects
    @project_relation ||= current_user.get_projects
  end
end
