class Task < ApplicationRecord
  belongs_to :category

  # Personas a las que se puede asignar una tarea.
  enum :assigned_to, { gabriel: 0, lucy: 1 }, prefix: :assigned_to

  # Prioridad de la tarea (Alta / Media / Baja).
  enum :priority, { baja: 0, media: 1, alta: 2 }, prefix: :priority

  # Ciclo de vida de la tarea. El 1 era "en proceso": se retiró por no aportar
  # nada sobre "abierta". El hueco se respeta para no renumerar filas existentes.
  enum :status, { abierta: 0, cerrada: 2, cancelada: 3 }, prefix: :status

  # Estatus que se consideran "terminados" y disparan el sello de cierre real.
  CLOSED_STATUSES = %w[cerrada cancelada].freeze

  before_validation :normalize_name
  before_validation :assign_default_category

  validates :name, presence: true
  validates :category, presence: true

  before_save :sync_closed_at

  # --- Scopes ---

  # Tareas activas (no cerradas ni canceladas).
  scope :open_tasks, -> { where(status: :abierta) }

  # Cuándo vence una tarea: manda la meta (desired_completion_date). La alerta
  # (reminder_at) no vence nada, es un empujón que TARS da antes de tiempo, y
  # solo decide la fecha cuando la tarea no tiene meta.
  #
  # Por eso una tarea con alerta del lunes y meta del viernes NO está vencida
  # el martes: su recordatorio ya sonó, pero todavía tiene hasta el viernes.

  # Vencidas: su fecha ya pasó y siguen abiertas.
  scope :overdue_tasks, ->(now = Time.current) {
    open_tasks.where(
      "CASE WHEN desired_completion_date IS NOT NULL " \
        "THEN desired_completion_date < :hoy " \
        "ELSE reminder_at < :inicio_de_hoy END",
      hoy: now.to_date, inicio_de_hoy: now.beginning_of_day
    )
  }

  # Hoy: su fecha cae hoy.
  scope :due_today, ->(now = Time.current) {
    open_tasks.where(
      "CASE WHEN desired_completion_date IS NOT NULL " \
        "THEN desired_completion_date = :hoy " \
        "ELSE reminder_at BETWEEN :inicio_de_hoy AND :fin_de_hoy END",
      hoy: now.to_date, inicio_de_hoy: now.beginning_of_day, fin_de_hoy: now.end_of_day
    )
  }

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

  # La alerta ya llegó: sonó el recordatorio o se alcanzó la meta. Es lo que
  # hace que TARS insista, y por diseño se adelanta: NO quiere decir que la
  # tarea esté vencida.
  def alert_fired?(now = Time.current)
    return false unless status_abierta?

    (reminder_at.present? && reminder_at <= now) ||
      (desired_completion_date.present? && desired_completion_date <= now.to_date)
  end

  def due_for_notification?(now = Time.current)
    return false unless alert_fired?(now)

    notified_at.blank? || notified_at < now.beginning_of_day
  end

  # Vencida de verdad: su fecha ya pasó. Manda la meta; la alerta solo decide
  # cuando no hay meta. Misma regla que el scope .overdue_tasks, para que el
  # rojo de la lista y la vista "Vencidas" nunca se contradigan.
  def overdue?(now = Time.current)
    return false unless status_abierta?

    if desired_completion_date.present?
      desired_completion_date < now.to_date
    else
      reminder_at.present? && reminder_at < now.beginning_of_day
    end
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
