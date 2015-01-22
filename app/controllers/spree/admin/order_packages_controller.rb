module Spree
  module Admin
    class OrderPackagesController < ResourceController
      belongs_to 'spree/order', :find_by => :number
      before_filter :load_data

      private
        def load_data
          @order = Order.where(:number => params[:order_id]).first
        end

        def permitted_order_package_attributes
          [:length, :width, :height, :weight]
        end
    end
  end
end
