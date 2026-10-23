# Devise reads the same bcrypt hashes has_secure_password wrote, so the
# column only needs renaming - nobody has to reset their password.
class InstallDeviseOnUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :password_digest, :encrypted_password
    change_column_default :users, :encrypted_password, from: nil, to: ""
  end
end
