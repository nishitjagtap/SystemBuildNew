#
# Cookbook:: srv_000033_chefwsi
# Recipe:: default
#
# Copyright:: 2017, Johnson and Johnson, All Rights Reserved.

# List of the additionally included SCM Framework or other Functional Cookbooks
# EXAMPLE:
# include_recipe 'scm_jenkins'

# IMPORTANT! This attributes file contains nil values that should be overwritten by app cookbooks (including NAS)!

# Define ez-er to use vars for rest of attributes file:
# Do not change the next two lines!
s_lsid = node['srv_000033_sap']['l_sapsid']

# # Uncomment this to have Chef create file systems
# # Note, storage must be provisioned according to the following standards:
# # https://confluence.jnj.com/display/ADVR/AWS+-+RHEL+8+Certification%3A+HANA+DB+Requirements
node.default['srv_000033_sap']['create_lvm_filesystems'] = true

# SAP System Definition Object
# Detailed description of attributes can be found here:
# https://confluence.jnj.com/display/ADVR/Explaination+of+SAP+CHEF+application+cookbook+attributes+%3E%3D+0.2.1

node.override['srv_000033_sap']['users']["#{s_lsid}adm"]['u_uid'] = 9100
node.override['srv_000033_sap']['users']['sapadm']['u_uid'] = 9300

node.default['srv_000033_sap']['sap_system_definition'] =
  {
    # system info / type / global system settings go here
    'system_info' =>
    {
      'sapversion' => 'NW749',
      'stack' => 'WD',
      'sap_cmdb_ci' => 'CONCOURSE-IS-WD-SBX-SAF',
      'email_addr' => %w(nishit.jagtap@quantumintegrators.com),
      'app_environment' => 'Test',
    },
    # instance data here
    # possible instance types: cs, acs, jcs, ers, aers, jers, db, pas, aas, wd
    'wd' =>
    [
      {
        'instance_vhost' => "w#{s_lsid}01",
        'instance_number' => '00',
        'build_info' =>
        {
          'NW_GetMasterPassword.masterPwd' => 'Welcome123',
          'NW_Webdispatcher_Instance.wdInstanceNumber' => '00',
          'NW_webdispatcher_Instance.wdVirtualHostname' => "w#{s_lsid}01",
        },
      },
    ],
  }

# # Uncomment out the following line to completely skip the SAP install
# # Chef will only configure the base OS
node.default['srv_000033_sap']['skip_sap_install'] = true

# # These should only be set for development purposes or for pre-blueprint built VMs
node.default['srv_000033_sap']['skip_pmul_checks'] = false
node.default['srv_000033_sap']['skip_lama_checks'] = false
node.default['srv_000033_sap']['skip_sstorage_checks'] = false
node.default['srv_000033_sap']['skip_sstorage_blockstorage_checks'] = false
node.default['srv_000033_sap']['skip_sstorage_sharedstorage_checks'] = false
node.default['srv_000033_sap']['skip_nas_checks'] = false
node.default['srv_000033_sap']['skip_package_checks'] = false
node.default['srv_000033_sap']['skip_policy_checks'] = false
node.default['srv_000033_sap']['skip_sysctl_checks'] = false
node.default['srv_000033_sap']['skip_systemd_checks'] = false
node.default['srv_000033_sap']['skip_user_checks'] = false
node.default['srv_000033_sap']['skip_limits_checks'] = false
node.default['srv_000033_sap']['skip_etcservices_checks'] = false

# # !!! skip_san_checks should be uncommented if you are hooking up to a pre-existing system !!!
# # This feature should be deprecated as of 0.3.x versions of Chef
node.default['srv_000033_sap']['skip_san_checks'] = false

# # Set this value to false to skip installing and configuring backint
node.default['srv_000033_sap']['install_backint'] = false

# # This should only ever be used by the INOE team for testing new Chef functional
# # cookbook versions!!!
# node.default['srv_000033_sap']['cookbook_testing'] = false

# # Example of how certain attributes can be overridden:
# node.override['srv_000033_sap']['group_ids'] =
#   {
#     'sapinst' => 999,
#     'oper' =>  222,
#   }

include_recipe 'srv_000033_sap'
