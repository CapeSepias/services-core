FROM ruby:2.5.1-alpine

RUN set -x \
  && apk upgrade --no-cache \
  && apk add --no-cache --virtual build-dependencies \
    build-base libc-dev linux-headers tzdata\
    postgresql-dev postgresql-client openssl git
RUN apk add --no-cache build-base libxml2-dev libxslt-dev
RUN gem install nokogiri -v 1.12.5 --platform=ruby -- --use-system-libraries

RUN gem install bundler -v 2.2.27
ENV BUNDLER_VERSION=2.2.27

WORKDIR /app

ADD Gemfile /app
ADD Gemfile.lock /app
COPY . /app

RUN bundle install
