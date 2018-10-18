class CreateLoggedInIps < ActiveRecord::Migration
  def change
    create_table :logged_in_ips do |t|
      t.references :member, index: true, foreign_key: true
      t.string :ip_address
      t.string :token
      t.boolean :is_confirmed, default: false
      t.timestamps null: false
    end
  end
end
