module Spree
  module ActiveShipping
    class Inpost < ActiveMerchant::Shipping::Carrier

      self.retry_safe = false
      cattr_accessor :default_options
      cattr_reader :name
      @@name = 'Inpost'

      # Url for testing is the same - the are credentials for test accounts
      LIVE_URL = 'http://api.paczkomaty.pl'

      RESOURCES = {
        cancel_pack: '?do=cancelpack',
        create_delivery_packs: '?do=createdeliverypacks',
        find_nearest_machines: '?do=findnearestmachines',
        get_sticker: '?do=getsticker',
        get_stickers: '?do=getstickers',
        get_confirm_printout: '?do=getconfirmprintout',
        get_pack_status: '?do=getpackstatus',
        list_machines: '?do=listmachines_xml',
        pricelist: '?do=pricelist', 
        set_customer_ref: '?do=setcustomerref'
      }

      DEFAULT_SERVICES = {
        'STANDARD' => 'STANDARD',
        'PASS_THRU' => 'PASS_THRU'
      }

      def requirements
        [:login, :password]
      end

      def find_rates(origin, destination, packages, options={})
        response = fetch(:pricelist) 
        parse_rate_response(origin, destination, packages, response)
      end

      def parse_rate_response(origin, destination, packages, response)
        xml = build_document(response, 'paczkomaty')
        success = response_success?(xml)
        message = response_message(xml)

        if success
          rate_estimates = xml.root.css('service').map do |service|
            service_name = service.css('serviceName')
            ::ActiveMerchant::Shipping::RateEstimate.new(origin, destination, @@name, service_name,
                                                         total_price: service.css('packType price')[2].text,
                                                         insurance_price: xml.root.at('insurance price').text,
                                                         currency: 'PLN',
                                                         service_code: service_name,
                                                         packages: packages,
                                                         negotiated_rate: service.css('packType price')[1].text
                                                        )
          end
        end
        ::ActiveMerchant::Shipping::RateResponse.new(success, message, Hash.from_xml(response), rates: rate_estimates, xml: response, request: last_request)
      end

      def create_shipment(origin, destination, packages, options = {})
        options = @options.merge(options) 
        packages = Array(packages)


        
        response = commit(:create_delivery_packs, (build_shipment_request(origin, destination, packages, options)))
      end

      def build_shipment_request(origin, destination, packages, options = {})
        data = access_data
        data.merge(content: xml_for_packages(origin, destination, packages, options))
      end

      def xml_for_packages(origin, destination, packages, options = {})
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.paczkomaty do
            xml.autoLabels true
            xml.selfSend false
            packages.each do |package|
              xml.pack do
                xml.id                          [origin.name, options[:order_number]].join(' - ')
                xml.adreseeEmail                destination.email
                xml.senderEmail                 origin.email
                xml.phoneNum                    destination.phone
                xml.boxMachineName              destination.name
                xml.alternativeBoxMachineName   options[:alt_machine_name]
                xml.senderBoxMachineName        options[:sender_machine_name]
                xml.insuranceAmount             options[:insurance_amount]
                xml.onDeliveryAmount            options[:on_delivery_amount]
                xml.customerRef                 options[:reference]
                xml.senderAddress do
                  xml.name        origin.name
                  #xml.surName     options[:sender_surname]
                  xml.email       origin.email
                  xml.phoneNum    origin.phone
                  xml.street      origin.address1
                  #xml.buildingNo  origin.address2
                  #xml.flatNo      origin.address3
                  xml.town        origin.city
                  xml.zipCode     origin.postal_code
                  xml.province    origin.state
                end
              end
            end
          end
        end

        xml_builder.to_xml
      end

      def access_data
        {
          email: @options[:login],
          password: @options[:password]
        }
      end


      def get_all_machines
        response = fetch(:list_machines)
        parse_machines_response(response, true)
      end

      def find_nearest_machines(postcode, options = {})
        query_params = {
          postcode: postcode.gsub(' ','')
        }
        query_params.merge!(paymentavailable: (options[:terminal_available] ? 't' : 'f')) unless options[:terminal_available].blank?

        response = fetch(:find_nearest_machines, query_params: query_params)
        parse_machines_response(response, false)

      end

      def parse_machines_response(response, extended_params = false)
        xml = Nokogiri::XML(response)
        success = response_success?(xml)
        message = response_message(xml)

        machines = []
        if success
          xml_machines = xml.css('machine')
          unless xml_machines.empty?
            xml_machines.each do |item|
              machine = {
                name:                 item.css('name').text,
                postcode:             item.css('postcode').text,
                street:               item.css('street').text,
                buildingnumber:       item.css('buildingnumber').text,
                town:                 item.css('town').text,
                latitude:             item.css('latitude').text,
                longitude:            item.css('longitude').text,
                locationdescription:  item.css('locationdescription').text,
                paymenttype:          item.css('paymenttype').text
              }
              if extended_params
                machine.merge!({
                  type:                   item.css('type').text,
                  province:               item.css('province').text,
                  paymentavailable:       item.css('paymentavailable').text,
                  status:                 item.css('status').text,
                  operatinghours:         item.css('operatinghours').text,
                  paymentpointdescr:      item.css('paymentpointdescr').text,
                  parterid:               item.css('partnerid').text,
                  locationdescription2:   item.css('locationdescription2').text,
                })
              else
                machine.merge!(distance: item.css('distance').text)
              end
              machines << machine
            end
          end
        end

        machines
      end

      def response_success?(document)
        document.css('error').empty?
      end

      def response_message(document)
        document.css('error').text
      end

      def fetch(action, options={})
        url = "#{LIVE_URL}/#{RESOURCES[action]}"
        url << build_http_query(options.delete(:query_params))
        headers = options.fetch(:headers, {'Content-Type' => 'application/x-www-form-urlencoded'})
        ssl_get(url, headers)
      end

      def commit(action, request)
        ssl_post("#{LIVE_URL}/#{RESOURCES[action]}", request)
      end

      def build_http_query(query_params)
        return '' unless query_params.is_a?(Hash)
        params = []
        query_params.each do |key, value|
          params << "&#{Rack::Utils.escape(key)}=#{Rack::Utils.escape(value)}"
        end
        params.join
      end

      def build_document(xml, expected_root_tag)
        document = Nokogiri.XML(xml)
        if document.root.nil? || document.root.name != expected_root_tag
          raise ActiveShipping::ResponseContentError.new(StandardError.new('Invalid document'), xml)
        end
        document
      rescue Nokogiri::XML::SyntaxError => e
        raise ActiveShipping::ResponseContentError.new(e, xml)
      end

      def digest
        @digest ||= Base64.encode64(Digest::MD5.digest(@options[:password])).chomp
      end

    end
  end
end

