#
# Cookbook Name:: blendfresh
# Recipe:: deploy_setup
#

include_recipe "composer::install"

node[:deploy].each do |app_name, deploy|

    #generate propay config file
    template "#{deploy[:deploy_to]}/current/Config/propay.php" do
        source 'propay.php.erb'
        mode 0440
        group deploy[:group]

        if platform?('ubuntu')
            owner 'www-data'
        elsif platform?('amazon')
            owner 'apache'
        end

        variables(
            :propay =>     (node[:config][:propay] rescue nil)
        )

        only_if do
            File.directory?("#{deploy[:deploy_to]}/current/Config")
        end
    end

    script "setup_propay" do
        interpreter "bash"
        cwd "#{deploy[:deploy_to]}/current"
        creates "Plugin/ProPay/generated/SPS.php"
        code <<-EOH
        ./Plugin/ProPay/setup.sh Plugin/ProPay/generated
        EOH
    end
end
