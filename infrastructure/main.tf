terraform {
  required_providers {
    proxmox = {
      source  = "thegameprofi/proxmox"
      version = ">= 2.10.0"
    }
  }
  required_version = ">= 1.5"
}

provider "proxmox" {
  pm_api_url          = "https://162.38.112.67:8006/api2/json" # URL de l'API Proxmox
  pm_api_token_id     = "terraform-prov@pve!terraform"         # ID du token API (terraform-prov@pve!terraform)
  pm_api_token_secret = var.pm_api_token_secret                # Token API Proxmox
  pm_tls_insecure     = true
}

variable "pm_api_token_secret" {
  description = "Token API Proxmox pour l'utilisateur terraform-prov@pve"
  type        = string
  sensitive   = true
}

variable "ci_pwd" {
  description = "Mot de passe pour l'utilisateur Cloud-Init (pop)"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nom du nœud Proxmox où on va créer les VMs"
  type        = string
  default     = "gryffondor-1"
}

variable "template_id" {
  description = "VMID du template Cloud-Init existant (avec QEMU-Guest Agent, cloud-init, swap off, etc.)"
  type        = number
  default     = 113
}

variable "storage_name" {
  description = "Storage Proxmox pour les disques (Gryffondor-Pool)"
  type        = string
  default     = "gryffondor-pool"
}

variable "ssh_public_key" {
  description = "Clé SSH publique à injecter dans chaque VM (Cloud-Init)"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICiUx+gC8DLBTi76OnNd1cbflGG3cNToeN5Gqbd6aGRy giada.de-martino@etu.umontpellier.fr"
}

locals {
  vmids = [11112000, 11112001, 11112002, 11112003] # VMIDs des VMs à créer
  public_ips = {
    0 = "162.38.112.159" # IP publique du master dans Gryffondor-1
    1 = "162.38.112.155" # IP publique du premier worker dans Gryffondor-2
    2 = "162.38.112.226" # IP publique du deuxième worker dans Gryffondor-3
    3 = "162.38.112.227" # IP publique du troisième worker dans Gryffondor-1
  }
  node_names = ["gryffondor-1", "gryffondor-2", "gryffondor-3", "gryffondor-1"] # Noms des nœuds Proxmox où les VMs seront créées respectivement
  template_ids = [
    "poptart-cloud-init-template",   # ID du template pour le master dans Gryffondor-1
    "poptart-cloud-init-template-2", # ID du template pour le premier worker dans Gryffondor-2
    "poptart-cloud-init-template-3", # ID du template pour le deuxième worker dans Gryffondor-3
    "poptart-cloud-init-template"    # ID du template pour le troisième worker dans Gryffondor-1
  ]

  # template_ids = [
  #   "113", # ID du template pour le master dans Gryffondor-1
  #   "11112004", # ID du template pour le premier worker dans Gryffondor-2
  #   "11112005", # ID du template pour le deuxième worker dans Gryffondor-3
  #   "113" # ID du template pour le troisième worker dans Gryffondor-1
  # ]
}

resource "proxmox_vm_qemu" "k8s_node" {
  count = length(local.vmids)      # Crée une VM pour chaque ID dans local.vmids
  vmid  = local.vmids[count.index] # Utilise l'index du count pour assigner le VMID de manière à ce que chaque VM ait un VMID unique situé dans local.vmids

  name = (
    count.index == 0 ?          # C'est le master Kubernetes
    "k8s-master" :              # Dans ce cas, le nom de la VM sera "k8s-master"
    "k8s-worker-${count.index}" # Sinon, c'est un worker, donc le nom sera "k8s-worker-1", "k8s-worker-2", etc.
  )

  target_node = local.node_names[count.index]   # Utilise le nom du nœud Proxmox correspondant à l'index de la VM
  clone       = local.template_ids[count.index] # Clone le template correspondant à l'index de la VM
  full_clone  = true                            # Utilise un clone complet pour chaque VM
  os_type     = "cloud-init"                    # Type d'OS pour les VMs, ici c'est Cloud-Init

  cores  = 2
  memory = 4096

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  ciuser     = "pop"              # Utilisateur Cloud-Init
  cipassword = var.ci_pwd         # Mot de passe pour l'utilisateur Cloud-Init
  sshkeys    = var.ssh_public_key # Clé SSH publique à injecter dans chaque VM

  # Configuration Cloud-Init pour chaque VM
  cicustom = <<EOF
#cloud-config
hostname: ${count.index == 0 ? "k8s-master" : "k8s-worker-${count.index}"}
ssh_authorized_keys:
  - ${var.ssh_public_key}
manage_etc_hosts: true
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - ${lookup(local.public_ips, count.index)}/24
      gateway4: 162.38.112.254
      nameservers:
        addresses:
          - 8.8.8.8
EOF
}

output "master_public_ip" {
  description = "IP publique du master Kubernetes"
  value       = lookup(local.public_ips, 0) # IP publique du master
}

output "workers_public_ips" {
  description = "Liste des IP publiques des 3 workers"
  value = [
    lookup(local.public_ips, 1), # IP publique du premier worker
    lookup(local.public_ips, 2), # IP publique du deuxième worker
    lookup(local.public_ips, 3), # IP publique du troisième worker
  ]
}
