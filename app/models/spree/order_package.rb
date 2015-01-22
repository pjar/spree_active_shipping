module Spree
  class OrderPackage < ActiveRecord::Base
    belongs_to :order

  end
end
