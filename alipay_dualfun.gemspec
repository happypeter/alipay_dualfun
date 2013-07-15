# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "alipay_dualfun"
  gem.version       = "0.0"
  gem.authors       = ["happypeter"]
  gem.email         = ["happypeter1983@gmail.com"]
  gem.description   = %q{This gem can help you integrate Alipay to your application.}
  gem.summary       = %q{A simple payment library for alipay dual function payment gateways}
  gem.homepage      = "https://github.com/happypeter/alipay_dualfun"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
