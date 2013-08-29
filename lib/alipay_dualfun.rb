# encoding: utf-8
require 'cgi'
require 'open-uri'
require 'digest/md5'

module AlipayDualfun
  GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'
  CREATE_PARTNER_TRADE_BY_BUYER_REQUIRED_OPTIONS = %w( service partner _input_charset out_trade_no subject payment_type logistics_type logistics_fee logistics_payment seller_email price quantity )

  def self.trade_create_by_buyer_url(options = {})
    options = {
      'service'        => 'trade_create_by_buyer',
      '_input_charset' => 'utf-8',
      'payment_type'   => '1',
      'logistics_type'    => 'DIRECT',
      'logistics_fee'     => '0',
      'logistics_payment' => 'SELLER_PAY'
    }.merge(stringify_keys(options))

    @secret_key = options[:key]
    options.delete(:key)

    check_required_options(options, TRADE_CREATE_BY_BUYER_REQUIRED_OPTIONS)

    "#{GATEWAY_URL}?#{query_string(options)}"
  end

  def self.check_required_options(options, names)
    names.each do |name|
      warn("Ailpay Warn: missing required option: #{name}") unless options.has_key?(name)
    end
  end

  def self.stringify_keys(hash)
    new_hash = {}
    hash.each do |key, value|
      new_hash[(key.to_s rescue key) || key] = value
    end
    new_hash
  end

   def self.query_string(options)
      options.merge('sign_type' => 'MD5', 'sign' => generate_sign(options)).map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
   end

   def self.generate_sign(params)
     query = params.sort.map do |key, value|
       "#{key}=#{value}"
     end.join('&')

     Digest::MD5.hexdigest("#{query}#{@secret_key}")
   end
end
