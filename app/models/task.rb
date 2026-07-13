class Task < ApplicationRecord
  belongs_to :category

  # Personas a las que se puede asignar una tarea.
  enum :assigned_to, { gabriel: 0, lucy: 1 }, prefix: :assigned_to

  # Prioridad de la tarea (Alta / Media / Baja).
  enum :priority, { baja: 0, media: 1, alta: 2 }, prefix: :priority

  # Ciclo de vida de la tarea.
  enum :status, { abierta: 0, en_proceso: 1, cerrada: 2, cancelada: 3 }, prefix: :status

  # Estatus que se consideran "terminados" y disparan el sello de cierre real.
  CLOSED_STATUSES = %w[cerrada cancelada].freeze

  before_validation :normalize_name
  before_validation :assign_default_category

  validates :name, presence: true
  validates :category, presence: true

  before_save :sync_closed_at

  # --- Scopes ---

  # Tareas activas (no cerradas ni canceladas).
  scope :open_tasks, -> { where(status: %i[abierta en_proceso]) }

  # Alertas de tareas abiertas que TARS debe insistir hasta que se atiendan.
  def self.due_reminders(now = Time.current)
    open_tasks
      .where(
        "(reminder_at IS NOT NULL AND reminder_at <= :now) OR " \
          "(desired_completion_date IS NOT NULL AND desired_completion_date <= :today)",
        now: now,
        today: now.to_date
      )
      .where("notified_at IS NULL OR notified_at < ?", now.beginning_of_day)
      .order(:reminder_at, :desired_completion_date, :created_at)
  end

  # Marca la tarea como ya notificada por TARS (idempotente).
  def mark_notified!(at = Time.current)
    update!(notified_at: at)
  end

  def category_name
    category&.name
  end

  def due_for_notification?(now = Time.current)
    return false unless status_abierta? || status_en_proceso?

    reminder_due = reminder_at.present? && reminder_at <= now
    target_overdue = desired_completion_date.present? && desired_completion_date <= now.to_date
    alert_due = reminder_due || target_overdue
    not_notified_today = notified_at.blank? || notified_at < now.beginning_of_day

    alert_due && not_notified_today
  end

  def overdue?(now = Time.current)
    return false unless status_abierta? || status_en_proceso?

    (reminder_at.present? && reminder_at <= now) ||
      (desired_completion_date.present? && desired_completion_date <= now.to_date)
  end

  private

  # Sella closed_at automáticamente al cerrar/cancelar, y lo limpia si se reabre.
  def sync_closed_at
    if CLOSED_STATUSES.include?(status)
      self.closed_at ||= Time.current
    else
      self.closed_at = nil
    end
  end

  def normalize_name
    self.name = name.to_s.strip if name.present?
  end

  def assign_default_category
    self.category ||= Category.find_or_create_by_name!("Personal")
  end
end
