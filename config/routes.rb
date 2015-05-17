Spree::Core::Engine.add_routes do
  
  resources :shipping_rates do
    resource :shipping_method_options, only: [:show]
  end

  namespace :admin do
    resource :active_shipping_settings, :only => ['show', 'update', 'edit']

    resources :orders, :only => [] do
      resources :order_packages
    end
  end
end
