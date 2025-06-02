# TP-monitoring

# Pré-requis

Pour chacun des trois TP, voici les pré-requis détaillés incluant l'installation d'un cluster Kubernetes via un outil d'Infrastructure as Code :

## Prérequis communs aux TP

Avant de commencer l'un de ces TP, les étudiants devront avoir mis en place un cluster Kubernetes fonctionnel en utilisant l'un des outils d'Infrastructure as Code suivants (au choix) :

### Option : Terraform

- Installation de Terraform
- Création d'un module Terraform pour déployer un cluster Kubernetes
- Documentation du processus et des variables utilisées

### Exigences minimales pour le cluster

- Version Kubernetes : 1.29+
- Minimum 3 nœuds worker (2 vCPU, 4 Go RAM chacun)
- Système de stockage persistant configuré (CSI)
- Accès administrateur au cluster
- kubectl configuré et fonctionnel
- Metrics Server installé
- Réseau CNI fonctionnel avec support pour les Network Policies

Le tout sera déployé sur l’infra OpenStack de Polytech.

Les étudiants devront fournir la documentation de leur processus d'installation, y compris :

- Code source IaC utilisé
- Journal des problèmes rencontrés et solutions appliquées
- Commandes de vérification démontrant que le cluster est opérationnel
- Architecture du cluster (schéma)

Cette approche permet aux étudiants de choisir l'outil avec lequel ils sont le plus à l'aise, tout en assurant une expérience pratique avec l'Infrastructure as Code avant de se plonger dans les sujets avancés des TP.

## TP : Kubernetes Gateway API et Service Mesh

### Objectif: Explorer la nouvelle Gateway API de Kubernetes et son intégration avec un service mesh.

Contenu:

- Mise en place d’une Gateway API OSS
- Configuration avancée de routing avec HTTPRoute, TCPRoute
- Implémentation de stratégies de trafic et sécurité via les Policy Attachments
- Demo d’une application maison pour expliciter le gain d’un service mesh
- Observation et debugging avec les outils du service mesh

	
