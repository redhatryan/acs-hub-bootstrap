#!/bin/bash

LANG=C
SLEEP_SECONDS=30

echo ""

echo "Installing policies on ACM hub to bootstrap DevSecOps"

kustomize build components/policies/devsecops --enable-alpha-plugins | oc apply -f -