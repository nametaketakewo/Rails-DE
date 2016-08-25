FROM rails:latest
#FROM ruby:latest

ENV LANG C.UTF-8
#RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs npm phantomjs
RUN gem install bundler

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
