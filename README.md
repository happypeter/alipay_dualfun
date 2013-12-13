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

- <https://github.com/chloerei/alipay> lots of code token from here
- <https://github.com/daqing/china_pay> for the initial idea


Generate payment url

    options = {
      :partner           => 'PID',
      :seller_email      => 'SELLER_EMAIL',
      :key               => 'SECRET',
      :out_trade_no      => 'YOUR_ORDER_ID',         # 20130801000001
      :subject           => 'YOUR_ORDER_SUBJECCT', 
      :price             => '10.00',
      :quantity          => 12,
      :return_url        => 'YOUR_ORDER_RETURN_URL', # 可选项
      :notify_url        => 'YOUR_ORDER_NOTIFY_URL'  # 可选项
    }

    Alipay.trade_create_by_buyer_url(options)     # 标准双接口
    # => 'https://mapi.alipay.com/gateway.do?out_trade_no=...'

NOTE: 以上除了标注`可选项`的内容之外，其他选项都是 Gem 要求的必填项，缺一不可。用户还可以根据自身特定需求添加可选项，具体可以参考支付宝官方资料包中的 pdf 文件。

Send Goods

    options = {
      :partner           => 'PID',
      :trade_no          => 'TRADE_NO',
      :logistics_name    => 'haoqicat course'
    }

    Alipay::Service.send_goods_confirm_by_platform(options)
    # => '<!xml version="1.0" encoding="utf-8"?><alipay><is_success>T</is_success></alipay>'

NOTE: `trade_no` is NOT `out_treade_no`
