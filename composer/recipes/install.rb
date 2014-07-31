#
# Cookbook Name:: composer 
# Recipe:: install
#

node[:deploy].each do |app_name, deploy|
Chef::Log.info("Composer #{deploy[:deploy_to]}");
  script "install_composer" do
    interpreter "bash"
    user 'root'
    code "cd ~ && curl -s http://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer.phar"
  end

end
