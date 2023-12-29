class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.float :price, null: false
      t.float :quantity, null: false
      t.integer :order_type, null: false, default: 0
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
