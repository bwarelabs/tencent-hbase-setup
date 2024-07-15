################################################################################
# ZOOKEEPER GROUP
################################################################################

data "tencentcloud_images" "zookeeper_image" {
  count            = var.zookeeper_image_id != "" ? 0 : 1
  image_type       = var.zookeeper_image_type
  image_name_regex = var.zookeeper_image_name_regex
}

resource "tencentcloud_instance" "zookeeper_node" {
  count             = var.zookeeper_instance_count
  instance_name     = "${var.zookeeper_instance_name}-${count.index}"
  availability_zone = var.subnet_cidrs != [] ? var.subnet_cidrs[count.index % length(var.subnet_cidrs)].availability_zone : var.zookeeper_availability_zone
  image_id          = var.zookeeper_image_id != "" ? var.zookeeper_image_id : data.tencentcloud_images.zookeeper_image[0].image_id
  instance_type     = var.zookeeper_instance_type

  system_disk_type = var.zookeeper_system_disk_type
  system_disk_size = var.zookeeper_system_disk_size

  hostname   = "${var.zookeeper_instance_name}-${count.index}"
  project_id = var.zookeeper_instance_project
  vpc_id     = var.create_vpc ? tencentcloud_vpc.vpc[0].id : var.vpc_id
  subnet_id  = var.subnet_cidrs != [] ? values(tencentcloud_subnet.subnet)[count.index % length(values(tencentcloud_subnet.subnet))].id : var.zookeeper_subnet_id

  instance_charge_type                = var.zookeeper_instance_charge_type
  instance_charge_type_prepaid_period = var.zookeeper_instance_charge_type_prepaid_period
  # instance_charge_type_prepaid_renew_flag = var.zookeeper_instance_charge_type_prepaid_renew_flag

  data_disks {
    data_disk_type = var.zookeeper_data_disk_type
    data_disk_size = var.zookeeper_data_disk_size
    encrypt        = var.zookeeper_data_disk_encrypt
  }

  force_delete = var.zookeeper_force_delete
  tags         = var.zookeeper_instance_tags
}

resource "tencentcloud_security_group" "zookeeper_sg" {
  name        = var.zookeeper_instance_name
  description = "Zookeeper node security group"
  tags        = var.zookeeper_instance_tags
}

resource "tencentcloud_security_group_rule_set" "zookeeper_sg_rule" {
  security_group_id = tencentcloud_security_group.zookeeper_sg.id

  egress {
    action      = "ACCEPT"
    cidr_block  = "0.0.0.0/0"
    description = "Allow all egress traffic"
  }
}
