#!/bin/bash

# Dump
#mongodump -d dencity_development

# Restore ?
mongo dencity_development --eval "db.dropDatabase();"
mongorestore -d dencity_development dump/dencity_development



