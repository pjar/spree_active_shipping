module Spree
  class ShippingMethodOptionsController < Spree::StoreController

    def show
      shipping_rate = ShippingRate.find_by(id: params[:shipping_rate_id])
      if shipping_rate
        shipping_method = shipping_rate.shipping_method
        opts = InpostShippingMethodOptionsService.new({shipping_method: shipping_method}).get_all_machines

        render json: prepare_machines_from(opts).to_json
      else
        render json: {error: 'error'}, status: :unprocessable_entity
      end
    end

    def prepare_machines_from(data)
      return nil unless data
      cities = []
      machines_by_city = {}
      data.each do |machine|
        cities << machine[:town]
        machines_by_city[machine[:town]] ||= []
        machines_by_city[machine[:town]] << machine
      end
      machines_by_city.each_value do |machines|
        machines.sort_by!{ |machine| machine[:street] }
      end
      {cities: cities.uniq.sort, machines: machines_by_city}
    end
  end
end
