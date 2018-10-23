class CreateRestrictedIps < ActiveRecord::Migration
  def change
    create_table :restricted_ips do |t|
      t.string :whitelisted_ip
      t.timestamps null: false
    end
  end
end
