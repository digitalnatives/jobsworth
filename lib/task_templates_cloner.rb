# Clone task templates from a ProjectTemplate to a Project with restoring the
# dependencies
#
# TODO Maybe shouldn't know about the project, ajustment day would be enough

class TaskTemplatesCloner

  attr_accessor :project, :template, :cloned_tasks, :connections
  delegate :start_at, to: :project, prefix: true

  def self.clone(args)
    new(args).perform
  end

  def initialize(args)
    @project        = args[:to]
    @template       = args[:from]
    @cloned_tasks   = []
    @connections    = {}

    raise ArgumentError.new 'Only ProjectTemplate accepted as clone source'\
      unless template.is_a?(ProjectTemplate)
    raise ArgumentError.new 'Destination should be a Project'\
      unless project.is_a?(Project)
  end

  def perform
    ActiveRecord::Base.transaction do
      clone_and_ajust_tasks
      assign_dependencies

      project.tasks = cloned_tasks
    end

    return cloned_tasks
  end

private
  def clone_and_ajust_tasks
    self.cloned_tasks = template.task_templates.map do |t|
      self.connections[t] = t.duplicate(ajustment_days)
    end
  end

  def assign_dependencies
    connections.each_pair do |original, clone|
      original.dependencies.each do |dep|
        cloned_dep = connections[dep]
        clone.dependencies << cloned_dep if cloned_dep
      end
    end
  end

  def ajustment_days
    @ajustment_days ||= (project_start_at - template.start_at).days
  end
end
