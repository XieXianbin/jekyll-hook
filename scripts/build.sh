#!/bin/bash
set -e

# This script is meant to be run automatically
# as part of the jekyll-hook application.
# https://github.com/developmentseed/jekyll-hook

repo=$1
branch=$2
owner=$3
giturl=$4
source=$5
build=$6

# Check to see if repo exists. If not, git clone it
if [ ! -d $source ]; then
    git clone $giturl $source
fi

# Git checkout appropriate branch, pull latest code
cd $source
git checkout $branch
git pull origin $branch
cd -

# Run jekyll
cd $source
[ -f Gemfile ] && (bundle check || bundle install)
bundle exec jekyll build -s $source -d $build
cd -

# configure and restart/reload nginx
if [[ ! -f "/etc/nginx/conf.d/$repo.conf" ]]; then
  cp -rf /root/REPO_NAME_GITHUB_IO.conf /etc/nginx/conf.d/$repo.conf
  sed -i "s/REPO_NAME_GITHUB_IO/${repo}/g" /etc/nginx/conf.d/$repo.conf
  service nginx restart
fi
