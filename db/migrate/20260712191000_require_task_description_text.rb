class RequireTaskDescriptionText < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE tasks
      SET description = 'Sin nombre'
      WHERE description IS NULL OR btrim(description) = ''
    SQL

    change_column_null :tasks, :description, false
    add_check_constraint :tasks,
      "char_length(btrim(description)) > 0",
      name: "tasks_description_not_blank"
  end

  def down
    remove_check_constraint :tasks, name: "tasks_description_not_blank"
  end
end
