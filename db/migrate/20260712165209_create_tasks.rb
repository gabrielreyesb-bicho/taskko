class CreateTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks do |t|
      t.string :description, null: false
      t.text :notes
      t.string :category, null: false, default: "Personal"
      t.integer :assigned_to, null: false, default: 0        # 0 => gabriel
      t.integer :priority, null: false, default: 1           # 1 => media
      t.integer :status, null: false, default: 0             # 0 => abierta
      t.date :desired_completion_date
      t.datetime :reminder_at
      t.datetime :closed_at
      t.datetime :notified_at

      t.timestamps
    end

    # TARS consulta recordatorios vencidos: reminder_at <= now AND notified_at IS NULL.
    # Este índice parcial hace ese barrido barato aunque crezca la tabla.
    add_index :tasks, :reminder_at, where: "notified_at IS NULL", name: "index_tasks_pending_reminders"
    add_index :tasks, :status
  end
end
