FROM ubuntu
MAINTAINER Nicholas Long nicholas.long@nrel.gov

# Install Nginx.
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends openjdk-7-jre-headless tar curl git nginx imagemagick && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Install JRuby and Update Bundler
ENV JRUBY_VERSION 1.7.15
RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH
RUN echo gem: --no-document >> /etc/gemrc
RUN gem update --system
RUN gem install bundler

# TODO: create an image from the above code then use that image as the base.
# **Make sure NOT to publish this container as it contains the source code via the ADD command below**

# First upload the Gemfile* so that it can cache the Gems -- do this first because it is slow
WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install

# Configure the nginx server
ADD docker/nginx.conf /etc/nginx/sites-enabled/default

# Startup Script
ADD docker/start-server.sh /usr/bin/start-server
RUN chmod +x /usr/bin/start-server

# Bundle app source
ADD . /srv

WORKDIR /srv

# Call the start-server script as the default command
# When debugging you can use CMD so that you can override the command otherwise use ENTRYPOINT
CMD ["/usr/bin/start-server"]

# Expose ports.
EXPOSE 80