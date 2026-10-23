# PaperTrail's audit table. jsonb rather than the default text column, so
# the payload stays queryable and #changeset needs no YAML.
class CreateVersions < ActiveRecord::Migration[8.1]
  def change
    create_table :versions do |t|
      t.string :item_type, null: false
      t.bigint :item_id, null: false
      t.string :event, null: false
      t.bigint :whodunnit
      t.jsonb :object
      t.jsonb :object_changes
      t.datetime :created_at, null: false
    end

    add_index :versions, %i[item_type item_id created_at]
    add_index :versions, :whodunnit
  end
end
