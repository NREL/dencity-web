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

## Deployment

WARNING:  Asset Pipelines are not being precompiled.  They fall back and compile on
demand.  This needs to be fixed.

1. Run the following to clean out precompiled assets, compile, and war the app
 
    ```
    RAILS_ENV=production bundle exec rake assets:clobber
    RAILS_ENV=production bundle exec rake assets:precompile
    bundle exec warble war
    ```

1. Upload the WAR to AWS-EB
1. Note that if there still seems to be an issue with assets after deployed, then increment the asset version in the
production.rb file.  `config.assets.version = '1.1'`
1. If you need to reindex or run any rake tasks, then for now you need to manually SSH into one of the running EB instances
and execute the following
  * Note that the schema.xml file that ships with Ubuntu's solr-tomcat does not work out of the box. I used https://raw.githubusercontent.com/sunspot/sunspot/master/sunspot_solr/solr/solr/conf/schema.xml

    ```
    export RAILS_ENV=production
    export BUNDLE_WITHOUT=development:test
    export BUNDLE_GEMFILE=Gemfile
    export GEM_HOME=gems
    java -classpath "lib/*" org.jruby.Main -S rake sunspot:reindex
    ```

## Docker deployment

1. Re/Pre-compile assets if they changed. `rake assets:precompile RAILS_ENV=production`
1. `docker build -t nlong/dencity-1 .`
1. Test locally by calling `docker run -p 80:80 nlong/dencity-1`
1. Point browser to $DOCKER_HOST IP (if using boot2docker) (e.g. http://192.168.59.103)
1. If you are ready to deploy then make sure commit your changes locally.
1. If it works, then create a zip file `git archive --format=zip HEAD > deploy.zip`
    + Note that this will not upload the assets. So make sure to run `zip -9 -r deploy.zip public/assets/*` to add the assets to the upload
    ```
    rm -f deploy.zip
    git archive --format=zip HEAD > deploy.zip
    zip -9 -r deploy.zip public/assets/*
    ```

1. Upload the Zip to EB

Source code will be mounted at /srv