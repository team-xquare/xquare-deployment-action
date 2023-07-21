#!/bin/bash

function clone_config_file() {
  clone_path="/tmp/clone/$(uuidgen)"
  git clone --depth 1 --branch $TARGET_BANCH $GIT_URL $clone_path

  # Check if the repository was successfully cloned
  if [ $? -ne 0 ]; then
    echo "Error: Failed to clone the repository."
    exit 1
  fi

  # Read the content of the file
  file_path="$clone_path/$CONFIG_FILE_PATH"

  if [ -f "$file_path" ]; then
    cat "$file_path"
  else
    echo "Error: The specified file does not exist."
    exit 1
  fi
  return "$clone_path" "$file_path"
}

function check_required_key() {
  # Check if the required config keys exist in the YAML file by yq
  sudo apt update
  sudo apt install -y yq

  required_keys=("config.name" "config.imageTag" "config.containerPort" "config.prefix")

  # $1 = first arg = file_path
  for required_key in "${required_keys[@]}"; do
    if ! yq eval ".\"${required_key}\"" "$1" &> /dev/null; then
      echo "Error: The specified key \"$required_key\" does not exist"
      exit 1
    fi
  done
}

result=($(clone_config_file))
clone_path=result[0]
file_path=result[1]
check_required_key $file_path

# Return config files content
cat $file_path

# Remove tmp clone directory
rm -rf $clone_path
