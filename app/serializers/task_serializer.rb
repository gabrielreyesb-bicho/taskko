# JSON estable que consume TARS. Un solo lugar define la forma de una tarea.
class TaskSerializer
  def self.call(task)
    {
      id: task.id,
      description: task.description,
      notes: task.notes,
      category: task.category,
      assigned_to: task.assigned_to,
      priority: task.priority,
      status: task.status,
      desired_completion_date: task.desired_completion_date&.iso8601,
      reminder_at: task.reminder_at&.iso8601,
      closed_at: task.closed_at&.iso8601,
      notified_at: task.notified_at&.iso8601,
      created_at: task.created_at.iso8601,
      updated_at: task.updated_at.iso8601
    }
  end
end
