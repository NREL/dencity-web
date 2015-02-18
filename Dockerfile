FROM ubuntu
MAINTAINER Nicholas Long nicholas.long@nrel.gov

# Install JDK, nginx, and other libraries
RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends openjdk-7-jre-headless tar curl wget git nginx imagemagick && \
  rm -rf /var/lib/apt/lists/* && \
  echo "\ndaemon off;" >> /etc/nginx/nginx.conf && \
  chown -R www-data:www-data /var/lib/nginx

# Install JRuby and Update Bundler
ENV JRUBY_VERSION 1.7.19
RUN curl http://jruby.org.s3.amazonaws.com/downloads/$JRUBY_VERSION/jruby-bin-$JRUBY_VERSION.tar.gz | tar xz -C /opt
ENV PATH /opt/jruby-$JRUBY_VERSION/bin:$PATH
RUN echo gem: --no-document >> /etc/gemrc
RUN gem update --system
RUN gem install bundler

# **Make sure NOT to publish this container as it contains the source code via the ADD command below**

# First upload the Gemfile* so that it can cache the Gems -- do this first because it is slow
WORKDIR /srv
ADD Gemfile /srv/Gemfile
ADD Gemfile.lock /srv/Gemfile.lock
RUN bundle install

# Add the app assets and precompile assets. Do it this way so that when the app changes the assets don't
# have to be recompiled everytime
ADD Rakefile /srv/Rakefile
ADD /config/ /srv/config/
ADD /app/assets/ /srv/app/assets/

# Configure the nginx server
ADD docker/nginx.conf /etc/nginx/sites-enabled/default

# Startup Script
ADD docker/start-server.sh /usr/bin/start-server
RUN chmod +x /usr/bin/start-server

# Build the assets
# First add the users model to prevent the error with not finding the User
ADD /app/models/user.rb /srv/app/models/user.rb
# Now call precompile
RUN rake assets:precompile RAILS_ENV=production

# Bundle app source
ADD / /srv

# Call the start-server script as the default command
# When debugging you can use CMD so that you can override the command otherwise use ENTRYPOINT
CMD ["/usr/bin/start-server"]

# Expose ports.
EXPOSE 80