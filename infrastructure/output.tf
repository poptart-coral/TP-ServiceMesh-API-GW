resource "local_file" "machine_configs" {
  for_each        = module.Popoter.machine_config
  content         = each.value.machine_configuration
  filename        = "output/talos-machines-config-${each.key}.yaml"
  file_permission = "0600"
}

resource "local_file" "talos_config" {
  content         = module.Popoter.client_configuration.talos_config
  filename        = "output/talos-config.yaml"
  file_permission = "0600"
}

resource "local_file" "kube_config" {
  content         = module.Popoter.kube_config.kubeconfig_raw
  filename        = "output/kube-config.yaml"
  file_permission = "0600"
}

output "kube_config" {
  value     = module.Popoter.kube_config.kubeconfig_raw
  sensitive = true
}

output "talos_config" {
  value     = module.Popoter.client_configuration.talos_config
  sensitive = true
}