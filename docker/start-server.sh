#!/bin/bash
cd /srv
puma -C ./config/puma.rb
nginx