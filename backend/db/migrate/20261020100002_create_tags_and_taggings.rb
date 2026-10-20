class CreateTagsAndTaggings < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :name, null: false

      t.timestamps
    end

    # Same rule as categories: one "urgent" tag per user, case-insensitive.
    add_index :tags, "user_id, lower(name)", unique: true, name: "index_tags_on_user_id_and_lower_name"

    # Polymorphic join table, so tags can label todos today and categories later.
    create_table :taggings do |t|
      t.references :tag, null: false, foreign_key: { on_delete: :cascade }
      t.references :taggable, null: false, polymorphic: true

      t.timestamps
    end

    add_index :taggings, %i[tag_id taggable_type taggable_id], unique: true, name: "index_taggings_uniqueness"
  end
end
