if node['jnj']['scm_hosting_platform'].casecmp?('OPC')
  include_recipe "#{node['jnj']['vpcx_accountid'].tr('-', '_')}_#{node['jnj']['scm_application']}::srv_000033_sap"
else
  include_recipe "#{node['jnj']['scm_tag_cookbook'].downcase}::srv_000033_sap"
end
