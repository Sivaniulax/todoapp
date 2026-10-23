class AddStatusToTodos < ActiveRecord::Migration[8.1]
  def up
    add_column :todos, :status, :string, null: false, default: "pending"
    add_index :todos, :status

    execute "UPDATE todos SET status = 'completed' WHERE completed = TRUE"

    remove_column :todos, :completed
  end

  def down
    add_column :todos, :completed, :boolean, null: false, default: false

    execute "UPDATE todos SET completed = TRUE WHERE status = 'completed'"

    remove_column :todos, :status
  end
end
