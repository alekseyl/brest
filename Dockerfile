FROM ruby:3.3-bullseye

WORKDIR /app

EXPOSE 3000

RUN  apt-get update && apt-get -y install autoconf \
                                         automake \
                                         bison \
                                         build-essential \
                                         curl \
                                         ca-certificates \
                                         git-core \
                                         imagemagick \
                                         libc6-dev \
                                         libffi-dev \
                                         libgmp-dev \
                                         libpq-dev \
                                         libreadline6-dev \
                                         libssl-dev \
                                         libtool \
                                         libxml2-dev \
                                         libyaml-dev \
                                         lsb-release\
                                         ncurses-dev \
                                         nginx \
                                         openssl \
                                         wget \
                                         zlib1g \
                                         zlib1g-dev

#COPY Gemfil* /app/
#RUN  gem install bundler && bundle install
