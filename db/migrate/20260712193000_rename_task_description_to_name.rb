class RenameTaskDescriptionToName < ActiveRecord::Migration[8.1]
  def up
    rename_column :tasks, :description, :name

    remove_check_constraint :tasks, name: "tasks_description_not_blank" if check_constraint_exists?(:tasks, name: "tasks_description_not_blank")
    add_check_constraint :tasks,
      "char_length(btrim(name)) > 0",
      name: "tasks_name_not_blank"
  end

  def down
    remove_check_constraint :tasks, name: "tasks_name_not_blank" if check_constraint_exists?(:tasks, name: "tasks_name_not_blank")

    rename_column :tasks, :name, :description
    add_check_constraint :tasks,
      "char_length(btrim(description)) > 0",
      name: "tasks_description_not_blank"
  end
end
