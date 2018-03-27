FROM ruby:2.5
MAINTAINER Andrii Ageiev <a.ageyev@gmail.com>

WORKDIR /opt/app
COPY ./server.rb /opt/app/server.rb
COPY ./healthcheck.sh /opt/app/healthcheck.sh

CMD ["/usr/bin/env", "ruby", "/opt/app/server.rb"]
