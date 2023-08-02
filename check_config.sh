#!/bin/bash

file_content=$(cat $CONFIG_FILE_PATH)

function readValue {
  echo "$file_content" | yq eval $1 -
}

# config 파일에 필요한 키가 존재하는지 여부 확인
required_keys=(".config.name" ".config.service_type")

for required_key in "${required_keys[@]}"; do
  if ! readValue "${required_key}"; then
    echo "Error: The specified key \"$required_key\" does not exist"
    exit 1
  fi
done

# service_domain 값이 존재하면서 .xquare.app으로 끝나지 않는 경우 에러
domain_key=".config.domain"
domain_value=$(readValue "${domain_key}")

if [[ -z $domain_value && $domain_value != *.xquare.app ]]; then
  echo "Error: The domain ($domain_value) does not end with '.xquare.app'."
  exit 1
fi

echo "name=$(readValue ".config.name")" >> $GITHUB_ENV
echo "prefix=$(readValue ".config.prefix")" >> $GITHUB_ENV
echo "domain=$(readValue ".config.domain")" >> $GITHUB_ENV
echo "type=$(readValue ".config.service_type")" >> $GITHUB_ENV
echo "port=$(readValue ".config.port")" >> $GITHUB_ENV
