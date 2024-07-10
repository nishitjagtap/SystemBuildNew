module "IAC_SAH" {
  source                     = "git::https://sourcecode.jnj.com/scm/asx-iacx/terraform-aws-sapsystem-oracle.git"
  appid                      = "APP000010024488"
  application_name           = "JNJ-SAP"
  cookbook                   = "srv_000033_reponame"
  instance_profile           = "itx-bin-app-jjterptestlab-development-11GAOTFZ8C5TB"
  os_filter                  = "JNJ RHEL 8 SAP-HANA CLOUDx - 2023 Q3"
  sap_apsid                  = "APS000010004898"
  sap_sid                    = "SAH"
  ec2_tshirt_size            = "medium"
  subnet_filter              = ["Primary VPC 1 - Primary1 Subnet 1"]
  user                       = "ITX-DMX"
  vpc_filter                 = "Primary VPC 1"
  vpcxEnvironment            = "DEV"
  env                        = "QA"
  wd                         = "1"
  wd_host_name               = ["wdsah"]
  IAC_org                    = var.IAC_org
}
