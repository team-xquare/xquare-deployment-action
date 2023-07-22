#!/bin/bash

function check_required_key() {
  required_keys=("config.name" "config.prefix")
  # $1 = first arg = file_path
  for required_key in "${required_keys[@]}"; do
    if ! yq eval ".\"${required_key}\"" "$1" &> /dev/null; then
      echo "Error: The specified key \"$required_key\" does not exist"
      exit 1
    fi
  done
}

github_raw_url="https://raw.githubusercontent.com/$GIT_REPO/$TARGET_BANCH/$CONFIG_FILE_PATH"
file_path="/tmp/$(uuidgen)/config.yaml"
curl -sS $github_raw_url -o $file_path

check_required_key $file_path

rm $file_path
