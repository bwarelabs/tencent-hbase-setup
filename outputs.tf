locals {
  total_storage_gb = var.workers_instance_count * var.workers_data_disk_count * var.workers_data_disk_size
}

output "list_price" {
  value = {
    masternodes_cost   = var.management_instance_count * 302
    zookeeper_cost     = var.zookeeper_instance_count * 115
    workernodes_cost   = var.workers_instance_count * 302
    worker_disks_cost  = var.workers_instance_count * var.workers_data_disk_count * 313
    rpc_node_cost      = 166
    archive_cost       = local.total_storage_gb * 1024 * 0.0025
    total_cost         = (
      (var.management_instance_count * 302) +
      (var.zookeeper_instance_count * 115) +
      (var.workers_instance_count * 302) +
      (var.workers_instance_count * var.workers_data_disk_count * 313) +
      166 +
      (local.total_storage_gb * 1024 * 0.0025)
    )
  }
}
