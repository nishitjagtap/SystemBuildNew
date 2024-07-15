module "IAC_S23" {
  source                     = "git::https://sourcecode.jnj.com/scm/asx-iacx/terraform-aws-sapsystem-oracle.git"
  appid                      = "APP000010025051"
  application_name           = "CONCOURSE-IS-ATT-SBX"
  cookbook                   = "srv_000033_ConCourse"
  instance_profile           = "itx-dmx-app-sap-developmentProfile"
  os_filter                  = "JNJ RHEL 8 SAP-HANA CLOUDx - 2023 Q3"
  os_filter_oradb            = "JNJ ORACLELINUX 8 - CLOUDx - 2023 Q3"
  os_filter_as               = "JNJ ORACLELINUX 8 - CLOUDx - 2023 Q3"
  cs_host_name               = ["css23-aws"]
  db_host_name               = ["dbs23-aws"]
  as_host_name               = ["ass2300-aws"]
  sap_apsid                  = "APS000010003910"
  sap_sid                    = "S23"
  ec2_tshirt_size            = "medium"
  disk_tshirt_size           = "large"
  as_count                   = "1"
  subnet_filter              = ["Primary VPC 1 - Primary1 Subnet 1"]
  user                       = "njagtap"
  vpc_filter                 = "Primary VPC 1"
  vpcxEnvironment            = "PROD"
  env                        = "DEV"
  IAC_org                    = var.IAC_org
}
