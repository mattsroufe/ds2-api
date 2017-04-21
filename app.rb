require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'googleauth'
require 'google-id-token'
require 'multi_json'

configure do
  client_secrets = MultiJson.load(File.read('.config/client_secrets.json'))['web']
  set :client_id, Google::Auth::ClientId.new(client_secrets['client_id'], client_secrets['client_secret'])
end

before do
  response['Access-Control-Allow-Origin'] = '*'
end

post('/signin') do
  audience = settings.client_id.id
  # Important: The google-id-token gem is not production ready. If using, consider fetching and
  # supplying the valid keys separately rather than using the built-in certificate fetcher.
  validator = GoogleIDToken::Validator.new
  claim = validator.check(params['id_token'], audience, audience)
  if claim
    content_type :json
    # session[:user_id] = claim['sub']
    # session[:user_email] = claim['email']
    MultiJson.dump(claim)
  else
    logger.info('No valid identity token present')
    401
  end
end

