# README

## Installation instructions

```
git clone git@github.com:karafka/karafka.git
cd karafka

docker-compose up


bundle install
bundle exec rake client:websocket_request
Or we can execute different instances, one per client:
ruby lib/socket.rb author=1
ruby lib/socket.rb author=2
```