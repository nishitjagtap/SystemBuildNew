#
# Cookbook:: srv_000033_saptemplate
# Recipe:: default
#
# Copyright:: 2017, Johnson and Johnson, All Rights Reserved.

# List of the additionally included SCM Framework or other Functional Cookbooks
# EXAMPLE:
# include_recipe 'scm_jenkins'

# # This version of the app cookbook template is compatible with the SAP CHEF
# # Functional Cookbook version 0.3.0 and above!!!

# # Define ez-er to use vars for rest of attributes file:
# # Do not change the next two lines!
s_lsid = node['srv_000033_sap']['l_sapsid']
s_usid = node['srv_000033_sap']['u_sapsid']

# # Uncomment this to have Chef create file systems
# # Note, storage must be provisioned according to the following standards:
# # https://confluence.jnj.com/display/ADVR/AWS+-+RHEL+8+Certification%3A+HANA+DB+Requirements
node.default['srv_000033_sap']['create_lvm_filesystems'] = true

# # Override user and group ids, uncomment and set accordingly:
# # Especially necessary for sidadm, CENTRIFY UID
node.override['srv_000033_sap']['users']["#{s_lsid}adm"]['u_uid'] = 9101
node.override['srv_000033_sap']['users']['sapadm']['u_uid'] = 9300

# # This line is ABSOLUTELY NEEDED as of srv_000033_sap version 0.3.3
# # This ensures that your /sapmnt/SID file system will be mounted
# # This is needed since we have added /sapmnt/SID for Web Dispatcher to v. 0.3.3
node.rm_default('srv_000033_sap', 'sstorage', "/sapmnt/#{s_usid}")

# # This can be set here or in node.default['srv_000033_sap']['sap_system_definition']
# # as additional_sstorage. This can be done at the instance level or system level
# # or you can specify 'flavor' => %w(cs db) if you just want it mounted on cs and db
node.override['srv_000033_sap']['sstorage'] =
  {
    "/sapmnt/#{s_usid}" =>
    {
      'owner' => "#{s_lsid}adm",
      'group' => 'sapsys',
      'mode' => '0755',
      'type' => 'efs',
      'fstype' => 'nfs4',
      'options' => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport',
      'source' => node['jnj']['scm_tag_sap-sapmntsrc'],
    },
    '/usr/sap/trans' =>
    {
      'owner' => "#{s_lsid}adm",
      'group' => 'sapsys',
      'mode' => '0775',
      'type' => 'efs',
      'fstype' => 'nfs4',
      'options' => 'nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport',
      'source' => node['jnj']['scm_tag_sap-transsrc'],
    },
  }

# # Uncomment out the following line to completely skip the SAP install
# # Chef will only configure the base OS
node.default['srv_000033_sap']['skip_sap_install'] = true

# # SAP System Definition Object
# # Detailed description of attributes can be found here:
# # https://confluence.jnj.com/display/ADVR/Explanation+of+SAP+CHEF+application+cookbook+attributes+%3E%3D+0.3.x
node.default['srv_000033_sap']['sap_system_definition'] =
  {
    # system info / type / global system settings go here
    'system_info' =>
    {
      'sapversion' => 'NW753',
      'stack' => 'ABAP',
      'dbversion' => 'ORA19',
      'sap_cmdb_ci' => 'CONCOURSE-IS-ATT-SBX-S23',
      'email_addr' => %w(csharm23@its.jnj.com),
      # app_environment can be: 'Staging', 'Test', 'Sandbox', 'Development', 'QA', or 'Production'
      'app_environment' => 'Development',
      # backint_folder can be 'Sandbox', 'Development', 'Quality', or 'Production'
      'backint_folder' => 'Development',
    },
    # instance data here
    # possible instance types: cs, acs, jcs, ers, aers, jers, db, pas, aas, wd
    'cs' =>
    {
      'instance_vhost' => "cs#{s_lsid}",
      'instance_number' => '00',
      'build_info' =>
      {
        'NW_GetMasterPassword.masterPwd' => 'Welcome123',
        'NW_SCS_Instance.instanceNumber' => '00',
        'NW_SCS_Instance.scsVirtualHostname' => "cs#{s_lsid}",
      },
    },
    'db' =>
    {
      'instance_vhost' => "db#{s_lsid}",
      'instance_number' => '00',
      'build_info' =>
      {
        'storageBasedCopy.ora.ABAPSchema' => 'SAPSR3',
      },
      'additional_linux_kernel_params' =>
      {
        'vm.nr_hugepages' =>
        {
          'sap_sysctl_value' => '45713',
        },
      },
    },
    'pas' =>
    {
      'instance_vhost' => "as#{s_lsid}00",
      'instance_number' => '00',
      'build_info' =>
      {
        'NW_CI_Instance.ascsVirtualHostname' => "cs#{s_lsid}",
        'NW_CI_Instance.ciInstanceNumber' => '00',
        'NW_CI_Instance.ciVirtualHostname' => "as#{s_lsid}00",
        'NW_getDBInfoGeneric.dbhost' => "db#{s_lsid}",
        'NW_CI_Instance.ascsInstanceNumber' => '00',
        'storageBasedCopy.ora.ABAPSchema' => 'SAPSR3',
      },
    },
    'aas' =>
    [
      {
        'instance_vhost' => "as#{s_lsid}01",
        'instance_number' => '00',
        'build_info' =>
        {
          'NW_AS.instanceNumber' => '00',
          'NW_DI_Instance.virtualHostname' => "as#{s_lsid}01",
          'storageBasedCopy.ora.ABAPSchema' => 'SAPSR3',
        },
      },
    ],
  }

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
