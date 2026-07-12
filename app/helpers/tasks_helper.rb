module TasksHelper
  STATUS_LABELS = {
    "abierta" => "Abierta",
    "en_proceso" => "En proceso",
    "cerrada" => "Cerrada",
    "cancelada" => "Cancelada"
  }.freeze

  PRIORITY_LABELS = {
    "baja" => "Baja",
    "media" => "Media",
    "alta" => "Alta"
  }.freeze

  ASSIGNED_LABELS = {
    "gabriel" => "Gabriel",
    "lucy" => "Lucy"
  }.freeze

  def status_label(task)  = STATUS_LABELS.fetch(task.status, task.status.humanize)
  def priority_label(task) = PRIORITY_LABELS.fetch(task.priority, task.priority.humanize)
  def assigned_label(task) = ASSIGNED_LABELS.fetch(task.assigned_to, task.assigned_to.humanize)

  # Clases Tailwind (paleta Nettsy) para el badge de estatus.
  def status_badge_classes(task)
    case task.status
    when "abierta"    then "bg-brand-dark text-brand-light"
    when "en_proceso" then "bg-info/25 text-blue-200"
    when "cerrada"    then "bg-line text-ink-muted"
    when "cancelada"  then "bg-danger/20 text-danger-text"
    else "bg-line text-ink-muted"
    end
  end

  # Clases Tailwind para el badge de prioridad.
  def priority_badge_classes(task)
    case task.priority
    when "alta"  then "bg-danger/20 text-danger-text"
    when "media" then "bg-warn/20 text-warn"
    when "baja"  then "bg-brand-dark text-brand-light"
    else "bg-line text-ink-muted"
    end
  end

  # Formatea un datetime en la zona local, o un guion si es nil.
  def datetime_or_dash(value)
    return "—" if value.blank?
    l(value.in_time_zone, format: :short)
  end

  def date_or_dash(value)
    return "—" if value.blank?
    l(value, format: :long)
  end

  # true si el recordatorio ya venció y sigue pendiente de notificar.
  def reminder_overdue?(task)
    task.reminder_at.present? && task.reminder_at <= Time.current && task.notified_at.nil?
  end
end
