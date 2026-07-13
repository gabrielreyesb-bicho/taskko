module Api
  module V1
    # Endpoint que hace proactiva a la app: TARS lo consulta periódicamente,
    # envía los avisos (Telegram / WhatsApp) y luego marca cuándo avisó por
    # última vez con POST /api/v1/tasks/:id/notified.
    class RemindersController < Api::BaseController
      # GET /api/v1/reminders/due
      # Tareas abiertas vencidas que no se han notificado hoy.
      def due
        tasks = Task.due_reminders
        render json: {
          count: tasks.size,
          as_of: Time.current.iso8601,
          reminders: tasks.map { |t| TaskSerializer.call(t) }
        }
      end
    end
  end
end
