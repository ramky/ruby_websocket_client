#require 'socket'        # Sockets are in standard library
require 'rest-client'

URL = 'http://localhost:3000'
PATH = 'authenticate'
USER = 'f@tela.com'
PSSW = '1234'
PARAMS1 = {params: {'email': 'f@tela.com', 'password': '1234'}}
PARAMS =  {'email': 'f@tela.com', 'password': '1234'}

def get_token2
  response = RestClient.post "#{URL}/#{PATH}", PARAMS1
  results = JSON.parse(response.to_str)
end

def get_token
  response = RestClient::Request.new(
    :method => :get,
    :url => "#{URL}/#{PATH}",
    :user => USER,
    :password => PSSW,
    :headers => { :accept => :json, :content_type => :json }
  ).execute
  results = JSON.parse(response.to_str)
end

token = get_token2