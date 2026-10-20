class CreateTodos < ActiveRecord::Migration[8.0]
  def change
    create_table :todos do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :category, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.text :description
      t.boolean :completed, null: false, default: false
      t.datetime :completed_at
      t.date :due_date
      t.integer :priority, null: false, default: 1 # 0 = low, 1 = medium, 2 = high

      t.timestamps
    end

    add_index :todos, [ :user_id, :completed ]
    add_index :todos, [ :user_id, :due_date ]
  end
end
