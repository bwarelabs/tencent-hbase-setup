################################################################################
# HBASE MANAGEMENT GROUP IMAGE VARIABLES
################################################################################

variable "management_image_id" {
  type        = string
  description = "The Hbase managemen node image id, if this is provided then it will override other image parameters below"
  default     = "img-eb30mz89"
}

variable "management_image_type" {
  type        = list(string)
  description = "The Hbase managemen node image type, this parameter and management_image_name_regex are used only if image_id is set to empty value"
  default     = ["PUBLIC_IMAGE"]
}

variable "management_image_name_regex" {
  type        = string
  description = "The Hbase managemen node image id, if this is provided then it will override other image parameters below"
  default     = "Solana"
}

################################################################################
# HBASE MANAGEMENT GROUP INSTANCE VARIABLES
################################################################################

variable "management_instance_count" {
  type        = number
  description = "The number of Hbase management nodes to bootstrap"
  default     = 2
}

variable "management_instance_name" {
  type        = string
  description = "The instace management name prefix"
  default     = "hbase-management"
}

variable "management_instance_project" {
  type        = number
  description = "The project the instance belongs to"
  default     = 0
}

variable "management_instance_type" {
  type        = string
  description = "The instace type"
  default     = "SA5.MEDIUM4"
}

variable "management_instance_charge_type" {
  type        = string
  description = "The charge type of instance"
  default     = "POSTPAID_BY_HOUR"
}

variable "management_instance_charge_type_prepaid_period" {
  type        = number
  description = "The tenancy (time unit is month) of the prepaid instance"
  default     = 1
}

variable "management_instance_charge_type_prepaid_renew_flag" {
  type        = string
  description = "Auto renewal flag"
  default     = "NOTIFY_AND_MANUAL_RENEW"
}

variable "management_force_delete" {
  type        = bool
  description = "Indicate whether to force delete the instance"
  default     = false
}

variable "management_subnet_id" {
  type        = string
  description = "The subnet id for the instance"
  default     = ""
}

variable "management_availability_zone" {
  type        = string
  default     = "The instance availability zone"
  description = ""
}

variable "management_instance_tags" {
  type        = map(string)
  description = "Specify one or more tags for the instance"
  default = {
    "network" : "tencent",
    "type" : "management",
  }
}

################################################################################
# HBASE MANAGEMENT GROUP INSTANCE DISKS
################################################################################

variable "management_system_disk_type" {
  type        = string
  description = "The instace system disk type"
  default     = "CLOUD_BSSD"
}

variable "management_system_disk_size" {
  type        = number
  description = "The instace system disk size"
  default     = 50
}

# DATA DISK
variable "management_data_disk_type" {
  type        = string
  description = "The instace data disk type"
  default     = "CLOUD_BSSD"
}

variable "management_data_disk_size" {
  type        = number
  description = "The instace data disk size"
  default     = 50
}

variable "management_data_disk_encrypt" {
  type        = bool
  description = "Enable data disk encryption"
  default     = false
}
