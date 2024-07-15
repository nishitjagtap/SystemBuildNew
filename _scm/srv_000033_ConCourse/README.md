# srv_000033_sap

# Description

This README will document the main purpose and usage for this functional cookbook, `srv-000033`, as well as explain the symbiotic releationship this cookbook has with all of the SAP application cookbooks.

## Overview

SRV_000033_SAP is the Chef cookbook which will automate the SAP installation and configuration on the Johnson and Johnson environment. This cookbook is written for JNJ OPCx environment for RHEL6, RHEL7, & RHEL8 Linux versions.

## Functional cookbook layout

The cookbook is logically divided into 3 parts... they are:

1. **SAP Server Provisioning:** takes care of all the Operating System configuration required to install SAP NetWeaver.

2. **SAP Basebuild:** calls the basebuild automation framework shell scripts. It uses all the attributes declared in the assigned application cookbook.

3. **SAP IQOQ:** this part will call the metadata generation script, qualify script, and scm_qualify core cookbook for qualifying the SAP application installation and configurations (including an automated upload of the SFT/EVD document to EDMS)

## Current configuration items

OS configuration includes the following configuration items: 
* user and group management
* userlimits
* sysctl (Linux kernel settings)
* disable THP and restart the server if cookbook is triggered within 24 hours of VM provisioning
* sudo privileges for SAP users
* package installation for SAP 
* SAN mountpoints
* NAS automount for all shared storage and binary servers
* `/etc/services` file port fencing (ABAP and JAVA)
* netbackup exclude list
* AMAZON EBS file system creation
* SAP Policy Files
* Misc HANA configuration

If more information is needed, please view exactly what attributes are configured by this functional cookbook under the [attributes](https://sourcecode.jnj.com/projects/SRV-000033/repos/srv_000033_sap/browse/attributes) folder.

# Usage

## Overview

This section will describe how the functional cookbook is called by the application cookbooks.  The functional cookbook contains all of the logic as well as the hardened configuration attributes that cannot be changed by an application cookbook.  Attributes that need to be custom tailored for each application are defined in the application cookbook.  The functional cookbook then merges the additional attributes into one object that it then uses to configure the system.

## Tags

The following tags must be set on each workload in order for the SAP Chef cookbooks to function as expected.

### For OPCx:

The following tags must be set via the `/etc/jnj-install/scm_facts.txt` file:
* accountid:`srv-000033`
* application:`<repository id><d|q|p>`
* appbranch:`<development|qa|production>`
* AppID:`<SAP CMDB APS ID>`
* tag_role:`<CS|ACS|JCS|ERS|AERS|JERS|DB|PAS|AAS|WD>`
* tag_set:`<SAP SID>`

### For VPCx:

The following tags must be set via the cloud hosting provider's tag management requirements (e.g., for AWS, via the AWS console):
* cookbook:`<application cookbook name under srv-000033>`
* sap-sid:`<SAP SID>`
* hdb-sid:`<HANA DB SID> *note, this is only needed on HDB hosts`
* sap-apsid:`<SAP CMDB APS ID>`
* sap-instance:`<CS|ACS|JCS|ERS|AERS|JERS|HDB|PAS|AAS|WD>`

---

**NOTE**

The `cookbook` tag is extremely important for VPCx builds.  This tag points the VM to an application cookbook under srv-000033.  Application cookbooks under srv-000033 are named like `srv_000033_<reponame>.` Within the application cookbook repository, the updates must be pushed to the correct target branch as well (either development, qa, or production).  This maps directly to the IAM role's environment... E.g., if the IAM role for the VM is development, then the application
cookbook must be pushed to the development branch within srv-000033.

---

## Skipping over the SAP installation

While the SAP base/shell build is essential, it is possible to completely skip the SAP installation and just perform the OS level configurations.  In order to do this, as of functional cookbook version `0.2.11`, you can set the following attribute to `true` in the recipe file of the application cookbook, for the system in question:

```
node.default['srv_000033_sap']['skip_sap_install'] = true
```

## SAP instance types and platform versions

This section will outline what current SAP instance types are used and also what platform versions are supported.  An instance type can be an actual SAP instance or a different logical delimeter, for example, a print server.

### Current supported instance types

The instance type directly correlates with the OHAI attribute for `tag_role` aka `node['jnj']['scm_tag_role']`.  For OPCx, when this is set in the node's `/etc/jnj-install/scm_facts.txt` file, the functional cookbook then compares this against whatever is specified in the related attributes objects.  This is how we can set certain values for one instance type but not the others, etc... 

The following instance types are able to be specified:

* SAP Central Services for single stack (ABAP or JAVA): `CS`
* SAP Central Services ABAP dual stack: `ACS`
* SAP Central Services JAVA dual stack: `JCS`
* SAP Enqueue Replication Server (ABAP or JAVA): `ERS`
* SAP Enqueue Replication Server ABAP dual stack: `AERS`
* SAP Enqueue Replication Server JAVA dual stack: `JERS`
* SAP Oracle Database: `DB`
* SAP HANA Database: `HDB`
* SAP Primary Application Server: `PAS`
* SAP Additional Application Server(s): `AAS`
* SAP Web Dispatcher: `WD`

### Current supported platform versions

The platform version directly correlates with the OHAI attribute `node['platform_version']`.  This is a default attribute within OHAI and does not need to be specified in the `/etc/jnj-install/scm_facts.txt` file.  This is how we can set certain values for one platform version but not the others, etc... 

The following instance types are able to be specified:

* RHEL6: `6`
* RHEL7: `7`
* RHEL7: `8`

### Current supported cluster types

As of version `0.2.1`, the SAP CHEF functional cookbook supports cluster software configurations.  This is important because configuration items may change depending on the cluster state.  For example, if you had a two node active/passive cluster where `node a` runs `CS` and `node b` runs `DB`, then the configuration items for `node a` will be different than `node b`.  In the event of `node b` failing over to `node a`, then you would expect CHEF to then check configuration for both `CS` and `DB` on `node a`.  As of this release, this functionality is available.

The following cluster types are supported:

* HP Service Guard:

```
'cluster' =>
{
  'type' => 'serviceguard',
  'package_name' => 'dbL01',
},
```

## How to separate configuration on instance type or platform version

The functional cookbook has a way to apply attributes to whatever instance type or platform version of your choice.  For example, if there are certain Linux kernel parameters that belong on the database instance but not the other instances, this can be accomplished by setting `'flavor' => 'db'` within your attribute object.  If you needed something set on multiple instances, you could set the `flavor` variable within your attribute object as follows: `'flavor' => %w(cs db pas aas wd)`.  If you omit the `flavor`, then any instance type would be in scope.  Similar to instance type, platform version can also be specified to distinguish between RHEL6 and RHEL7 by setting the following variable within your attribute object: `'platform_version' => %w(7)` or `'platform_version' => %w(6 7)`.  Similar to omitting the `flavor`, if you omit the `platform_version`, then any platform version would be in scope.  Specific examples of this logic are outlined below...

## Transparent Hugepage Settings (THP)

This cookbook will also disable THP.  Depending on the platform version, it will take appropriate action to disable this.  Unfortunately, there is currently no way to automate the reboot and then ensure that the node is not subsequently rebooted, so **the reboot needs to be taken care of manually before releasing the system for productive use!**

## Application cookbook naming convention

The application cookbook must follow strict naming standards.  Each platform will have a repository created under the main SAP Infrastructure Serverices Business Service Bitbucket Project: [srv-000033](https://sourcecode.jnj.com/projects/SRV-000033).  Each repository must be named by the platform's associated business service ID.  For example, for VISIONCARE: [srv0004385d](https://sourcecode.jnj.com/projects/SRV-000033/repos/srv0004385d/browse).

Please note that each platform will have an application cookbook repository for each environment.  We split this into 3 separate environments: development, qa, and production.  So if we continue with the VISIONCARE example, we will have three application cookbook repositories for VISIONCARE: 

* VISIONCARE Development: [srv0004385d](https://sourcecode.jnj.com/projects/SRV-000033/repos/srv0004385d/browse).
* VISIONCARE Qa: [srv0004385q](https://sourcecode.jnj.com/projects/SRV-000033/repos/srv0004385q/browse).
* VISIONCARE Production: [srv0004385p](https://sourcecode.jnj.com/projects/SRV-000033/repos/srv0004385p/browse).

The application cookbook's recipe files adhere to a strict naming convention.  Each recipe file must be named accordingly as follows: `srv_000033_sap_<aps_id>_<sid>.rb`

## Overrideable attributes

Most attributes should NOT be overridden.  However, in the event that it is absolutely required, these following attributes can be overridden.  Note, all overridden attributes must be set outside of the system definition object.

### User IDs

The `default['srv_000033_sap']['user_ids']` attribute can be overridden as follows:

```
node.override['srv_000033_sap']['user_ids'] =
{
  "ora#{s_lsid}" => 9099,
  "#{s_lsid}adm" => 9199,
}
```

### Group IDs

The `default['srv_000033_sap']['group_ids']` attribute can be overridden as follows:

```
node.override['srv_000033_sap']['group_ids'] =
{
  'sapinst' => 999,
  'oper' =>  222,
}
```

## Application system definition

The next revision of the SAP CHEF cookbook utilizes the SAP system definition object.  This object allows the end user to fine-tune the system by specifying attributes at the system-wide or instance-specific level.  The 'aas' instance type is the only instance that can be defined as an array if there are more than one additional app servers.  Any other attempt to use the other instance types as an array to install more than one will result in a failed run (e.g., try to install more than one 'cs' instance).

This can ONLY be used if the 'instance_vhost' parameter is truly mapped to the guest OS.  A simple entry in the /etc/hosts file may not work for these additional attribute settings.

The following objects can be set in application cookbooks in order to merge settings with the functional cookbook:
* additional users = `'additional_users'`
* additional groups = `'additional_groups'`
* additional packages (rpms) = `'additional_packages'`
* additional yum repositories (rpms) = `'additional_yumrepos'`
* additional san storage = `'additional_san'` (note, being replaced by additional_sstorage)
* additional nas storage = `'additional_nas'` (note, being replaced by additional_sstorage)
* additional sap storage = `'additional_sstorage'`
* additional kernel settings = `'additional_linux_kernel_params'`

### Generic usage for these objects

Any strings that need to use a variable must be wrapped in double quotes `"`, else wrap strings in single quotes, `'`.  If you need to create multiple scenarios for the same element in an object, for example, you want a kernel setting to be `123` on the `CS` node but `789` on the `DB` node, then that element should be an array. Use arrays to define multiple scenarios for one single key.

### Additional users object example

The following is an example of what the additional users object would look like in the application cookbook's main recipe file:

```
'additional_users' =>
  {
    'newuser1' =>
    {
      'u_uid' => 999,
      'u_gid' => group_gid['maingroup'],
      'u_comment' => 'new user 1 description',
      'u_home' => '/home/newuser1',
      'u_shell' => '/bin/bash',
    },
    "#{s_lsid}adm" =>
    {
      'u_uid' => 9100,
      'u_gid' => group_gid['sapsys'],
      'u_comment' => "#{s_usid} SAP Admin",
      'u_home' => "/home/#{s_lsid}adm",
      'u_shell' => '/bin/bash',
    },
  }
```

Note, this is just an example... User `newuser1` is a dummy user and `#{s_lsid}adm` is actually included in the functional cookbook by default. 

### Additional groups object example

The following is an example of what the additional groups object would look like in the application cookbook's main recipe file:

```
'additional_groups' =>
  {
    'dba' =>
    [{
      'gid' => group_gid['dba'],
      'members' => "#{s_lsid}adm",
    },
    {
      'gid' => group_gid['dba'],
      'members' => ["#{s_lsid}adm", 'oracle'],
    },],
    'sapsys' =>
    {
      'gid' => group_gid['sapsys'],
    },
  }
```

Note, this is just an example... Groups `dba` and `sapsys` are included in the functional cookbook by default. Note that the first element in this example is an array. Use arrays to define multiple scenarios for one single key.

### Additional packages object example

The following is an example of what the additional packages object would look like in the application cookbook's main recipe file:

```
'additional_packages' =>
  {
    'compat-sap-c++' =>
    {
      'package_command' => 'install',
    },
    'nfs-utils' =>
    {
      'package_command' => 'install',
    },
    'somegroup' =>
    {
      'package_command' => 'groupinstall',
    },
  }
```

Note, this is just an example... Packages `compat-sap-c++` and `nts-utils` are already included in the functional cookbook.

If a new yum server/repo needs to be added, it can be set in the application cookbook's main recipe file as follows:

```
'additional_yumrepos' =>
  {
    'JNJ-rhel-x86_64-server-sap-6-201703' =>
    {
      'baseurl' => 'https://itsusrasmtp1/yum/JNJ-rhel-x86_64-server-sap-6-201703',
      'enabled' => true,
      'sslverify' => false,
    },
  }
```

Note, this is just an example... This yum repo is already included in the functional cookbook.

### Additional sstorage object example

The `additional_sstorage` functionality combines all storage into one recipe and attribute.  The type of storage can be specified within the attribute itself.

If you combine this attribute with the `node.default['srv_000033_sap']['create_lvm_filesystems'] = true` attribute, Chef will attempt to provision the file systems accordingly.  However, the storage for the guest OS must be provisioned according to https://confluence.jnj.com/display/ADVR/Red+Hat+Enterprise+Linux+%28RHEL%29+8+Certification

---

**NOTE**

This attribute should be used instead of `additional_san` and/or `additional_nas` since both have been replaced by `additional_sstorage.`

---

```
'additional_sstorage' =>
  {
    '/erpsoftware' =>
    {
      'sstorage_source' => 'itsusrac1ts1.jnj.com:/itsusrac1ts1_its_sap_03/erp_software_dev',
      'sstorage_owner' => 'root',
      'sstorage_group' => 'root',
      'sstorage_mode' => '0755',
      'sstorage_type' => 'nas',
      'region' => %w(na eu ap),
    },
    '/tst/one' =>
    {
      'owner' => "#{s_lsid}adm",
      'group' => 'sapsys',
      'mode' => '0775',
      'type' => 'ebs',
      'fstype' => 'xfs',
      'options' => 'rw,noatime,nodiratime,logbsize=256k',
      'source' => '/dev/mapper/vgtstone-lvtstone',
      'vol_info' =>
      {
        'vgname' => 'vgtstone',
        'lvname' => 'lvtstone',
        'minimum_sizegb' => 2,
        'block_devices' => %w(/dev/sdi /dev/sdj),
        'lv_size' => '100%FREE',
        'lv_stripes' => 2,
        'lv_stripesize' => 256,
      },
    },
    '/tst/two' =>
    {
      'owner' => "#{s_lsid}adm",
      'group' => 'sapsys',
      'mode' => '0775',
      'type' => 'ebs',
      'fstype' => 'xfs',
      'options' => 'rw,noatime,nodiratime,logbsize=256k',
      'source' => '/dev/mapper/vgtsttwo-lvtsttwo',
      'vol_info' =>
      {
        'vgname' => 'vgtsttwo',
        'lvname' => 'lvtsttwo',
        'minimum_sizegb' => 2,
        'block_devices' => %w(/dev/sdk),
        'lv_size' => '100%FREE',
      },
    },
  }
```

As with all other attributes, the `flavor`, `region`, and `platform_version` attributes can be set to further restrict where and how to apply these settings.  The `sstorage_type` attribute can be set to any of the following:

* 'nas'
* 'san'
* 'swap'
* 'efs'
* 'ebs'

Another important attribute that can be defined, is the `sstorage_options` attribute.  This attribute can be set to any specific string to provide mount options... for example: `'sstorage_options' => 'nfsvers=3,udp'`.  This can be set to any valid string for mounting options.

### Additional san object example

Note, this will be phased out by the `additional_sstorage` attribute type.  The `additional_sstorage` functionality combines all storage into one recipe and attribute.  The type of storage can be specified within the attribute itself.  See `additional_sstorage` for details...

Since we use LVMs, the functional cookbook will only check to make sure that the appropriate mountpoint are mounted.  It will not maintain the `/etc/fstab` file with these entries.  In the case of the SAP database instance, the functional cookbook will take a different approach for the SAPDATA file systems.  The SAPDATA file systems must be set via the following:

* Within the application cookbook's appropriate recipe file, `srv_000033_sap_appid_sid.rb`, the following variable **must be set to the exact SAPDATA file system count** for instance type `DB`: `'sapdata_count'`.  This variable must be set in the syste-wide section within the `sap_system_definition` variable.
* If a new SAPDATA needs to be added, you **absolutely must** increase the number defined in the appropriate recipe file for the `'sapdata_count'` variable.  If you do not do this, the next chef-client run will fail.
* To skip SAN checks altogether, you can set the following variable to true: `node.default['srv_000033_sap']['skip_san_checks'] = true`

The following is an example of what the additional san object would look like in the application cookbook's main recipe file:

```
'additional_san' =>
  {
    "/dev/mapper/vg01-lvoem#{s_usid}" =>
    {
      'san_name' => "lvoem#{s_usid}",
      'san_mountpoint' => '/oem',
      'san_mountpoint_owner' => 'monora', # 35462,
      'san_mountpoint_group' => 'dba',
      'san_mountpoint_mode' => '0775',
    },
    '/dev/mapper/vg01-lvoracle' =>
    {
      'san_name' => 'lvoracle',
      'san_mountpoint' => "/oracle/#{s_usid}",
      'san_mountpoint_owner' => 'oracle',
      'san_mountpoint_group' => 'oinstall',
      'san_mountpoint_mode' => '0755',
    },
  }
```

Note, this is just an example... These volumes are already included in the functional cookbook.

### Additional nas object example

Note, this will be phased out by the `additional_sstorage` attribute type.  The `additional_sstorage` functionality combines all storage into one recipe and attribute.  The type of storage can be specified within the attribute itself.  See `additional_sstorage` for details...

All NAS is defined within the `/etc/fstab` file.

The following is an example of what the additional nas object would look like in the application cookbook's main recipe file:

```
'additional_nas' =>
  {
    'itsusrasdna112.jnj.com:/vol/itsusrasdna112_sbx/che_sapmnt_wsi' =>
    {
      'nas_mountpoint' => "/sapmnt/#{s_usid}",
      'nas_mountpoint_owner' => "#{s_lsid}adm",
      'nas_mountpoint_group' => 'sapsys',
      'nas_mountpoint_mode' => '0755',
    },
    'itsusrasdna112.jnj.com:/vol/itsusrasdna112_sbx/che_saptrans_wsi' =>
    {
      'nas_mountpoint' => '/usr/sap/trans',
      'nas_mountpoint_owner' => "#{s_lsid}adm",
      'nas_mountpoint_group' => 'sapsys',
      'nas_mountpoint_mode' => '0755',
    },
  }
```

Note, this is just an example... These volumes are already included in the functional cookbook.

### Additional linux kernel parameters object example

The functional cookbook will place all custom Linux kernel parameters in the following file: `/etc/sysctl.d/99-chef-attributes.conf` (**RHEL7 only!**).  Unfortunately, there is no option to do that in RHEL6, so values will be set **directly in** `/etc/sysctl.conf`.

The following is an example of what the additional linux kernel parameters object would look like in the application cookbook's main recipe file:

```
'additional_linux_kernel_params' =>
  {
    'vm.nr_whatever' =>
      {
        'sap_sysctl_value' => '4096',
      },
  }
```

Note, this is just an example... this shows where we need a linux kernel parameter called, `vm.nr_whatever`, to be set differently depending on what `platform_version` we are running on.

# License and Author

* **Maintained by** "Conicelli, Steve [GTSUS]" sconicel@ITS.JNJ.com
* **Author** "Conicelli, Steve [GTSUS]" sconicel@ITS.JNJ.com
