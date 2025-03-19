#!/bin/bash

PACKAGE_NAME=$1
VERSION=$2

if [ -z "$PACKAGE_NAME" ] || [ -z "$VERSION" ]; then
  echo "Usage: $0 <package_name> <version>"
  exit 1
fi

MAX_RETRIES=40
RETRY_COUNT=0

check_version() {
  RESPONSE=$(curl -s "https://pub.dev/api/packages/$PACKAGE_NAME")
  if echo "$RESPONSE" | grep -q "\"version\":\"$VERSION\""; then
    return 0
  else
    return 1
  fi
}

while true; do
  if check_version; then
    echo "Version $VERSION of package $PACKAGE_NAME is available."
    exit 0
  else
    ((RETRY_COUNT++))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
      echo "Version $VERSION of package $PACKAGE_NAME is not available after $MAX_RETRIES attempts."
      exit 1
    fi
    echo "Version $VERSION of package $PACKAGE_NAME is not available. Checking again in 30 seconds..."
    sleep 30
  fi
done
