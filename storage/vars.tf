variable "AVAILABILITY_ZONE" {
  type = list(string)
}

variable "DEVICE_NAME" {
  default = "/dev/xvdh"
}

variable "VOLUME_NAME" {
  default = "volume1"
}

variable "INSTANCE_COUNT" {
}

variable "VOLUME_SIZE" {
  default = 10
}

