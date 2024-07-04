################################################################################
# HBASE WORKER GROUP IMAGE VARIABLES
################################################################################

variable "workers_image_id" {
  type        = string
  description = "The Hbase worker node image id, if this is provided then it will override other image parameters below"
  default     = "img-eb30mz89"
}

variable "workers_image_type" {
  type        = list(string)
  description = "The Hbase worker node image type, this parameter and image_name_regex are used only if image_id is set to empty value"
  default     = ["PUBLIC_IMAGE"]
}

variable "workers_image_name_regex" {
  type        = string
  description = "The Hbase worker node image id, if this is provided then it will override other image parameters below"
  default     = "Solana"
}

################################################################################
# HBASE WORKER GROUP INSTANCE VARIABLES
################################################################################

variable "workers_instance_count" {
  type        = number
  description = "The number of Hbase worker nodes to bootstrap"
  default     = 2
}

variable "workers_instance_name" {
  type        = string
  description = "The instace name prefix"
  default     = "hbase-worker"
}

variable "workers_instance_project" {
  type        = number
  description = "The project the instance belongs to"
  default     = 0
}

variable "workers_instance_type" {
  type        = string
  description = "The instace type"
  default     = "SA5.MEDIUM4"
}

variable "workers_instance_charge_type" {
  type        = string
  description = "The charge type of instance"
  default     = "POSTPAID_BY_HOUR"
}

variable "workers_instance_charge_type_prepaid_period" {
  type        = number
  description = "The tenancy (time unit is month) of the prepaid instance"
  default     = 1
}

variable "workers_instance_charge_type_prepaid_renew_flag" {
  type        = string
  description = "Auto renewal flag"
  default     = "NOTIFY_AND_MANUAL_RENEW"
}

variable "workers_force_delete" {
  type        = bool
  description = "Indicate whether to force delete the instance"
  default     = false
}

variable "workers_subnet_id" {
  type        = string
  description = "The subnet id for the instance"
  default     = ""
}

variable "workers_availability_zone" {
  type        = string
  default     = "The instance availability zone"
  description = ""
}

variable "workers_instance_tags" {
  type        = map(string)
  description = "Specify one or more tags for the instance"
  default = {
    "network" : "tencent",
    "type" : "hbase",
  }
}

################################################################################
# HBASE WORKER GROUP INSTANCE DISKS
################################################################################

variable "workers_system_disk_type" {
  type        = string
  description = "The instace system disk type"
  default     = "CLOUD_BSSD"
}

variable "workers_system_disk_size" {
  type        = number
  description = "The instace system disk size"
  default     = 50
}

# DATA DISK
variable "workers_data_disk_type" {
  type        = string
  description = "The instace workers disk type"
  default     = "CLOUD_BSSD"
}

variable "workers_data_disk_size" {
  type        = number
  description = "The instace workers disk size"
  default     = 50
}

variable "workers_data_disk_encrypt" {
  type        = bool
  description = "Enable workers disk encryption"
  default     = false
}
