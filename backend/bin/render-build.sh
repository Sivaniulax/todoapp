#!/usr/bin/env bash
# Render runs this on every deploy (see render.yaml).
set -o errexit

bundle install
bundle exec rails db:migrate
bundle exec rails db:seed
