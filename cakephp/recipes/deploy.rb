#
# Cookbook Name:: cakephp
# Recipe:: deploy
#

include_recipe "composer::install"

node[:deploy].each do |app_name, deploy|
  Chef::Log.info("CakePHP deploy #{app_name} to #{deploy[:deploy_to]}/current/#{app_name}")
  app_dir = node[:config][:app_dir] rescue "app/"

  #generate database config file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Config/database.php" do
    source 'database.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :host =>     (deploy[:database][:host] rescue nil),
        :user =>     (deploy[:database][:username] rescue nil),
        :password => (deploy[:database][:password] rescue nil),
        :db =>       (deploy[:database][:database] rescue nil)
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config")
    end
  end

  #generate core config file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Config/core.php" do
    source 'core.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :debug => (node['config']['core']['debug'] rescue nil),
        :salt => (node['config']['security']['salt'] rescue nil),
        :cipher_seed => (node['config']['security']['cipher_seed'] rescue nil),
        :prefixes => (node['config']['prefixes'] rescue "'admin'")
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config")
    end
  end

  #set permissions on cake console
  file "#{deploy[:deploy_to]}/current/#{app_dir}Console/cake" do
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    group deploy[:group]
    mode 0550
    action :touch
  end

  #set tmp permissions, create if needed
  directory "#{deploy[:deploy_to]}/current/#{app_dir}tmp" do
    mode 0740
    group deploy[:group]
    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end
    action :create
  end

  #create tmp subdirectories
  %w{cache logs sessions tests}.each do |dir|
    directory "#{deploy[:deploy_to]}/current/#{app_dir}tmp/#{dir}" do
      mode 0740
      group deploy[:group]
      if platform?('ubuntu')
        owner 'www-data'
      elsif platform?('amazon')
        owner 'apache'
      end
      action :create
      recursive true
    end
  end

  #create cache subdirectories
  %w{models persistent views}.each do |dir|
    directory "#{deploy[:deploy_to]}/current/#{app_dir}tmp/cache/#{dir}" do
      mode 0740
      group deploy[:group]
      if platform?('ubuntu')
        owner 'www-data'
      elsif platform?('amazon')
        owner 'apache'
      end
      action :create
      recursive true
    end
  end

  #if plugins directory exists iterate over each doing migrations for those with migration scripts
  if File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Plugin")
    Dir.foreach("#{deploy[:deploy_to]}/current/#{app_dir}Plugin") do |item|
      next if item == '.' or item == '..'  or Dir["#{deploy[:deploy_to]}/current/#{app_dir}Plugin/#{item}/Config/Migration"].empty?
      Chef::Log.info("Running migrations for #{item}")
      execute 'cake migration' do
        cwd "#{deploy[:deploy_to]}/current/#{app_dir}"
        command "./Console/cake Migrations.migration run all --plugin #{item}"
        if platform?('ubuntu')
          user 'www-data'
        elsif platform?('amazon')
          user 'apache'
        end
        action :run
        returns 0
      end
    end
  end

  #if app has migrations run them
  if File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Config/Migration")
    Chef::Log.info("Running migrations for app")
    execute 'cake migration' do
      cwd "#{deploy[:deploy_to]}/current/#{app_dir}"
      command './Console/cake Migrations.migration run all'
      if platform?('ubuntu')
        user 'www-data'
      elsif platform?('amazon')
        user 'apache'
      end
      action :run
      returns 0
    end
  end

end


