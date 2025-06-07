# Déploiement de l'infrastructure Kubernetes avec Terraform

Ce guide décrit pas à pas comment déployer un cluster Kubernetes Talos sur un cluster Proxmox **Gryffondor** à l’aide de Terraform.


## Structure du projet

```bash
.
├── README.md                       
└── infrastructure
    ├── README.md                    # Guide pour déployer l'infrastructure (cluster Kube dans Proxmox)
    ├── id_ed25519.pub               # Votre clé SSH publique (à ajouter vous-même)
    ├── main.tf                      # Point d’entrée Terraform, module Popoter
    ├── provider.tf                  # Déclaration des providers Terraform (Proxmox, Talos)
    ├── variables.tf                 # Variables globales (proxmox, nodes, cluster)
    ├── proxmox.auto.tfvars          # Valeurs sensibles pour Proxmox (en local, non commit)
    ├── output.tf                    # Outputs globaux vers `infrastructure/output/`
    ├── Popoter                      # Module Terraform principal
    │   ├── image.tf                 # Téléchargement du template Talos
    │   ├── virtual-machines.tf      # Définition des VMs Proxmox
    │   ├── talos.tf                 # Ressources Talos (bootstrap, health, kubeconfig)
    │   ├── variables.tf             # Variables du module (nodes, cluster)
    │   ├── provider.tf              # Provider mappings pour le module
    │   ├── output.tf                # Outputs du module (machine_config, kube_config…)
    │   └── machines-config
    │       ├── control-plane.yaml.tftpl  # Template Cloud-Init Talos pour les controlplanes
    │       └── worker.yaml.tftpl         # Template Cloud-Init Talos pour les workers
    └── output                       # Dossier généré après apply
        ├── talos-config.yaml        # Config Talos client générée
        ├── talos-machines-config-*.yaml  # Configs Talos pour chaque VM
        └── kube-config.yaml         # Kubeconfig pour se connecter au cluster

```

## 2. Prérequis

- Terraform ≥ 1.5  
- Accès réseau au cluster Proxmox Gryffondor (VPN ou LAN)  
- Un utilisateur Proxmox avec :  
  - Token API  
  - Rôle **TerraformProv** (privileges listés ci-dessous)  

```bash
pveum role add TerraformProv -privs \
  "Datastore.Allocate Datastore.AllocateSpace Datastore.Audit \
   Pool.Allocate Sys.Audit Sys.Console Sys.Modify \
   VM.Allocate VM.Audit VM.Clone \
   VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk \
   VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options \
   VM.Console VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

pveum aclmod / -user root@pam -role TerraformProv

pveum user token add root@pam terraform \
  -expire 0 -privsep 0 -comment "Terraform token"
```

- Clé SSH  
  Copiez votre clé publique dans `infrastructure/id_ed25519.pub`.  

## 3. Variables sensibles

Créez (hors Git) `infrastructure/proxmox.auto.tfvars` :

```hcl
proxmox = {
  name         = "gryffondor"
  cluster_name = "gryffondor"
  endpoint     = "https://162.38.112.67:8006"
  insecure     = true
  username     = "root"
  api_token    = "root@pam!A7gK_9z.x-F=token"
}
```

## 4. Déploiement

```bash
cd infrastructure
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519  # votre clé privée
terraform init
terraform plan   # Vérifier le plan
terraform apply  # Déployer le cluster
```

À l’issue, le dossier `infrastructure/output/` contiendra :
- `talos-config.yaml`
- `talos-machines-config-<nom-de-vm>.yaml` (pour chaque node)
- `kube-config.yaml`

## 5. Description rapide des modules
Module racine (main.tf)

Appelle le module ./Popoter

Passe la liste des nœuds, la configuration Proxmox et les paramètres de cluster Talos.

Module Popoter

image.tf : télécharge l’image Cloud-Init Talos pour chaque nœud.

virtual-machines.tf : crée/clône les VMs via le provider bpg/proxmox.

talos.tf : génère et applique les configs Talos, bootstrap le controlplane, vérifie la santé du cluster et génère le kubeconfig.

machines-config/ : templates pour controlplanes et workers (.tftpl).

output.tf : écrit les fichiers de config Talos et Kube dans infrastructure/output/.

