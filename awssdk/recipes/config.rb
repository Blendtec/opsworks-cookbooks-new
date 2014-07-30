#
# Cookbook Name:: awssdk
# Recipe:: config
#


node[:deploy].each do |app_name, deploy|

  app_dir = node[:config][:app_dir] rescue "app/"

  #generate awssdk config file
  template "#{deploy[:deploy_to]}/current/#{app_dir}Vendor/AwsSdk/config.inc.php" do
    source 'config.inc.php.erb'
    mode 0440
    group deploy[:group]

    if platform?('ubuntu')
      owner 'www-data'
    elsif platform?('amazon')
      owner 'apache'
    end

    variables(
        :key => (node['config']['awssdk']['key'] rescue nil),
        :secret => (node['config']['awssdk']['secret'] rescue nil)
    )

    only_if do
      File.directory?("#{deploy[:deploy_to]}/current/#{app_dir}Vendor/AwsSdk")
    end
  end

end