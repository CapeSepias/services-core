class CreatePaymentRequests < ActiveRecord::Migration
  def change
    create_table :payment_requests, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :billing_address, null: false, foreign_key: { references: :addresses }

      t.decimal :total_amount, null: false, precision: 10, scale: 2
      t.string :payment_method, null: false
      t.integer :installments_count, null: false
      t.string :state, null: false

      t.string :gateway_card_id, foreign_key: false
      t.string :gateway_card_hash
      t.decimal :gateway_fee, precision: 10, scale: 2, default: 0

      t.timestamps null: false
    end
  end
end