# DEnCity Rails Application

## Development

Start Solr for JRuby using the command below.  You can check that Solr is running by going to `http://localhost:8983/solr`

```
bundle
jruby -S sunspot-solr run
```

In a separate console  call

```
rake sunspot:reindex
```

In a separate console call

```
rails s
```

## Development using Docker

If desired, it is possible to run the database (MongoDB) and Solr as docker containers on your local machine.

1. Install boot2docker if the machine is Mac OSX or Windows. Make sure it is running `boot2docker start`.
1. Pull down the MongoDB Docker Image `docker pull dockerfile/mongodb`
1. Pull down the Apache Solr Docker Image `docker pull makuk66/docker-solr`
1. To build the app for the first time run the following:

    ```
    cd <project_root_directory>

    # create data volume and run the mongodb container
    docker run -v /data/db --name mongodata busybox true
    docker run -it -d --name dencity_mongo -p 27017:27017 --volumes-from mongodata dockerfile/mongodb

    # build the solr container
    cd solr
    docker build -t dencity-solr .
    cd ..

    # run the solr container. Not sure how the index is persisted after removing the container
    docker run -v /opt/solr/example/solr/dencity/data --name solrdata busybox true
    docker run -it -d --name dencity_solr -p 8983:8983 --volumes-from solrdata dencity-solr

    # build the dencity container
    docker build -t dencity-web .

    # run the dencity container
    docker run -it -d --name dencity_web -p 8080:80 --link dencity_mongo:db --link dencity_solr:solr dencity-web

    # enter the dencity_web container and populate some data
    docker exec -it dencity_web /bin/bash
    rake populate:units RAILS_ENV=docker
    ```

1. To start the app, run the following

    ```
    docker run -it -d --name dencity_mongo -p 27017:27017 --volumes-from mongodata dockerfile/mongodb
    docker run -it -d --name dencity_solr -p 8983:8983 --volumes-from solrdata dencity-solr
    docker run -it -d --name dencity_web -p 8080:80 --link dencity_mongo:db --link dencity_solr:solr dencity-web
    ```

## Development with Docker and Fig

1. Install docker-compose (`brew install docker-compse` or https://docs.docker.com/compose/install/), docker (boot2docker)
1. Make sure that the mongodata and solrdata data containers exist:

    ```
    docker run -v /data/db --name mongodata busybox true
    docker run -v /opt/solr/example/solr/dencity/data --name solrdata busybox true
    ```

1. Run

    
    ```
    export DENCITY_HOST_URL = newsite.url.org
    
    # if you need email, then setup mailgun and add in your mailgun smtp user and api key
    export MAILGUN_SMTP_LOGIN = login
    export MAILGUN_API_KEY = key
    
    docker-compose up

    # to populate db (first time only)
    docker-compose run web bash
    rake db:mongoid:create_indexes
    rake db:seed # create test user with default password. Make sure to reset this password!
    rake populate:units

    # point browser to boot2docker ip (or system ip) port 8080.
    ```

## Deployment with AWS ElasticBeanstalk

These instructions only work with Docker on AWS' ElasticBeanstalk (EB) Environment. 
 
1. Make sure you commit your changes locally (EB will use your current Github commit)
1. Setup Python (use brew), pip, [EB cli](http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-getting-set-up.html) and [AWS cli](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html)
1. Set the in the Dockerfile and the /config/puma.rb (this should already be done)
1. eb create NAME_OF_ENVIRONMENT or eb deploy NAME_OF_ENVIRONMENT.  *Note elastic beanstalk environments are specified here: https://github.com/NREL/cofee-rails/blob/develop/.elasticbeanstalk/config.yml*
1. Note that you must set a few environment variables for the EB environment
    * JRUBY_OPTS = --server -J-Xms1024m -J-Xmx1500m -J-XX:+UseConcMarkSweepGC -J-XX:-UseGCOverheadLimit -J-XX:+CMSClassUnloadingEnabled
    * RAILS_ENV = production
    * MAILGUN_SMTP_LOGIN = smtp_from_mailgun
    * MAILGUN_API_KEY = key_from_mailgun
1. Redeploy if the environment variables have changed



