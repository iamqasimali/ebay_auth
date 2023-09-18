require 'sinatra'
require 'omniauth-ebay-oauth'
require 'json'
require "faraday"
require 'dotenv'
require 'base64'
require 'cgi'
require 'pry'
require 'pry-remote'

Dotenv.load

use Rack::Session::Cookie

set :root, File.dirname(__FILE__)
set :public_folder, 'public'
set :port, 3000

# OmniAuth disables starting authentication with GET request to mitigate CVE-2015-9284.
# For testing purposes we can enable it, but for production it is better to use POST with CSRF protection/
OmniAuth.config.allowed_request_methods += %i[get]
# OmniAuth.config.silence_get_warning = true



use OmniAuth::Builder do
  provider :ebay_oauth, 'Ferdinan-h2rliste-SBX-75d80d3bd-1abd6615', 'SBX-5d80d3bd8496-25cd-4205-825c-b2d7',
    callback_url: 'Ferdinando_Brit-Ferdinan-h2rlis-htgmdq', name: 'ebay'
end

get '/' do
  erb :index  # This will render the 'views/index.erb' template
end

get '/ebay_auth' do
  redirect '/auth/ebay'
end

get '/auth/ebay/callback' do
  "Hello, #{request.env['omniauth.auth'].dig('info', 'name')}"
end


get '/ebay_webhook_response' do
  # Parse the params and get code from the request params
  # Generate a new Post request to get User Auth token
  #Exchanging the authorization code for a User access token
  # https://developer.ebay.com/api-docs/static/oauth-auth-code-grant-request.html
  # Your URL-encoded string
  url_encoded_string = params[:code]
  # url_encoded_string = "v%5E1.1%23i%5E1%23r%5E1%23f%5E0%23I%5E3%23p%5E3%23t%5EUl41XzEwOkQ2ODZBNzI0MDJCMUYzQ0ZDMTNDQkQwQTM4OUQ0MkI2XzBfMSNFXjEyODQ%3D"

  # Decode the URL-encoded string
  decoded_code_string = CGI.unescape(url_encoded_string)

  # Define the eBay API URL
  url = 'https://api.sandbox.ebay.com/identity/v1/oauth2/token'
  
  credentials = "#{ENV['Client_ID']}:#{ENV['Client_Secret']}"

  # Encode the credentials in Base64
  encoded_credentials = Base64.strict_encode64(credentials)
  authorization_header = "Basic #{encoded_credentials}"  

  # Define the request headers
  headers = {
    'Content-Type' => 'application/x-www-form-urlencoded',
    'Authorization' => authorization_header
  }
  
  # Define the request parameters as a hash
  params = {
    grant_type: 'authorization_code',
    code: decoded_code_string,
    redirect_uri: ENV['RuName']
  }
  
  # Create a Faraday connection
  conn = Faraday.new(url: url, headers: headers)
  
  # Make a POST request with the parameters
  response = conn.post do |req|
    req.body = URI.encode_www_form(params)
  end
  
  # Print the response
  puts response.body
  
  # Presever the User access token somewhere in the file

end

get '/refersh_token' do 
  
  # https://developer.ebay.com/api-docs/static/oauth-refresh-token-request.html

  url = 'https://api.sandbox.ebay.com/identity/v1/oauth2/token'
  
  # Construct the credentials string and encode it in Base64
  credentials = "#{ENV['Client_ID']}:#{ENV['Client_Secret']}"
  encoded_credentials = Base64.strict_encode64(credentials)

  # Create the authorization header
  authorization_header = "Basic #{encoded_credentials}"

  # Define the request headers
  headers = {
    'Content-Type' => 'application/x-www-form-urlencoded',
    'Authorization' => authorization_header
  }

  # Define the request parameters as a hash
  params = {
    grant_type: 'authorization_code',
    refresh_token: decoded_code_string, # Replace with your actual code
    redirect_uri: ENV['RuName']
  }

  # Create a Faraday connection
  conn = Faraday.new(url: url, headers: headers)

  # Make a POST request with the parameters
  response = conn.post do |req|
    req.body = URI.encode_www_form(params)
  end

  # Print the response
  puts response.body
  
end


# after oauth authentication is working correctly will need and example to send an api request and response
# per example this one: https://developer.ebay.com/api-docs/buy/browse/resources/item_summary/methods/search
# using the gem https://github.com/ebaymag/ebay_api

