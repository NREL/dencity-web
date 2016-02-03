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
rake sunspot:mongo:reindex
```

In a separate console call

```
rails s
```

## Deployment with Docker and Docker-Compose

1. Install docker-compose (`brew install docker-compose` or https://docs.docker.com/compose/install/), docker-machine (brew install docker-machine)
2. 
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
    export SECRET_KEY_BASE = 'a long secret key for the rails application (use rake secret to generate key)'
    export DEVISE_SECRET_KEY = 'a long secret key for rails devise (use rake secret to generate key)'
    
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
    * JRUBY_OPTS=--server -J-Xms2048m -J-Xmx2048m -J-XX:+UseConcMarkSweepGC -J-XX:-UseGCOverheadLimit -J-XX:+CMSClassUnloadingEnabled
    * RAILS_ENV=production
    * SECRET_KEY_BASE='a long secret key for the rails application (use rake secret to generate key)'
    * DEVISE_SECRET_KEY='a long secret key for rails devise (use rake secret to generate key)'
    * MAILGUN_SMTP_LOGIN=smtp_from_mailgun
    * MAILGUN_API_KEY=key_from_mailgun


## Configuring Blank Ubuntu Box to Host DEnCity on AWS

* Create instance via AWS console
* Mount 500GB of EBS Storage for docker containers
* Launch instance
* Format and Mount Storage

    ```
    sudo -i
    mkfs -t ext4 /dev/xvdb
    mkdir /mnt/docker-data
    # Add /dev/xvdb /mnt/docker-data auto defaults,nobootwait,comment=cloudconfig 0 2 to /etc/fstab
    mount -a
    ```

* Install Docker, Python, and Supervisor
    Make sure to forward your keys to access Github.

    ```
    ssh -A ubuntu@<ip-address>
    sudo -i
    apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' >> /etc/apt/sources.list.d/docker.list
    apt-get update
    apt-get install -y docker-engine

    echo 'DOCKER_OPTS="-g /mnt/docker-data"' >> /etc/default/docker
    service docker restart
    usermod -aG docker ubuntu

    mkdir /var/www
    chown ubuntu.ubuntu /var/www

    apt-get install -y python-setuptools supervisor
    easy_install pip
    pip install docker-compose

    ```

    * create a new file for dencity keys
    vi /etc/profile.d/dencity.sh

    ```
    export DENCITY_HOST_URL=newsite.url.org
    export SECRET_KEY_BASE='Generate new secret key, use `rake secret`'
    export DEVISE_SECRET_KEY='Generate new secret key, use `rake secret`'
    # export MAILGUN_SMTP_LOGIN=login (typically this is the domain)
    # export MAILGUN_API_KEY=key
    export SMTP_ADDRESS=smtp.gmail.com
    export SMTP_PORT=587
    export SMTP_USERNAME=gmail_user@gmail.com
    export SMTP_PASSWORD=secure-password
    ```

    * Log out entirely, then in again

    ```
    ssh -A ubuntu@<ip-address>
    git clone git@github.com:NREL/dencity-web.git /var/www/dencity

    cd /var/www/dencity
    docker run -v /data/db --name mongodata busybox true
    docker run -v /opt/solr/example/solr/dencity/data --name solrdata busybox true
    docker-compose up

    # create new shell and populate the database
    ssh -A ubuntu@<ip-address>
    cd /var/www/dencity
    docker-compose run web bash
    rake db:mongoid:create_indexes
    rake db:seed # create test user with default password. Make sure to reset this password!
    rake populate:units

    ```

    * Add in the supervisor task after the site is verified to be working. Point browser to <ip-address:8080> to make
    sure the dencity site loads

    ```
    sudo -i
    cd /var/www/dencity
    cp docker/supervisor-dencity.conf /etc/supervisor/conf.d/dencity.conf
    supervisorctl reload
    supervisorctl start
    ```

    * Change admin user email and password. Log in as `test@nrel.gov` and `testing123`, then edit your account and update the email and password

    * To redeploy, simply restart supervisor task

    ```
    supervisorctl restart dencity
    ```










