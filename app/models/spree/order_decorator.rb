# Add product packages relation
Spree::Order.class_eval do
  has_many :order_packages, :dependent => :destroy

  accepts_nested_attributes_for :order_packages, :allow_destroy => true, :reject_if => lambda { |pp| pp[:weight].blank? or Integer(pp[:weight]) < 1 }

end
