class AuthSocket
  require 'rest-client'
  require 'json'

  URL = 'http://localhost:3000'
  PATH = 'authenticate'
  USER = 'f@tela.com'
  PSSW = '1234'
  PARAMS =  {'email': 'f@tela.com', 'password': '1234'}
  #token = ''
  attr_reader :token

  def initialize
    response = RestClient.post "#{URL}/#{PATH}", PARAMS
    results = JSON.parse(response.to_str)
    @token = results['auth_token']
  end

  def get_token_tmp
    response = RestClient::Request.new(
      :method => :get,
      :url => "#{URL}/#{PATH}",
      :user => USER,
      :password => PSSW,
      :headers => { :accept => :json, :content_type => :json }
    ).execute
    results = JSON.parse(response.to_str)
  end

  #token = get_token
  #puts(token)
end