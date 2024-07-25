################################################################################
# HDFS VARIABLES
################################################################################

variable "hadoop_version" {
  type        = string
  description = "HADOOP version to use in the infrastructure"
  default     = "3.4.0"
}

variable "hadoop_home" {
  type        = string
  description = "HADOOP home directory"
  default     = "/usr/local/hadoop"
}

variable "hadoop_data_dir" {
  type        = string
  description = "HADOOP data directory"
  default     = "/var/lib/hadoop"
}

variable "java_home" {
  type        = string
  description = "Java home directory"
  default     = "/usr/lib/jvm/java-1.8.0"
}
