# alipay_dualfun 双功能收款

A ruby gem.

## Demo

http://alidemo.happycasts.net/

## Install

Add this line to your application's Gemfile:

    gem 'alipay_dualfun'


or development version

    gem 'alipay_dualfun', :github => 'happypeter/alipay_dualfun'

And then execute:

    $ bundle

### Thanks

- <https://github.com/chloerei/alipay>
- <https://github.com/daqing/china_pay>


Generate payment url

    options = {
      :out_trade_no      => 'YOUR_ORDER_ID',         # 20130801000001
      :subject           => 'YOUR_ORDER_SUBJECCT', 
      :partner           => 'PID',
      :seller_email      => 'SELLER_EMAIL',
      :price             => '10.00',
      :quantity          => 12,
      :discount          => '20.00'
      :return_url        => 'YOUR_ORDER_RETURN_URL',
      :notify_url        => 'YOUR_ORDER_NOTIFY_URL'
    }

    Alipay.trade_create_by_buyer_url(options)     # 标准双接口
    # => 'https://mapi.alipay.com/gateway.do?out_trade_no=...'

You can redirect user to this payment url, and user will see a payment page
for his/her order.

