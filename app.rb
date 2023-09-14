require 'sinatra'
require 'omniauth-ebay-oauth'

use Rack::Session::Cookie

# OmniAuth disables starting authentication with GET request to mitigate CVE-2015-9284.
# For testing purposes we can enable it, but for production it is better to use POST with CSRF protection/
OmniAuth.config.allowed_request_methods += %i[get]

use OmniAuth::Builder do
  provider :ebay_oauth, 'Ferdinan-h2rliste-SBX-75d80d3bd-1abd6615', 'SBX-5d80d3bd8496-25cd-4205-825c-b2d7',
    callback_url: 'Ferdinando_Brit-Ferdinan-h2rlis-htgmdq', name: 'ebay'
end

get '/' do
  redirect '/auth/ebay'
end

get '/auth/ebay/callback' do
  "Hello, #{request.env['omniauth.auth'].dig('info', 'name')}"
end

# after oauth authentication is working correctly will need and example to send an api request and response
# per example this one: https://developer.ebay.com/api-docs/buy/browse/resources/item_summary/methods/search
# using the gem https://github.com/ebaymag/ebay_api
