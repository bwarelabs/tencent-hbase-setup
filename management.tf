################################################################################
# HBASE MANAGEMENT GROUP
################################################################################

data "tencentcloud_images" "hbase_management_image" {
  count            = var.management_image_id != "" ? 0 : 1
  image_type       = var.management_image_type
  image_name_regex = var.management_image_name_regex
}

resource "tencentcloud_instance" "hbase_management_node" {
  count             = var.management_instance_count
  instance_name     = "${var.management_instance_name}-${count.index}"
  availability_zone = var.subnet_cidrs != [] ? var.subnet_cidrs[count.index % length(var.subnet_cidrs)].availability_zone : var.management_availability_zone
  image_id          = var.management_image_id != "" ? var.management_image_id : data.tencentcloud_images.hbase_management_image[0].image_id
  instance_type     = var.management_instance_type

  system_disk_type = var.management_system_disk_type
  system_disk_size = var.management_system_disk_size

  hostname   = "${var.management_instance_name}-${count.index}"
  project_id = var.management_instance_project
  vpc_id     = var.create_vpc ? tencentcloud_vpc.vpc[0].id : var.vpc_id
  subnet_id  = var.subnet_cidrs != [] ? values(tencentcloud_subnet.subnet)[count.index % length(values(tencentcloud_subnet.subnet))].id : var.management_subnet_id

  instance_charge_type                = var.management_instance_charge_type
  instance_charge_type_prepaid_period = var.management_instance_charge_type_prepaid_period
  # instance_charge_type_prepaid_renew_flag = var.management_instance_charge_type_prepaid_renew_flag

  data_disks {
    data_disk_type = var.management_data_disk_type
    data_disk_size = var.management_data_disk_size
    encrypt        = var.management_data_disk_encrypt
  }

  force_delete = var.management_force_delete
  tags         = var.management_instance_tags
}

resource "tencentcloud_security_group" "hbase_management_sg" {
  name        = var.management_instance_name
  description = "Hbase management node security group"
  tags        = var.management_instance_tags
}

resource "tencentcloud_security_group_rule_set" "hbase_management_sg_rule" {
  security_group_id = tencentcloud_security_group.hbase_management_sg.id

  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    description = "Allow all egress traffic"
  }
}
