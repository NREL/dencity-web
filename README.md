# DEnCity Rails Application



## Deployment

WARNING:  Asset Pipelines are not being precompiled.  They fall back and compile on
demand.  This needs to be fixed.

Run the following to clean out precompiled assets, compile, and war the app
```
RAILS_ENV=production bundle exec rake assets:clobber
RAILS_ENV=production bundle exec rake assets:precompile
bundle exec warble war
```