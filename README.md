# DEnCity Rails Application

## Development

Start Solr for JRuby using the command below.  You can check that Solr is running by going to `http://localhost:8983/solr`

```
bundle
jruby -S sunspot-solr run
```

In a separate console window call

```
rake sunspot:reindex
```



In a seperate terminal run `rails s`

## Docker deployment

1. `docker build -t nlong/dencity-1 .`
1. Test locally by calling `docker run -p 80:80 nlong/dencity-1`
1. Point browser to $DOCKER_HOST IP (if using boot2docker) (e.g. http://192.168.59.103)
1. If you are ready to deploy then make sure commit your changes locally.

1. Upload the Zip to EB

### Deploying to Elastic Beanstalk