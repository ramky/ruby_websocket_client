class RestCall
  require 'rest-client'
  require 'json'

  URL = 'http://localhost:3000'
  PATH = 'authenticate'
  PATHB = 'broadcast'
  USER = 'f@tela.com'
  PSSW = '1234'
  PARAMS =  {'email': 'f@tela.com', 'password': '1234'}
  #token = ''
  attr_reader :token
  attr_reader :client_id

  def initialize(client_id)
    @client_id = client_id
    # response = RestCall.post "#{URL}/#{PATH}", PARAMS
    # results = JSON.parse(response.to_str)
    # @token = results['auth_token']
  end

  def get_token
    response = RestClient.post "#{URL}/#{PATH}", PARAMS
    results = JSON.parse(response.to_str)
    @token = results['auth_token']
  end

  def send(uuid)
    response = RestClient::Request.execute(
      :method => :get,
      :url => "#{URL}/#{PATHB}" + '/' + uuid,
      :params => uuid,
      :headers => {'Authorization' => @token}
    )
    results = JSON.parse(response.to_str)
    puts results
  end

  #token = get_token
  #puts(token)
end