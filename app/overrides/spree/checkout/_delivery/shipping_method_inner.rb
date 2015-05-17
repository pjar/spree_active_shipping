Deface::Override.new(virtual_path: 'spree/checkout/_delivery',
                     name: 'delivery_method_options',
                     insert_bottom: '[data-hook="shipping_method_inner"]',
                     partial: 'spree/checkout/_delivery/delivery_method_options_section')
