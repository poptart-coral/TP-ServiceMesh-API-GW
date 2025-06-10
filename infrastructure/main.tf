module "Popoter" {
  source = "./Popoter"

  providers = {
    proxmox = proxmox
  }

  cluster = {
    name          = "kuboter"
    endpoint      = "162.38.112.159"
    talos_version = "v1.10.0"
  }

  cilium = {
    install = file("${path.module}/Popoter/inline-manifests/cilium-install.yaml")
    values = file("${path.module}/Popoter/inline-manifests/cilium-values.yaml")
  }

  nodes = {
    "poptart-controller-1" = {
      host_node     = "gryffondor-1"
      ip            = "162.38.112.159"
      mac_address   = "BC:24:11:2E:C8:00"
      vm_id         = 11112000
      cpu           = 4
      ram_dedicated = 8192
      machine_type  = "controlplane"
    }
    "poptart-worker-1" = {
      host_node     = "gryffondor-2"
      ip            = "162.38.112.226"
      mac_address   = "BC:24:11:2E:C8:01"
      vm_id         = 11112001
      cpu           = 4
      ram_dedicated = 8192
      machine_type  = "worker"
    }
    // quand tout marchera (cluster qui marche etc, tout paramétré), déployer ensuite ces VMs là
    // add poptart-worker-2 : ip address = 162.38.112.155 (mais VM de Giada à éteindre) vm_id = 11112002 sur gryffondor-3
    // add poptart-worker-3 : ip address = 162.38.112.227 vm_id = 11112003 sur gryffondor-1
  }
}
