class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 1 # 0 = guest, 1 = member, 2 = admin
      t.datetime :guest_expires_at
      t.integer :todos_count, null: false, default: 0 # counter cache

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, [ :role, :guest_expires_at ]
  end
end
