#!/bin/bash
set -euo pipefail

echo "Checking that su is disabled..."
if su root -c true 2>/dev/null; then
  echo "ERROR: su still works"
  exit 1
else
  echo "su is disabled as expected"
fi

echo "Checking that sudo is disabled..."
if sudo -n true 2>/dev/null; then
  echo "ERROR: sudo still works"
  exit 1
else
  echo "sudo is disabled as expected"
fi

echo "Checking firewall blocks example.com..."
if curl --connect-timeout 5 https://example.com >/dev/null 2>&1; then
  echo "ERROR: example.com is reachable"
  exit 1
else
  echo "Firewall correctly blocks example.com"
fi

echo "All validation checks passed."
