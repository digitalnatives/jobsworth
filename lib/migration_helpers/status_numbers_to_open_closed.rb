# Prerequisite:
# - tasks.status -> tasks.status_id
# - Status model can create default statuses for company
# - default resolutions are 'open' and 'closed'

class StatusNumbersToOpenClosed
  def migrate
    remove_orphan_tasks
    remove_previous_statuses

    each_company do |company|
      resolutions = resolutions_of(company)

      migrate_tasks   company.tasks,     resolutions
      migrate_tasks   company.templates, resolutions

      qualifiers = TaskFilterQualifier.by_company(company).by_qualifiable_type('Status')
      migrate_filter_qualifiers qualifiers, resolutions
    end
  end

private
  def each_company(&blk)
    Company.find_each &blk
  end

  def remove_orphan_tasks
    AbstractTask.where(company_id: nil).destroy_all
  end

  def remove_previous_statuses
    Status.delete_all
  end

  def resolutions_of(company)
    company.create_default_statuses
    open   = Status.default_open(company)
    closed = Status.default_closed(company)

    return { open: open, closed: closed }
  end

  def migrate_tasks(tasks, resolutions)
    tasks.where('tasks.status_id != 0').update_all(status_id: resolutions[:closed].id)
    tasks.where('tasks.status_id' => 0).update_all(status_id: resolutions[:open].id)
  end

  def migrate_filter_qualifiers(qualifiers, resolutions)
    qualifiers.where('task_filter_qualifiers.qualifiable_id != 0').update_all(qualifiable_id: resolutions[:closed].id)
    qualifiers.where('task_filter_qualifiers.qualifiable_id' => 0).update_all(qualifiable_id: resolutions[:open].id)
  end
end

