module "IAC_S24" {
  source                     = "git::https://sourcecode.jnj.com/scm/asx-iacx/terraform-aws-sapsystem-oracle.git"
  appid                      = "APP000010024488"
  application_name           = "JNJ-SAP"
  cookbook                   = "srv_000033_reponame"
  instance_profile           = "itx-dmx-app-sap-developmentProfile"
  os_filter                  = "JNJ RHEL 8 SAP-HANA CLOUDx - 2023 Q3"
  os_filter_oradb            = "JNJ ORACLELINUX 8 - CLOUDx - 2023 Q3"
  os_filter_as               = "JNJ ORACLELINUX 8 - CLOUDx - 2023 Q3"
  cs_host_name               = ["css24-aws"]
  db_host_name               = ["dbs24-aws"]
  as_host_name               = ["aass2400-aws"]
  sap_apsid                  = "APS000010004893"
  sap_sid                    = "S24"
  ec2_tshirt_size            = "small"
  disk_tshirt_size           = "large"
  as_count                   = "1"
  subnet_filter              = ["Primary VPC 1 - Primary1 Subnet 1"]
  user                       = "ITX-DMX"
  vpc_filter                 = "Primary VPC 1"
  vpcxEnvironment            = "DEV"
  env                        = "QA"
  IAC_org                    = var.IAC_org
}
