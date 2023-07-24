#!/bin/bash

github_raw_url="https://raw.githubusercontent.com/$GIT_REPO/${TARGET_BRANCH#refs/heads/}/$CONFIG_FILE_PATH"
file_content=$(curl -sS $github_raw_url)

required_keys=("config.name")

for required_key in "${required_keys[@]}"; do
  if ! echo "$file_content" | yq eval ".${required_key}" - > /dev/null; then
    echo "Error: The specified key \"$required_key\" does not exist"
    exit 1
  fi
done