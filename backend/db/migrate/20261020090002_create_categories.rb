class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false
      t.string :color, null: false, default: "#6366f1"
      t.integer :todos_count, null: false, default: 0

      t.timestamps
    end

    # One "Work" category per user (case-insensitive), enforced by the database too.
    add_index :categories, "user_id, lower(name)", unique: true, name: "index_categories_on_user_id_and_lower_name"
  end
end
