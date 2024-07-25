################################################################################
# ZOOKEEPER VARIABLES
################################################################################

variable "zookeeper_version" {
  type        = string
  description = "Zookeeper version to use in the infrastructure"
  default     = "3.7.2"
}

variable "zookeeper_home" {
  type        = string
  description = "Zookeeper home directory"
  default     = "/usr/local/zookeeper"
}

variable "zookeeper_data_dir" {
  type        = string
  description = "Zookeeper data directory"
  default     = "/var/lib/zookeeper"
}

variable "zookeeper_java_home" {
  type        = string
  description = "Java home directory"
  default     = "/usr/lib/jvm/java-1.8.0"
}
