# Déploiement de l'infrastructure Kubernetes avec Terraform

Ce document décrit la mise en place de l'infrastructure du projet à l’aide de Terraform sur le cluster Proxmox Gryffondor.

## Structure du projet
```bash
.
├── main.tf
└── terraform.tfvars        
```

## Prérequis

- Terraform installé (version >= 1.5 recommandée)
- Connexion au réseau interne de Polytech (via VPN ou réseau local)
- Accès au cluster Proxmox Gryffondor
- Un utilisateur `terraform-prov@pve` avec un **token API** généré
- Ce token doit disposer d’un **rôle personnalisé** nommé `TerraformProv` avec les privilèges suivants :

```bash
  pveum role add TerraformProv -privs \
    "Datastore.Allocate Datastore.AllocateSpace Datastore.Audit \
     Pool.Allocate Sys.Audit Sys.Console Sys.Modify \
     VM.Allocate VM.Audit VM.Clone \
     VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk \
     VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options \
     VM.Console VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
```

Attribuer ensuite ce rôle à l’utilisateur et lui ajoute un token (jeton API)

```bash
  pveum aclmod / -user terraform-prov@pve -role TerraformProv
  pveum user token add terraform-prov@pve terraform -expire 0 -privsep 0 -comment "Terraform token"
```

## Déploiement

Depuis le dossier contenant les fichiers Terraform :

```bash
  terraform init
  terraform plan        # absolument vérifier le plan pour éviter toute erreur
  terraform apply
```

Cela crée 4 machines virtuelles réparties sur les nœuds du cluster Gryffondor :

- k8s-master : node maître, déployé sur gryffondor-1
- k8s-worker-1 : déployé sur gryffondor-2
- k8s-worker-2 : déployé sur gryffondor-3
- k8s-worker-3 : déployé sur gryffondor-1

## Description technique

### Templates

Chaque VM est clonée à partir d’un template Cloud-Init déjà présent sur les nœuds cibles Proxmox. Ces templates incluent :

- QEMU Guest Agent installé
- Cloud-Init activé
- Swap désactivé
- Disque système de 32 Go
- Utilisateur `pop` avec mot de passe défini via la variable `ci_pwd`
- Une clé SSH injectée

### Configuration des VMs

Chaque VM disposera de :

- 2 vCPU
- 4 Go de RAM
- 32 Go de disque
- Réseau virtuel configuré avec :
  - bridge : `vmbr0`
  - modèle : `virtio`
- Configuration Cloud-Init incluant :
  - Nom de machine (hostname)
  - Une clé SSH publique (`ssh_public_key`)
  - IP statique, DNS, passerelle

### Attributions d’adresses IP

Les adresses sont définies directement dans `main.tf`.

- k8s-master : 162.38.112.159
- k8s-worker-1 : 162.38.112.155
- k8s-worker-2 : 162.38.112.226
- k8s-worker-3 : 162.38.112.227

## Gestion des secrets

Les mots de passe et tokens doivent être définis via un fichier local non versionné (`terraform.tfvars`), ou via des variables d’environnement.

Exemple `terraform.tfvars` (à ne pas pousser sur Git) :

```bash
  ci_pwd              = "votre_mot_de_passe"
  pm_api_token_secret = "votre_token_secret"
```

Ou bien, dans votre terminal :

```bash
  export TF_VAR_ci_pwd="votre_mot_de_passe"
  export TF_VAR_pm_api_token_secret="votre_token_secret"
```

## Exemple .gitignore recommandé

```bash
# Terraform state
*.tfstate
*.tfstate.backup

# Sensitive tfvars files
terraform.tfvars

# Terraform dirs
.terraform/
.terraform.lock.hcl
```