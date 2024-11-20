class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.belongs_to :user, null: false, type: :uuid
      t.datetime :abandoned_at, index: { where: 'abandoned_at IS NOT NULL' }

      t.timestamps
    end
  end
end
