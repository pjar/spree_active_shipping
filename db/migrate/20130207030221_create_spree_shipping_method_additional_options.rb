class CreateSpreeShippingMethodAdditionalOptions < ActiveRecord::Migration
  def change
    create_table :spree_shipping_method_additional_options do |t|
      t.references  :shipping_method
      t.text :options_hash
      t.timestamps
    end
  end
end
