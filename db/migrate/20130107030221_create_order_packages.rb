class CreateOrderPackages < ActiveRecord::Migration
  def change
    create_table :spree_order_packages do |t|
      t.integer "order_id",                :null => false
      t.integer "length",     :default => 0, :null => false
      t.integer "width",      :default => 0, :null => false
      t.integer "height",     :default => 0, :null => false
      t.integer "weight",     :default => 0, :null => false
      t.timestamps
    end
  end
end
