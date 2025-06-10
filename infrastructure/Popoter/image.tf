resource "proxmox_virtual_environment_download_file" "this" {
  for_each     = toset([for k, v in var.nodes : v.host_node])
  node_name    = split("_", each.key)[0]
  content_type = "iso"
  datastore_id = "local"

  file_name = "talos-cloud-init.img"
  url       = "https://factory.talos.dev/image/6ddf854fae73bd73caab1a49c6e5bf7bbbc6829d5352f8a8ff414ba979599050/v1.10.0/nocloud-amd64.raw.gz"

  decompression_algorithm = "gz"
  overwrite               = false

  lifecycle {
    prevent_destroy = true
  }
}
