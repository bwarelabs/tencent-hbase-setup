locals {
  hdfs_setup_datanodes_file = "/scripts/hdfs/3-hdfs-setup-datanodes.sh"
}

resource "tencentcloud_tat_command" "hdfs-setup-workernodes" {
  command_name      = "1-worker-hdfs-setup-datanodes"
  content           = file(join("", [path.module, local.hdfs_setup_datanodes_file]))
  description       = "Install and configure the HDFS datanodes settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hadoop_version" : var.hadoop_version,
    "hadoop_home" : var.hadoop_home,
    "namenodes_ips" : local.hdfs_namenodes_ips,
  })
}
