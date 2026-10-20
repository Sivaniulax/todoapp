class AddSoftDeleteAndLockingToTodos < ActiveRecord::Migration[8.1]
  def change
    # Soft delete: trashed todos stay in the table so they can be restored.
    add_column :todos, :discarded_at, :datetime
    add_index :todos, [ :user_id, :discarded_at ]

    # Optimistic locking: ActiveRecord bumps this on every save and raises
    # StaleObjectError if two requests edit the same todo concurrently.
    add_column :todos, :lock_version, :integer, null: false, default: 0
  end
end
