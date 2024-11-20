class CreateCartProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :cart_products do |t|
      t.belongs_to :cart, null: false
      t.belongs_to :product, null: false
      t.integer :quantity, null: false, default: 1

      t.timestamps
    end

    add_index :cart_products, %i[cart_id product_id], unique: true
  end
end
