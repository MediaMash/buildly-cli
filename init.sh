#!/bin/bash
# init
figlet buildly
echo -n "Buildy Core configuratioin tool, what type of app are building? [F/f] Fast and lightweight or [S/s] Scaleable and feature rich?"
read answer

if [ "$answer" != "${answer#[Ss]}" ] ;then
    echo "Cloning Buildly Core"
    git clone git@github.com:buildlyio/buildly-core.git

    echo -n "Would you like to Manage Users with Buildly? Yes [Y/y] or No [N/n]"
    read users

    # cp config file to make changes
    # this should have 4 config files (1 with all modules base.py, 1 with Templates and Mesh, and 1 with just Template, and 1 with just Mesh)
    # then the Mesh should just be an option
    cp buildly-core/buildly/settings/base.py buildly-core/buildly/settings/base-buildly.py

    if [ "$users" != "${users#[Nn]}" ] ;then
        sed 's/users//g' buildly-core/buildly/settings/base-buildly.py > buildly-core/buildly/settings/base-buildly.py
    fi

    echo -n "Would you like to use Templates to manage reuseable workflows with Buildly? Yes [Y/y] or No [N/n]"
    read templates

    if [ "$templates" != "${templates#[Nn]}" ] ;then
        sed 's/workflow//g' buildly-core/buildly/settings/base-buildly.py > buildly-core/buildly/settings/base-buildly.py
    fi
    echo -n "Would you like to enable the data mesh functions? Yes [Y/y] or No [N/n]"
    read mesh

    if [ "$mesh" != "${mesh#[Nn]}" ] ;then
        sed 's/datamesh//g' buildly-core/buildly/settings/base-buildly.py > buildly-core/buildly/settings/base-buildly.py
    fi
fi

# set up application and services
mkdir YourApplication
mv buildly-core YourApplication/
mkdir YourApplication/services

echo -n "Would you like to import a service from the marketplace? Yes [Y/y] or No [N/n]"
read service_answer2

if [ "$service_answer2" != "${service_answer2#[Yy]}" ] ;then
  # list marketplace open source repost
  curl -s https://api.github.com/orgs/Buildly-Marketplace/repos?per_page=1000 | grep git_url |awk '{print $2}'| sed 's/"\(.*\)",/\1/'

  # clone all repositories
  for repo in `curl -s https://api.github.com/orgs/Buildly-Marketplace/repos?per_page=1000 |grep git_url |awk '{print $2}'| sed 's/"\(.*\)",/\1/'`;do
    remove="git://github.com/Buildly-Marketplace/"
    name=${repo//$remove/}
    echo -n "Would you like to clone and use " $name " from the marketplace? Yes [Y/y] or No [N/n]"
    read service_answer3

    if [ "$service_answer3" != "${service_answer3#[Yy]}" ] ;then
      git clone $repo YourApplication/services/$name;
    fi
  done;
fi

echo -n "Now... would you like to create a new service from scratch? Yes [Y/y] or No [N/n]"
read service_answer

if [ "$service_answer" != "${service_answer#[Yy]}" ] ;then
  cd django-service-wizard
  # create a new service use django-service-wizard for now
  docker-compose run --rm django_service_wizard -u $(id -u):$(id -g) -v "$(pwd)":/code
fi

cd ../YourApplication

echo "Buildly services cloned and ready for configuration"

ls -l