#!/bin/bash

LANG=C
SLEEP_SECONDS=30

echo ""

echo "Update DNS (permanent solution coming soon)"

kustomize build github.com/redhatryan/cluster-config/components/dns | oc apply -f -

echo "Installing secrets on local ACS hub to bootstrap ACS with"

kustomize build bootstrap/secrets/base | oc apply -f -

echo "Proceed to import the ACS Hub (acs-hub) into the RHACM hub cluster"