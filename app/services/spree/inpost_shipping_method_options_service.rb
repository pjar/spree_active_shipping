module Spree
  class InpostShippingMethodOptionsService

    attr_reader :inpost_client, :shipping_method

    def initialize(options={})
      @inpost_client = ActiveShipping::Inpost.new(
        login: options.fetch(:login) { 'test@testowy.pl' },
        password: options.fetch(:password) { 'WqJevQy*X7' }
      )
      @shipping_method = options.fetch(:shipping_method)
    end

    def get_all_machines
      opts = ShippingMethodAdditionalOption.find_by(shipping_method_id: self.shipping_method.id)
      opts and return opts.options_hash

      if self.shipping_method.code == 'inpost'
        fetched_options = self.inpost_client.get_all_machines
        ShippingMethodAdditionalOption.create(
          shipping_method_id: self.shipping_method.id,
          options_hash: fetched_options
        ).options_hash
      end
    end

  end
end
