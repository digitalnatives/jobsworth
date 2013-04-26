# encoding: UTF-8
class TaskTemplatesController < TasksController
  include ActionView::Helpers::TextHelper

  def index
    @task_templates = current_templates
    render :layout => "admin"
  end

  def update
    @task = current_templates.find_by_id(params[:id])
    if @task.nil?
      flash[:error] = t('flash.alert.not_exists_or_no_permission', model: Template.model_name.human)
      redirect_from_last and return
    end

    @task.send(:do_update, params, current_user)

    flash[:success] ||= link_to_task(@task) + " - #{t('flash.notice.model_updated', model: Template.model_name.human)}"
    redirect_to :action=> "edit", :id => @task.task_num
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = (t('flash.error.model_update', model: Template.model_name.human) + '<br>' +
                    @task.errors.full_messages.join('<br>')).html_safe
    render :action=> "edit"
  end

  def destroy
    @task_template = current_templates.detect { |template| template.id == params[:id].to_i }
    @task_template.destroy
    flash[:success] = t('flash.notice.model_deleted', model: Template.model_name.human)
    redirect_to task_templates_path
  end

  def auto_complete_for_dependency_targets
    @tasks = Template.search(current_user, params[:term])
    hits = @tasks.collect do |task|
      {
        label: "[##{task.task_num}] #{task.name}",
        value: truncate(task.name, length: 17),
        id:    task.task_num,
        url:   url_for(action: 'dependency')
      }
    end
    render json: hits.to_json
  end

  def dependency
    dependency = Template.accessed_by(current_user)
                         .find_by_task_num(params[:dependency_id])

    render partial: 'dependency', locals: { dependency: dependency, perms: {} }
  end

protected
####  This methods inherited from TasksController.
####  They modifies behavior of TasksController actions: new, create, edit, update etc.
####  Please see design pattern Template Method.
  def create_entity
    Template.new(:company => current_user.company)
  end

  def check_if_user_has_projects
    unless current_user.has_projects_or_project_templates?
      flash[:error] = t('hint.task.project_needed')
      redirect_to new_project_template_path
    end
  end

end
