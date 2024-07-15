locals {
  hdfs_setup_common_nodes_file = "/scripts/hdfs/1-hdfs-setup-common-nodes.sh"
  hdfs_setup_namenodes_file    = "/scripts/hdfs/2-hdfs-setup-namenodes.sh"
  hdfs_setup_datanodes_file    = "/scripts/hdfs/3-hdfs-setup-datanodes.sh"
  hdfs_zookeeper_ips           = join(",", [for ip in tencentcloud_instance.zookeeper_node[*].private_ip : "${ip}:2181"])
}

resource "tencentcloud_tat_command" "hdfs-setup-common-nodes" {
  command_name      = "1-hdfs-setup-common-nodes"
  content           = file(join("", [path.module, local.hdfs_setup_common_nodes_file]))
  description       = "Install and configure the HDFS nodes common settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hadoop_version" : var.hadoop_version,
    "hadoop_home" : var.hadoop_home,
    "java_home" : var.java_home,
    "zookeeper_ips" : local.hdfs_zookeeper_ips,
  })
}

resource "tencentcloud_tat_command" "hdfs-setup-namenodes" {
  command_name      = "2-hdfs-setup-namenodes"
  content           = file(join("", [path.module, local.hdfs_setup_namenodes_file]))
  description       = "Install and configure the HDFS namenodes settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hadoop_home" : var.hadoop_home,
  })
}

resource "tencentcloud_tat_command" "hdfs-setup-datanodes" {
  command_name      = "3-hdfs-setup-datanodes"
  content           = file(join("", [path.module, local.hdfs_setup_datanodes_file]))
  description       = "Install and configure the HDFS datanodes settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hadoop_home" : var.hadoop_home,
  })
}
