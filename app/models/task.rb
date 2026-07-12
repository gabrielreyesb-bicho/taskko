class Task < ApplicationRecord
  # Personas a las que se puede asignar una tarea.
  enum :assigned_to, { gabriel: 0, lucy: 1 }, prefix: :assigned_to

  # Prioridad de la tarea (Alta / Media / Baja).
  enum :priority, { baja: 0, media: 1, alta: 2 }, prefix: :priority

  # Ciclo de vida de la tarea.
  enum :status, { abierta: 0, en_proceso: 1, cerrada: 2, cancelada: 3 }, prefix: :status

  # Estatus que se consideran "terminados" y disparan el sello de cierre real.
  CLOSED_STATUSES = %w[cerrada cancelada].freeze

  validates :description, presence: true
  validates :category, presence: true

  before_save :sync_closed_at

  # --- Scopes ---

  # Tareas activas (no cerradas ni canceladas).
  scope :open_tasks, -> { where(status: %i[abierta en_proceso]) }

  # Recordatorios que ya vencieron y que TARS todavía no ha notificado.
  # Esta es la consulta que hace proactiva a la app.
  scope :due_reminders, -> {
    where("reminder_at IS NOT NULL AND reminder_at <= ? AND notified_at IS NULL", Time.current)
      .order(:reminder_at)
  }

  # Marca la tarea como ya notificada por TARS (idempotente).
  def mark_notified!(at = Time.current)
    update!(notified_at: at)
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
end
