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

variable "java_home" {
  type        = string
  description = "Java home directory"
  default     = "/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.412.b08-2.tl3.x86_64"
}
