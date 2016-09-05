FROM ruby:latest

ENV LANG C.UTF-8
RUN apt-get update -qq && apt-get install -yy build-essential libpq-dev nodejs npm mariadb-client postgresql-client
RUN gem update --system
RUN gem install bundler

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
