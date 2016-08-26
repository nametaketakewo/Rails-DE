# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.provider 'virtualbox' do |v|
    v.memory = 2048
    v.cpus = 2
    v.gui = false
    v.customize [
      'modifyvm', :id,
      '--hwvirtex', 'on',
      '--nestedpaging', 'on',
      '--largepages', 'on',
      '--ioapic', 'on',
      '--pae', 'on',
      '--paravirtprovider', 'kvm',
      '--natdnsproxy1', 'off',
      '--natdnshostresolver1', 'off',
    ]
  end

  config.vm.box = 'ubuntu/trusty64'
  #config.vm.box = 'ubuntu/xenial64'
  #config.vm.box = 'centos/7'
  config.vm.network 'private_network', ip: '192.168.33.33'
  config.vm.network 'forwarded_port', guest: 3000, host: 3000
  config.vm.synced_folder '.', '/vagrant'

  config.vm.provision 'docker'
  config.vm.provision 'shell', inline: <<-SHELL
  curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  SHELL

  config.vm.provision 'shell', inline: <<-SHELL
  ln -s /vagrant /app
  cd /app
  /usr/local/bin/docker-compose build
  if [ ! -d '/app/app' ] && [ ! -f '/app/Gemfile' ]; then
    rm -rf /app/.git
    /usr/local/bin/docker-compose run app rails new . -f -d mysql
  elif [ ! -f '/app/Gemfile' ] ; then
    echo 'source '\''https://rubygems.org'\''\n\ngem '\''rails'\'', '\''~> 5.0.0'\' > /app/Gemfile
  fi
  sed -ie "/adapter: mysql/a \\  url: <%= ENV['MARIADB_URL'] %>" config/database.yml
  sed -ie "/adapter: postgresql/a \\  url: <%= ENV['POSTGRES_URL'] %>" config/database.yml
  /usr/local/bin/docker-compose run app bundle install
  /usr/local/bin/docker-compose run app bundle exec rake db:setup
  /usr/local/bin/docker-compose run app bundle exec rake db:migrate
  SHELL

  config.vm.provision 'shell', inline: <<-SHELL
  echo '#!/bin/bash\n\ncd /app\n/usr/local/bin/docker-compose run app bundle install' > /usr/local/bin/bundle-install
  echo '#!/bin/bash\n\ncd /app\n/usr/local/bin/docker-compose run app bundle update' > /usr/local/bin/bundle-update
  echo '#!/bin/bash\n\ncd /app\n/usr/local/bin/docker-compose run app bundle exec rake db:setup' > /usr/local/bin/setup
  echo '#!/bin/bash\n\ncd /app\n/usr/local/bin/docker-compose run app bundle exec rake db:migrate' > /usr/local/bin/migrate
  echo '#!/bin/bash\n\ncd /app\n/usr/local/bin/docker-compose up' > /usr/local/bin/server
  echo '#!/bin/bash\n\ncd /app\n/usr/local/bin/bundle-install\n/usr/local/bin/migrate\n/usr/local/bin/server' > /usr/local/bin/run
  echo '#!/bin/bash\n\ndocker exec -it `docker ps |grep vagrant_app | awk '\''{print $1}'\''` bash' > /usr/local/bin/connect
  chmod +x /usr/local/bin/bundle-install
  chmod +x /usr/local/bin/bundle-update
  chmod +x /usr/local/bin/setup
  chmod +x /usr/local/bin/migrate
  chmod +x /usr/local/bin/server
  chmod +x /usr/local/bin/run
  chmod +x /usr/local/bin/connect
  SHELL
end
