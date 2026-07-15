class RemoveEnProcesoStatusFromTasks < ActiveRecord::Migration[8.1]
  EN_PROCESO = 1
  ABIERTA = 0

  # "En proceso" salió del enum de Task. Una fila que se quede en 1 no truena:
  # Rails devuelve status = nil y la tarea desaparece de los filtros y de los
  # recordatorios sin avisar. Se reasignan a "abierta", que es lo que eran.
  def up
    execute "UPDATE tasks SET status = #{ABIERTA} WHERE status = #{EN_PROCESO}"
  end

  # Irreversible: ya en 0, no hay forma de saber cuáles eran "en proceso".
  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
