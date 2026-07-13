# JSON estable que consume TARS. Un solo lugar define la forma de una tarea.
class TaskSerializer
  def self.call(task)
    {
      id: task.id,
      name: task.name,
      notes: task.notes,
      category: task.category_name,
      category_id: task.category_id,
      assigned_to: task.assigned_to,
      priority: task.priority,
      status: task.status,
      desired_completion_date: task.desired_completion_date&.iso8601,
      reminder_at: task.reminder_at&.iso8601,
      closed_at: task.closed_at&.iso8601,
      notified_at: task.notified_at&.iso8601,
      overdue: task.overdue?,
      due_for_notification: task.due_for_notification?,
      created_at: task.created_at.iso8601,
      updated_at: task.updated_at.iso8601
    }
  end
end
