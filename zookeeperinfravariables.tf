################################################################################
# ZOOKEEPER GROUP IMAGE VARIABLES
################################################################################

variable "zookeeper_image_id" {
  type        = string
  description = "The Zookeeper node image id, if this is provided then it will override other image parameters below"
  default     = "img-eb30mz89"
}

variable "zookeeper_image_type" {
  type        = list(string)
  description = "The Zookeeper node image type, this parameter and zookeeper_image_name_regex are used only if image_id is set to empty value"
  default     = ["PUBLIC_IMAGE"]
}

variable "zookeeper_image_name_regex" {
  type        = string
  description = "The Zookeeper node image id, if this is provided then it will override other image parameters below"
  default     = "Solana"
}

################################################################################
# ZOOKEEPER GROUP INSTANCE VARIABLES
################################################################################

variable "zookeeper_instance_count" {
  type        = number
  description = "The number of Zookeeper nodes to bootstrap"
  default     = 3
}

variable "zookeeper_instance_name" {
  type        = string
  description = "The instace zookeeper name prefix"
  default     = "zookeeper"
}

variable "zookeeper_instance_project" {
  type        = number
  description = "The project the instance belongs to"
  default     = 0
}

variable "zookeeper_instance_type" {
  type        = string
  description = "The instace type"
  default     = "SA5.MEDIUM4"
}

variable "zookeeper_instance_charge_type" {
  type        = string
  description = "The charge type of instance"
  default     = "POSTPAID_BY_HOUR"
}

variable "zookeeper_instance_charge_type_prepaid_period" {
  type        = number
  description = "The tenancy (time unit is month) of the prepaid instance"
  default     = 1
}

variable "zookeeper_instance_charge_type_prepaid_renew_flag" {
  type        = string
  description = "Auto renewal flag"
  default     = "NOTIFY_AND_MANUAL_RENEW"
}

variable "zookeeper_force_delete" {
  type        = bool
  description = "Indicate whether to force delete the instance"
  default     = false
}

variable "zookeeper_subnet_id" {
  type        = string
  description = "The subnet id for the instance"
  default     = ""
}

variable "zookeeper_availability_zone" {
  type        = string
  default     = "The instance availability zone"
  description = ""
}

variable "zookeeper_instance_tags" {
  type        = map(string)
  description = "Specify one or more tags for the instance"
  default = {
    "network" : "tencent",
    "type" : "zookeeper",
  }
}

################################################################################
# ZOOKEEPER GROUP INSTANCE DISKS
################################################################################

variable "zookeeper_system_disk_type" {
  type        = string
  description = "The instace system disk type"
  default     = "CLOUD_BSSD"
}

variable "zookeeper_system_disk_size" {
  type        = number
  description = "The instace system disk size"
  default     = 50
}

# DATA DISK
variable "zookeeper_data_disk_type" {
  type        = string
  description = "The instace data disk type"
  default     = "CLOUD_BSSD"
}

variable "zookeeper_data_disk_size" {
  type        = number
  description = "The instace data disk size"
  default     = 50
}

variable "zookeeper_data_disk_encrypt" {
  type        = bool
  description = "Enable data disk encryption"
  default     = false
}
