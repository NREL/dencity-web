# DEnCity Rails Application

## Development

```
jruby -S sunspot-solr run
```

You can check that Solr is running by going to `http://localhost:8983/solr`

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

    ```
    export RAILS_ENV=production
    export BUNDLE_WITHOUT=development:test
    export BUNDLE_GEMFILE=Gemfile
    export GEM_HOME=gems
    java -classpath "lib/*" org.jruby.Main -S rake sunspot:reindex
    ```

    * Note that the schema.xml file that ships with Ubuntu's solr-tomcat does not work out of the box. I used https://raw.githubusercontent.com/sunspot/sunspot/master/sunspot_solr/solr/solr/conf/schema.xml