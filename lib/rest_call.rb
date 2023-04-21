class RestCall
  require 'rest-client'
  require 'json'

  URL = 'http://localhost:3000'
  PATH = 'authenticate'
  PATHB = 'broadcast'
  PARAMS =  {'email': 'f@tela.com', 'password': '1234'}
  # TEST to bypass SSL verification.
  #PARAMS =  {'email': 'f@tela.com', 'password': '1234', verify_ssl: OpenSSL::SSL::VERIFY_NONE}

  attr_reader :token
  attr_accessor :author_id
  attr_reader :uuid

  def initialize()
  end

  def get_token
    response = RestClient.post "#{URL}/#{PATH}", PARAMS
    results = JSON.parse(response.to_str)
    @token = results['auth_token']
  end

  def send(uuid = @uuid)
    if !uuid.nil? && uuid.length > 0
      @uuid = uuid
    end
    response = RestClient::Request.execute(
      :method => :get,
      :url => "#{URL}/#{PATHB}" + '/' + @uuid,
      :headers => {'Authorization' => @token}
    )
    results = JSON.parse(response.to_str)
    puts results
  end
end