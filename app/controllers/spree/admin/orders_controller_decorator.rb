Spree::Admin::OrdersController.class_eval do
  def order_packages
    @order = Spree::Order.find_by_number!(params[:id])
    @packages = @order.order_packages
    @order.order_packages.build
    
    respond_with(@object) do |format|
    format.html { render :layout => !request.xhr? }
      format.js { render :layout => false }
    end
  end
end
