Spree::Core::Engine.add_routes do
  namespace :admin do
    resource :active_shipping_settings, :only => ['show', 'update', 'edit']

    resources :orders, :only => [] do
      resources :order_packages
    end
  end
end
