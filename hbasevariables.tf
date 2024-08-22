################################################################################
# HBASE VARIABLES
################################################################################

variable "hbase_version" {
  type        = string
  description = "HBASE version to use in the infrastructure"
  default     = "2.6.0"
}

variable "hbase_home" {
  type        = string
  description = "HBASE home directory"
  default     = "/usr/local/hbase"
}
