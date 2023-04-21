# README

## Installation instructions

```
IF NOT DONE PREVIOUSLY: 

git clone git@github.com:karafka/karafka.git
cd karafka
docker-compose up


bundle install

And we can execute different instances, one per client:
ruby lib/socket.rb author=1
ruby lib/socket.rb author=2
```