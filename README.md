# DEnCity Rails Application

## Development

Make sure MongoDB is running 

```
# start with the following command
mongod
```

Start Solr for JRuby using the command below.  You can check that Solr is running by going to `http://localhost:8983/solr`

```
bundle
jruby -S sunspot-solr run
# or 
bundle exec sunspot-solr run
```

In a separate console  call

```
rake sunspot:reindex
```

In a separate console call

```
rails s
```

## Deployment with Docker and Docker-Compose

1. Install docker-compose (`brew install docker-compose` or https://docs.docker.com/compose/install/), docker (boot2docker)
1. Make sure that the mongodata and solrdata data containers exist:

    ```
    docker run -v /data/db --name mongodata busybox true
    docker run -v /opt/solr/example/solr/dencity/data --name solrdata busybox true
    ```

1. Run
    
    ```
    export DENCITY_HOST_URL = newsite.url.org
    
    # if you need email, then setup mailgun and add in your mailgun smtp user and api key
    export MAILGUN_SMTP_LOGIN = login (typically this is the domain)
    export MAILGUN_API_KEY = key
    export SECRET_KEY_BASE = 'a long secret key for the rails application'
    export DEVISE_SECRET_KEY = 'a long secret key for rails devise'
    
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
    * 
    * MAILGUN_SMTP_LOGIN = smtp_from_mailgun
    * MAILGUN_API_KEY = key_from_mailgun



