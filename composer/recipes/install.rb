#
# Cookbook Name:: composer 
# Recipe:: install
#

node[:deploy].each do |app_name, deploy|
Chef::Log.info("Composer #{deploy[:deploy_to]}");
  script "install_composer" do
    interpreter "bash"
    user 'root'
    cwd "#{deploy[:deploy_to]}/current"
    code "curl -s https://getcomposer.org/installer | php"
    code "php composer.phar install"
    EOH
  end

end
