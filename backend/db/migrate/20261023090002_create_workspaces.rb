class CreateWorkspaces < ActiveRecord::Migration[8.1]
  def up
    create_table :workspaces do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.timestamps
    end
    add_index :workspaces, :slug, unique: true

    add_reference :users, :workspace, foreign_key: true
    add_reference :todos, :workspace, foreign_key: true
    add_reference :categories, :workspace, foreign_key: true
    add_reference :tags, :workspace, foreign_key: true

    # Everyone who already has an account gets a workspace of their own.
    execute <<~SQL.squish
      INSERT INTO workspaces (name, slug, created_at, updated_at)
      SELECT CONCAT(users.name, '''s workspace'), CONCAT('w-', users.id), NOW(), NOW()
      FROM users
    SQL
    execute "UPDATE users SET workspace_id = workspaces.id FROM workspaces WHERE workspaces.slug = CONCAT('w-', users.id)"
    execute "UPDATE todos SET workspace_id = users.workspace_id FROM users WHERE users.id = todos.user_id"
    execute "UPDATE categories SET workspace_id = users.workspace_id FROM users WHERE users.id = categories.user_id"
    execute "UPDATE tags SET workspace_id = users.workspace_id FROM users WHERE users.id = tags.user_id"

    change_column_null :users, :workspace_id, false
    change_column_null :todos, :workspace_id, false
    change_column_null :categories, :workspace_id, false
    change_column_null :tags, :workspace_id, false
  end

  def down
    remove_reference :tags, :workspace
    remove_reference :categories, :workspace
    remove_reference :todos, :workspace
    remove_reference :users, :workspace
    drop_table :workspaces
  end
end
