variable "queue_names" {
  type="list"
}

variable "visibility_timeout" {
  default = 900
}

variable "delay_seconds" {
  default = 90
}

variable "max_message_size" {
  default = 2048
}

variable "message_retention_seconds" {
  default = 86400
}

variable "receive_wait_time_seconds" {
  default = 10
}

variable "policy" {
  default = ""
}

variable "queue_list" {
  
}

variable "fifo_queue" {
  default = false
}


variable "tags" {
  description = "Tags for Sqs "
  default     = {}
}

variable "queue_map" {
  default = ""
}

variable "tag_name" {
  default = ""
}

variable "tag_deployment" {
    default = ""

}

variable "tag_kubernetes_cluster" {
  default = ""

}

variable "tag_organisation" {
    default = ""

}

variable "tag_project" {
    default = ""

}


variable "tag_deployment_code" {
    default = ""

}


