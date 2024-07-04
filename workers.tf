################################################################################
# HBASE WORKERS GROUP
################################################################################

data "tencentcloud_images" "hbase_workers_image" {
  count            = var.workers_image_id != "" ? 0 : 1
  image_type       = var.workers_image_type
  image_name_regex = var.workers_image_name_regex
}

resource "tencentcloud_instance" "hbase_workers_node" {
  count             = var.workers_instance_count
  instance_name     = "${var.workers_instance_name}-${count.index}"
  availability_zone = var.subnet_cidrs != [] ? var.subnet_cidrs[count.index % length(var.subnet_cidrs)].availability_zone : var.workers_availability_zone
  image_id          = var.workers_image_id != "" ? var.workers_image_id : data.tencentcloud_images.hbase_workers_image[0].image_id
  instance_type     = var.workers_instance_type

  system_disk_type = var.workers_system_disk_type
  system_disk_size = var.workers_system_disk_size

  hostname   = "${var.workers_instance_name}-${count.index}"
  project_id = var.workers_instance_project
  vpc_id     = var.create_vpc ? tencentcloud_vpc.vpc[0].id : var.vpc_id
  subnet_id  = var.subnet_cidrs != [] ? values(tencentcloud_subnet.subnet)[count.index % length(values(tencentcloud_subnet.subnet))].id : var.workers_subnet_id

  instance_charge_type                = var.workers_instance_charge_type
  instance_charge_type_prepaid_period = var.workers_instance_charge_type_prepaid_period
  # instance_charge_type_prepaid_renew_flag = var.instance_charge_type_prepaid_renew_flag

  data_disks {
    data_disk_type = var.workers_data_disk_type
    data_disk_size = var.workers_data_disk_size
    encrypt        = var.workers_data_disk_encrypt
  }

  force_delete = var.workers_force_delete
  tags         = var.workers_instance_tags
}

resource "tencentcloud_security_group" "hbase_workers_sg" {
  name        = var.workers_instance_name
  description = "Hbase workers node security group"
  tags        = var.workers_instance_tags
}

resource "tencentcloud_security_group_rule_set" "hbase_workers_sg_rule" {
  security_group_id = tencentcloud_security_group.hbase_workers_sg.id

  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    description = "Allow all egress traffic"
  }
}
