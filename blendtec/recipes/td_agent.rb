
node[:deploy].each do |app_name, deploy|
  #generate td-agent.conf config file
  template '/etc/td-agent/td-agent.conf' do
    source 'td-agent.conf.erb'
    mode 0440
    owner  'td-agent'
    group  'td-agent'
    variables(
	:application => (app_name rescue nil),
        :key => (node['config']['keys']['logger']['key'] rescue nil),
        :secret => (node['config']['keys']['logger']['secret'] rescue nil),
        :bucket => (node['td_agent']['bucket'] rescue nil),
        :s3_end_point => (node['td_agent']['end_point'] rescue nil),
        :path => (node['td_agent']['path']),
        :buffer_chunk_limit => (node['td_agent']['buffer_chunk_limit']),
        :time_slice_format => (node['td_agent']['time_slice_format']),
        :time_slice_wait => (node['td_agent']['time_slice_wait']),
        :time_zone => (node['td_agent']['time_zone']),
        :apache_access_s3_object_key_format => (node['td_agent']['apache_access_s3_object_key_format']),
        :apache_access_buffer_path => (node['td_agent']['apache_access_buffer_path']),
        :apache_error_s3_object_key_format => (node['td_agent']['apache_error_s3_object_key_format']),
        :apache_error_buffer_path => (node['td_agent']['apache_error_buffer_path']),
        :app_access_s3_object_key_format => (node['td_agent']['app_access_s3_object_key_format']),
        :app_access_buffer_path => (node['td_agent']['app_access_buffer_path']),
        :app_error_s3_object_key_format => (node['td_agent']['app_error_s3_object_key_format']),
        :app_error_buffer_path => (node['td_agent']['app_error_buffer_path'])
    )
    only_if do
      File.directory?('/etc/td-agent/')
    end
  end

  group "adm" do
    action :modify
    members "td-agent"
    append true
   end

end
