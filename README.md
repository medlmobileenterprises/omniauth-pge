# OmniAuth PG&E

OmniAuth strategy for [PG&E's Share My Data](http://www.pge.com/en/myhome/addservices/sharemydata/vendor/testrequirements/index.page) using OAuth2.

[![Gem Version](https://badge.fury.io/rb/omniauth-pge.png)](https://rubygems.org/gems/omniauth-pge) [![Build Status](https://travis-ci.org/doomspork/omniauth-pge.svg?branch=master)](https://travis-ci.org/doomspork/omniauth-pge) [![Code Climate](https://codeclimate.com/github/doomspork/omniauth-pge/badges/gpa.svg)](https://codeclimate.com/github/doomspork/omniauth-pge) [![Coverage Status](https://coveralls.io/repos/doomspork/omniauth-pge/badge.png)](https://coveralls.io/r/doomspork/omniauth-pge) [![Dependency Status](https://gemnasium.com/doomspork/omniauth-pge.svg)](https://gemnasium.com/doomspork/omniauth-pge)

## Usage

Add the strategy to your `Gemfile` alongside OmniAuth:

```ruby
gem 'omniauth'
gem 'omniauth-pge'
```

Then integrate the strategy into your middleware:

```ruby
use OmniAuth::Builder do
  provider :pge, ENV['PGE_CLIENT_ID'], ENV['PGE_CLIENT_SECRET']
end
```

In Rails, you'll want to add to the middleware stack:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  keyString = File.read("/path/to/cert/key")
  cert = File.read("/path/to/cert/file")
  
  provider :pge, ENV['PGE_CLIENT_ID'], ENV['PGE_CLIENT_SECRET'], 
    {
      :client_options => {
        :connection_opts => {
          :ssl => {
            :client_key => OpenSSL::PKey::RSA.new(keyString),
            :client_cert => OpenSSL::X509::Certificate.new(cert)
          },
        },
        # if not supplied, will default to the test url
        :authorize_url => "production-url-here",
        # if not supplied, will default to the test url
        :token_url => "production-url-here",
      },
    }
end
```

For additional information, refer to the [OmniAuth wiki](https://github.com/intridea/omniauth/wiki).

## Contributing

Feedback, feature requests, and fixes are welcomed and encouraged.  Please make appropriate use of [Issues](https://github.com/doomspork/omniauth-pge/issues) and [Pull Requests](https://github.com/omniauth/pge_auth/pulls).  All code should have accompanying tests.

Be sure to familiarize yourself with the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Please see [LICENSE](LICENSE) for licensing details.
