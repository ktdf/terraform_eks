variable "cluster_subnets" {
  description = "List of cluster subnets"
  type        = list(string)
  default     = []
}

variable "node_subnets" {
  description = "List of cluster subnets"
  type        = list(string)
  default     = []
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type = string
  default = "testcluster"
}

variable "node_group_size" {
  description = "Size for the node group"
  type        = map(string)
  default = {
    "desired" = 2,
    "min"     = 1,
    "max"     = 2
  }

}

variable "addons" {
  description = "List of eks addon to be installed"
  type        = list(string)
  default = [
    "coredns",
    "kube-proxy",
    "vpc-cni"
  ]
}