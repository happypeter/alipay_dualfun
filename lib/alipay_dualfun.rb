# encoding: utf-8
require 'digest'
require 'uri'
require 'net/http'

module AlipayDualfun
  GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

  module Product
    class Base
      DEFAULT_CHARSET = 'utf-8'
      SIGN_TYPE_MD5 = 'MD5'

      # all the 'required` field from offical SDK pdf
      ATTR_REQUIRED = [:service, :partner, :_input_charset,
        :sign_type, :sign, :notify_url, :return_url,
        :out_trade_no, :subject, :payment_type, :seller_email,
        :logistics_type, :logistics_fee, :logistics_payment,
        :price, :quantity
      ]
    end

    class DualfunPay < Base
      NAME = '双功能收款'
      SERVICE_LABEL = :trade_create_by_buyer

      def initialize(order)
        @order = order
        @params = {}
      end

      def notification_callback_url(url)
        @params[:notify_url] = url
        self
      end

      def after_payment_redirect_url(url)
        @params[:return_url] = url
        self
      end

      def gateway_api_url
        secure_signature = create_signature
        request_params = sign_params.merge(
          :sign_type => SIGN_TYPE_MD5,
          :sign => secure_signature
        )

        lost_attributes = ATTR_REQUIRED - request_params.keys
        if lost_attributes.any?
          raise "the following keys are lost: #{lost_attributes.inspect}"
        end

        uri = URI(GATEWAY_URL)
        uri.query = URI.encode_www_form(request_params.sort)

        uri.to_s
      end

      # 出错通知异步调用 URL
      #
      # NOTE: 需要联系技术支持才能开通
      def error_callback_url(url)
        @params[:error_notify_url] = url
        self
      end

      private

      def sign_params
        params = @order.attributes.merge(@params)
        params[:service] = SERVICE_LABEL
        params[:partner] = @order.merchant.partner
        params[:_input_charset] = DEFAULT_CHARSET
        @sign_params ||= params
      end

      def create_signature
        sequence = sign_params.sort.map {|k, v| "#{k}=#{v}"}.join('&')
        Digest::MD5.hexdigest(sequence + @order.merchant.key)
      end
    end
  end

  class Order
    PAYMENT_TYPE_BUYING = 1

    attr_accessor :merchant
    attr_reader :attributes

    def initialize(order_id, subject, description)
      @attributes = {
        :out_trade_no => order_id,
        :subject => subject,
        :body => description }

        @attributes[:payment_type] = PAYMENT_TYPE_BUYING
    end

    def seller_email(email)
      @attributes[:seller_email] = email
      self
    end


    def set_price_and_quantity(price, quantity)
      @attributes[:price] = price
      @attributes[:quantity] = quantity
      self
    end

    def buyer_email(email)
      @attributes[:buyer_email] = email
      self
    end

    #收银台页面上,商品展示的超链接。
    def product_url(url)
      @attributes[:show_url] = url
      self
    end

    def set_logistics(type, payment, fee)
      @attributes[:logistics_type] = type
      @attributes[:logistics_payment] = payment
      @attributes[:logistics_fee] = fee
      self
    end

    # set to 0, for virtaul goods with no delivery
    def no_logistics
      @attributes[:logistics_type] = 'POST'
      @attributes[:logistics_payment] = 'BUYER_PAY'
      @attributes[:logistics_fee] = '0'
      self
    end

    def dualfun_pay
      Product::DualfunPay.new(self)
    end

  end

  class Merchant
    attr_accessor :partner, :key

    def initialize(partner, key)
      @partner = partner
      @key = key
    end

    def create_order(order_id, subject, description)
      order = Order.new(order_id, subject, description)
      order.merchant = self
      order
    end
  end

  class Notification
    def initialize(partner, notification_id)
      @partner = partner
      @notification_id = notification_id
    end

    def valid?
      uri = URI(GATEWAY_URL)
      params = {
        :service => :notify_verify,
        :partner => @partner,
        :notify_id => @notification_id
      }
      uri.query = params.map {|k, v| "#{k}=#{URI.escape(v.to_s)}"}.join('&')

      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        req = Net::HTTP::Get.new uri.request_uri

        response = http.request(req)
        response.body == 'true'
      end
    end
  end
end

