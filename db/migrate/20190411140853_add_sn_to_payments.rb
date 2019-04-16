class AddSnToPayments < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :sn, :integer
  end
end
