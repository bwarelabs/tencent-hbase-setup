locals {
  hdfs_setup_datanodes_file      = "/scripts/hdfs/3-hdfs-setup-datanodes.sh"
  hbase_setup_region_server_file = "/scripts/hbase/3-hbase-setup-region-server.sh"
  hbase_masters_ips              = join(",", [for ip in tencentcloud_instance.hbase_management_node[*].private_ip : "${ip}:16000"])
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

resource "tencentcloud_tat_command" "hbase-setup-region-servers" {
  command_name      = "3-hbase-setup-region-servers"
  content           = file(join("", [path.module, local.hbase_setup_region_server_file]))
  description       = "Install and configure the Hbase region servers settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hbase_version" : var.hbase_version,
    "hbase_home" : var.hbase_home,
    "zookeeper_ips" : local.hdfs_zookeeper_ips,
    "namenodes_ips" : local.hdfs_namenodes_ips,
    "hadoop_version" : var.hadoop_version,
    "hadoop_home" : var.hadoop_home,
    "hbase_masters_ips" : local.hbase_masters_ips,
  })
}
