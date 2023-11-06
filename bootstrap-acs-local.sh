#!/bin/bash

LANG=C
SLEEP_SECONDS=30

echo ""

echo "Installing secrets on local ACS hub to bootstrap ACS with"

kustomize build bootstrap/secrets/base | oc apply -f -