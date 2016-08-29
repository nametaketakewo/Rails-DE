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

  app_name = 'app'
  app_db = 'mysql'
  begin
    require 'yaml'
    file = YAML.load_file('docker-compose.yml')

    if File.exist?('app') && File.exist?('Gemfile')
      db_config = File.readlines('config/database.yml')
      adapters = db_config.grep(/adapter:/).map{|e| e.strip}
      if adapters.include?('adapter: mysql2') && adapters.include?('adapter: postgresql')
      elsif adapters.include?('adapter: mysql2')
        file['services']['app']['links'].delete('postgres')
        file['services'].delete('postgres')
      elsif adapters.include?('adapter: postgresql')
        file['services']['app']['links'].delete('mariadb')
        file['services'].delete('mariadb')
      elsif adapters.include?('adapter: sqlite3')
        file['services']['app']['links'].delete('postgres')
        file['services'].delete('postgres')
        file['services']['app']['links'].delete('mariadb')
        file['services'].delete('mariadb')
      end
    else
      app_name = (Dir::pwd).split('/')[-1] if (Dir::pwd).split('/')[-1] != 'Rails-DE'
      app_name = ENV['APP_NAME'].split(' ')[0] if ENV['APP_NAME'] && ENV['APP_NAME'] != '.' && ENV['APP_NAME'].split(' ').length > 0

      if ENV['APP_DB'] == 'sqlite' || ENV['APP_DB'] == 'sqlite3'
        app_db = 'sqlite3'
      elsif ENV['APP_DB'] == 'postgres' || ENV['APP_DB'] == 'postgresql'
        app_db = 'postgresql'
      end

      if app_db == 'mysql'
        file['services']['app']['links'].delete('postgres')
        file['services'].delete('postgres')
      elsif app_db == 'postgresql'
        file['services']['app']['links'].delete('mariadb')
        file['services'].delete('mariadb')
      elsif app_db == 'sqlite3'
        file['services']['app']['links'].delete('postgres')
        file['services'].delete('postgres')
        file['services']['app']['links'].delete('mariadb')
        file['services'].delete('mariadb')
      end
    end

    if ENV['EXCLUDE_REDIS'] == 'yes' || ENV['EXCLUDE_REDIS'] == 'true'
      file['services']['app']['links'].delete('redis')
      file['services'].delete('redis')
    end

    open('docker-compose.yml',"w") do |f|
      YAML.dump(file,f)
    end

    from = ''
    if File.exist?('.ruby-version')
      ruby_version = open('.ruby-version', &:read).chomp
      irregular_processors = %w(jruby maglev mruby rbx ree rbx)
      processor = ruby_version.split('-')
      if irregular_processors.include?(processor)
        from = 'FROM ruby:latest'
      else
        version = open('.ruby-version', &:read).split('.').map(&:to_i)
        if version.length >= 2 && version[0] >= 2 && version[1] >= 3
          from = "FROM ruby:#{ruby_version}"
        else
          from = 'FROM ruby:2.2.2'
        end
      end
    else
      from = 'FROM ruby:latest'
    end
    dockerfile = open('Dockerfile', &:read)
    dockerfile = from + "\n" + dockerfile
    open('Dockerfile','w') do |f|
      f.puts dockerfile
    end
  rescue
  end

  config.vm.provision 'shell', inline: <<-SHELL
  ln -s /vagrant /app
  cd /app
  /usr/local/bin/docker-compose build
  if [ ! -d '/app/app' ] && [ ! -f '/app/Gemfile' ]; then
  rm -rf /app/.git
  /usr/local/bin/docker-compose run app gem install rails
  /usr/local/bin/docker-compose run app rails new t/#{app_name} -d #{app_db}
  mv /app/t/#{app_name}/* /app/
  mv /app/t/#{app_name}/.* /app/
  rm -rf /app/t/
  elif [ ! -f '/app/Gemfile' ] ; then
  echo 'source '\''https://rubygems.org'\''\n\ngem '\''rails'\'', '\''~> 5.0.0'\' > /app/Gemfile
  fi
  grep "url: <%= ENV\['MARIADB_URL'\] %>" config/database.yml > /dev/null ||
  sed -ie "/adapter: mysql/a \\  url: <%= ENV['MARIADB_URL'] %>" config/database.yml
  grep "url: <%= ENV\['POSTGRES_URL'\] %>" config/database.yml > /dev/null ||
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
  echo "#!/bin/bash\n\ndocker exec -it "'\`'"docker ps |grep vagrant_app | awk '{print "'\$1'"}'"'\`'" bash" > /usr/local/bin/connect
  chmod +x /usr/local/bin/bundle-install
  chmod +x /usr/local/bin/bundle-update
  chmod +x /usr/local/bin/setup
  chmod +x /usr/local/bin/migrate
  chmod +x /usr/local/bin/server
  chmod +x /usr/local/bin/run
  chmod +x /usr/local/bin/connect
  SHELL
end
