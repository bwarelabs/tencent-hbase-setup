locals {
  hdfs_setup_common_nodes_file = "/scripts/hdfs/1-hdfs-setup-common-nodes.sh"
  hdfs_setup_namenodes_file    = "/scripts/hdfs/2-hdfs-setup-namenodes.sh"
  hdfs_zookeeper_ips           = join(",", [for ip in tencentcloud_instance.zookeeper_node[*].private_ip : "${ip}:2181"])
  hdfs_zookeeper_ips_edits     = join(",", [for ip in tencentcloud_instance.zookeeper_node[*].private_ip : "${ip}:8485"])
  hdfs_namenodes_ips           = join(",", [for ip in tencentcloud_instance.hbase_management_node[*].private_ip : "${ip}"])
  hbase_setup_common_nodes     = "/scripts/hbase/1-hbase-setup-common-nodes.sh"
  hbase_setup_master           = "/scripts/hbase/2-hbase-setup-master.sh"

  management_instance_ips_ordered = [
    for idx in range(var.management_instance_count) :
    tencentcloud_instance.hbase_management_node[idx].private_ip
  ]
  management_instance_ips_string = join(",", local.management_instance_ips_ordered)

  workers_instance_ips_ordered = [
    for idx in range(var.workers_instance_count) :
    tencentcloud_instance.hbase_workers_node[idx].private_ip
  ]
  workers_instance_ips_string = join(",", local.workers_instance_ips_ordered)
}

resource "tencentcloud_tat_command" "hdfs-setup-common-nodes" {
  command_name      = "1-hadoop-hdfs-setup-common-nodes"
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
  command_name      = "2-management-hdfs-setup-namenodes"
  content           = file(join("", [path.module, local.hdfs_setup_namenodes_file]))
  description       = "Install and configure the HDFS namenodes settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hadoop_version" : var.hadoop_version,
    "hadoop_home" : var.hadoop_home,
    "zookeeper_ips" : local.hdfs_zookeeper_ips,
    "zookeeper_ips_edits" : local.hdfs_zookeeper_ips_edits,
    "namenodes_ips" : local.hdfs_namenodes_ips,
  })
}

resource "tencentcloud_tat_command" "hbase-setup-common-nodes" {
  command_name      = "1-hbase-setup-common-nodes"
  content           = file(join("", [path.module, local.hbase_setup_common_nodes]))
  description       = "Install and configure the HBASE common settings"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "hbase_version" : var.hbase_version,
    "hbase_home" : var.hbase_home,
    "java_home" : var.java_home,
    "management_ips" : local.management_instance_ips_string,
    "worker_ips" : local.workers_instance_ips_string,
    "management_instance_name" : var.management_instance_name,
    "workers_instance_name" : var.workers_instance_name,
  })
}

resource "tencentcloud_tat_command" "hbase-setup-master" {
  command_name      = "2-hbase-setup-master"
  content           = file(join("", [path.module, local.hbase_setup_master]))
  description       = "Install and configure the Hbase master settings"
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
