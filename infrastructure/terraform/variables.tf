variable "public_key_path" {
  description = "Path to public key file"
  default     = "metadata/cloud-ssh.pub"
}

variable "user_data_path" {
	default = "metadata/userdata"
}

variable "service_account_key_file" {
	#default = "~/key.json"
}

variable "folder_id" {
	default = "b1g3a65ovr0uv7n30pq7"
}

variable "cluster_size_app" {
	default = 2
}

variable "instance_cores_app" {
	default = 2
}

variable "instance_memory_app" {
	default = 1
}

variable "instance_core_fraction_app" {
	default = 20
}

variable "instance_dist_size_app" {
	default = 8
}

variable "cluster_size_mon" {
	default = 1
}

variable "instance_cores_mon" {
	default = 2
}

variable "instance_memory_mon" {
	default = 1
}

variable "instance_core_fraction_mon" {
	default = 20
}

variable "instance_dist_size_mon" {
	default = 8
}

variable "cluster_size_lb" {
	default = 1
}

variable "instance_cores_lb" {
	default = 2
}

variable "instance_memory_lb" {
	default = 1
}

variable "instance_core_fraction_lb" {
	default = 20
}

variable "instance_dist_size_lb" {
	default = 8
}

variable "network_id" {
	default = "enp9rcra9bopd5msuias"
}

variable "cird_net_block" {
	default = 10
}
