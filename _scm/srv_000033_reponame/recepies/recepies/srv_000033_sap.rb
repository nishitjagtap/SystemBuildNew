#
# Cookbook:: srv_000033_hanatest
# Recipe:: default
#
# Copyright:: 2017, Johnson and Johnson, All Rights Reserved.

# List of the additionally included SCM Framework or other Functional Cookbooks
# EXAMPLE:
# include_recipe 'scm_jenkins'

if node['jnj']['scm_hosting_platform'].casecmp?('OPC')
  include_recipe "#{node['jnj']['vpcx_accountid'].tr('-', '_')}_#{node['jnj']['scm_application']}::srv_000033_sap_#{node['jnj']['scm_tag_appid'].downcase}_#{node['jnj']['scm_tag_set'].downcase}"
else
  include_recipe "#{node['jnj']['scm_tag_cookbook'].downcase}::srv_000033_sap_#{node['jnj']['scm_tag_sap-apsid'].downcase}_#{node['jnj']['scm_tag_sap-sid'].downcase}"
end
