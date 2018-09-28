class AddFullNameToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :full_name, :string
  end
end
