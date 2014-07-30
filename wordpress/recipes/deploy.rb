#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2013, K-TEC, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

node[:deploy].each do |app_name, deploy|

  template "#{deploy[:deploy_to]}/current/wp-config.php" do
    source 'wp-config.php.erb'
    user 'deploy'
    group 'www-data'
    mode 00755
    variables(
        :db_name => (deploy[:database][:database] rescue nil),
        :db_user => (deploy[:database][:username] rescue nil),
        :db_password => (deploy[:database][:password] rescue nil),
        :db_host => (deploy[:database][:host] rescue nil),
        :auth_key => node['wordpress']['keys']['auth'],
        :secure_auth_key => node['wordpress']['keys']['secure_auth'],
        :logged_in_key => node['wordpress']['keys']['logged_in'],
        :nonce_key => node['wordpress']['keys']['nonce'],
        :auth_salt => node['wordpress']['salt']['auth'],
        :secure_auth_salt => node['wordpress']['salt']['secure_auth'],
        :logged_in_salt => node['wordpress']['salt']['logged_in'],
        :nonce_salt => node['wordpress']['salt']['nonce'],
        :lang => node['wordpress']['languages']['lang'],
        :aws_key => node['wordpress']['aws']['key'],
        :aws_secret_key => node['wordpress']['aws']['secret']
    )
    action :create
  end

  template "#{deploy[:deploy_to]}/current/wp-content/w3tc-config/master.php" do
    source 'master.php.erb'
    user 'deploy'
    group 'www-data'
    mode 00755
    variables(
        :db_name => (deploy[:database][:database] rescue nil),
        :db_user => (deploy[:database][:username] rescue nil),
        :db_password => (deploy[:database][:password] rescue nil),
        :db_host => (deploy[:database][:host] rescue nil),
        :auth_key => node['wordpress']['keys']['auth'],
        :secure_auth_key => node['wordpress']['keys']['secure_auth'],
        :logged_in_key => node['wordpress']['keys']['logged_in'],
        :nonce_key => node['wordpress']['keys']['nonce'],
        :auth_salt => node['wordpress']['salt']['auth'],
        :secure_auth_salt => node['wordpress']['salt']['secure_auth'],
        :logged_in_salt => node['wordpress']['salt']['logged_in'],
        :nonce_salt => node['wordpress']['salt']['nonce'],
        :lang => node['wordpress']['languages']['lang'],
        :aws_key => node['wordpress']['aws']['key'],
        :aws_secret_key => node['wordpress']['aws']['secret']
    )
    action :create
  end

  directory "#{deploy[:deploy_to]}/current/wp-content" do
    mode 00775
    recursive true
  end

  file "#{deploy[:deploy_to]}/current/wp-content/plugins/w3tc-wp-loader.php" do
    mode 00775
    only_if do
      ::File.exists?("##{deploy[:deploy_to]}/current/wp-content/plugins/w3tc-wp-loader.php")
    end
  end

  file "#{deploy[:deploy_to]}/current/.htaccess" do
    mode 00664
    only_if do
      ::File.exists?("#{deploy[:deploy_to]}/current/.htaccess")
    end
  end


end
