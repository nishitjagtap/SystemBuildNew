name 'srv_000033_saptemplate'
maintainer 'Johnson and Johnson'
maintainer_email 'sconicel@its.jnj.com'
license 'All Rights Reserved'
description 'Installs/Configures srv_000033_saptemplate'
long_description 'Installs/Configures srv_000033_saptemplate'
version '1.4.4'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://jira.jnj.com' if respond_to?(:issues_url)
source_url 'https://sourcecode.jnj.com/scm//saptemplate' if respond_to?(:source_url)

# List of the cookbook dependencies
# EXAMPLE:
# depends 'scm_jenkins', "= 1.0.2"

depends 'srv_000033_sap', '= 1.2.3'
