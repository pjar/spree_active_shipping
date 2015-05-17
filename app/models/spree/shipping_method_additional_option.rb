module Spree
  class ShippingMethodAdditionalOption < ActiveRecord::Base

    belongs_to :shipping_method

    serialize :options_hash

  end
end
