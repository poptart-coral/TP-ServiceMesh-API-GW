variable "nodes" {
  description = "Liste des VMs à créer avec leurs configurations qui seront des nodes Kubernetes"
  type = map(object({
    host_node     = string
    datastore_id  = optional(string, "gryffondor-pool")
    ip            = string
    mac_address   = string
    vm_id         = number
    cpu           = number
    ram_dedicated = number
    gateway       = optional(string, "162.38.112.254")
    machine_type  = string
  }))
}

variable "cluster" {
  description = "values for the cluster configuration"
  type = object({
    name            = string
    endpoint        = string
    talos_version   = string
    proxmox_cluster = optional(string, "gryffondor")
  })
}

variable "cilium" {
  description = "Cilium configuration"
  type = object({
    values  = string
    install = string
  })
}