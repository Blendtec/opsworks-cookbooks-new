node[:deploy].each do |app_name, deploy|

  #Add proxypass entry for blog
  ruby_block "add proxypass blog entry" do
    Chef::Log.info("modifying #{node[:apache][:dir]}/sites-available/#{app_name}.conf")
    block do
      rc = Chef::Util::FileEdit.new("#{node[:apache][:dir]}/sites-available/#{app_name}.conf")
      proxy_line = "  ProxyPass /blog http://#{node['config']['blog']['ip']}\n  ProxyPassReverse /blog http://#{node['config']['blog']['ip']}"
      rc.insert_line_after_match(/^.*\DocumentRoot\b.*$/, proxy_line)
      rc.write_file
    end
    only_if do
      ::File.exists?("#{node[:apache][:dir]}/sites-available/#{app_name}.conf")
    end
  end
end
