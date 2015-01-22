class Spree::ActiveShippingConfiguration < Spree::Preferences::Configuration

  preference :ups_login, :string, :default => ENV['UPS_LOGIN'] || "aunt_judy"
  preference :ups_password, :string, :default => ENV['UPS_PASSWORD'] || "secret"
  preference :ups_key, :string, :default => ENV['UPS_KEY'] || "developer_key"
  preference :shipper_number, :string, :default => ENV['UPS_SHIPPER_NUMBER']
  preference :shipper_name, :string, :default => ENV['UPS_SHIPPER_NAME'] || 'test'

  preference :units, :string, :default => "metric"
  preference :unit_multiplier, :decimal, :default => 16 # 16 oz./lb - assumes variant weights are in lbs
  preference :default_weight, :integer, :default => 0 # 16 oz./lb - assumes variant weights are in lbs
  preference :handling_fee, :integer
  preference :max_weight_per_package, :integer, :default => 0 # 0 means no limit

  preference :test_mode, :boolean, :default => false
end
