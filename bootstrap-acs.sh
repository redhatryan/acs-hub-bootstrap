#!/bin/bash

LANG=C
SLEEP_SECONDS=30

echo ""

echo "Installing policies to bootstrap ACS"

kustomize build bootstrap/secrets/base | oc apply -f -
kustomize build bootstrap/policies/overlays/acs/bootstrap --enable-alpha-plugins | oc apply -f -
kustomize build bootstrap/policies/overlays/acs/base --enable-alpha-plugins | oc apply -f -

echo "Join acs-clusters ManagedClusterSet"
oc label managedcluster acs-hub cluster.open-cluster-management.io/clusterset=acs-clusters --overwrite=true

echo "Labeling cluster with 'gitops: local.acs'"
oc label managedcluster acs-hub acs-gitops=local.acs --overwrite=true