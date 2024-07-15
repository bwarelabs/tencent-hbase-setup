locals {
  zookeeper_setup = "/scripts/zookeeper/1-zookeeper-setup.sh"
  zookeeper_ips   = join(",", tencentcloud_instance.zookeeper_node[*].private_ip)
}

resource "tencentcloud_tat_command" "zookeeper-setup" {
  command_name      = "1-zookeeper-setup"
  content           = file(join("", [path.module, local.zookeeper_setup]))
  description       = "Install and configure the Zookeeper nodes"
  command_type      = "SHELL"
  timeout           = 1200
  username          = "root"
  working_directory = "/root"
  enable_parameter  = true
  default_parameters = jsonencode({
    "zookeeper_version" : var.zookeeper_version,
    "zookeeper_home" : var.zookeeper_home,
    "zookeeper_data_dir" : var.zookeeper_data_dir,
    "zookeeper_ips" : local.zookeeper_ips,
    "java_home" : var.java_home,
  })

  depends_on = [tencentcloud_instance.zookeeper_node]
}
