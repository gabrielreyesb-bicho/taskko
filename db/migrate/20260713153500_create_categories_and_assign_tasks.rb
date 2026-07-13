class CreateCategoriesAndAssignTasks < ActiveRecord::Migration[8.1]
  def up
    create_table :categories do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :categories, "lower(name)", unique: true, name: "index_categories_on_lower_name"
    add_check_constraint :categories, "char_length(btrim(name)) > 0", name: "categories_name_not_blank"

    add_reference :tasks, :category, foreign_key: true

    execute <<~SQL.squish
      INSERT INTO categories (name, created_at, updated_at)
      SELECT MIN(clean_name), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM (
        SELECT COALESCE(NULLIF(btrim(category), ''), 'Personal') AS clean_name
        FROM tasks
      ) normalized_categories
      GROUP BY lower(clean_name)
    SQL

    execute <<~SQL.squish
      INSERT INTO categories (name, created_at, updated_at)
      SELECT 'Personal', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      WHERE NOT EXISTS (
        SELECT 1 FROM categories WHERE lower(name) = lower('Personal')
      )
    SQL

    execute <<~SQL.squish
      UPDATE tasks
      SET category_id = categories.id
      FROM categories
      WHERE lower(categories.name) = lower(COALESCE(NULLIF(btrim(tasks.category), ''), 'Personal'))
    SQL

    change_column_null :tasks, :category_id, false
    remove_column :tasks, :category, :string
  end

  def down
    add_column :tasks, :category, :string

    execute <<~SQL.squish
      UPDATE tasks
      SET category = categories.name
      FROM categories
      WHERE tasks.category_id = categories.id
    SQL

    change_column_null :tasks, :category, false
    change_column_default :tasks, :category, "Personal"
    remove_reference :tasks, :category, foreign_key: true

    drop_table :categories
  end
end
