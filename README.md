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

1. Install fig (`brew install fig` or http://www.fig.sh/install.html), docker (boot2docker)
1. Make sure that the mongodata and solrdata data containers exist:

    ```
    docker run -v /data/db --name mongodata busybox true
    docker run -v /opt/solr/example/solr/dencity/data --name solrdata busybox true
    ```

1. Run

    ```
    fig up

    # to populate db (first time only)
    fig run web bash
    rake populate:units RAILS_ENV=docker

    # point browser to boot2docker ip (or system ip) port 8080.
    ```

## Docker deployment

1. `docker build -t nlong/dencity-1 .`
1. Test locally by calling `docker run -p 80:80 nlong/dencity-1`
1. Point browser to $DOCKER_HOST IP (if using boot2docker) (e.g. http://192.168.59.103)
1. If you are ready to deploy then make sure commit your changes locally.

1. Upload the Zip to EB

## Deploying to Elastic Beanstalk