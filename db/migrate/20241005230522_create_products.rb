class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :unit_price, null: false
      t.string :description, null: false
      t.datetime :discarded_at, index: { where: 'discarded_at IS NULL' }

      t.timestamps
    end
  end
end
