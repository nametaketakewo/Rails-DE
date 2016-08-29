
ENV LANG C.UTF-8
RUN gem update --system
RUN gem install bundler

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
