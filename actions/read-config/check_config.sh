#!/bin/bash

cat "$CONFIG_FILE_PATH"
file_content=$(cat "$CONFIG_FILE_PATH" 2>&1)

if [ $? -ne 0 ]; then
    echo "Error: An error occurred while getting config file's content" 
    exit 1
fi

function readValue {
  echo "$file_content" | yq eval $1 -
}

# config 파일에 필요한 키가 존재하는지 여부 확인
required_keys=(".config.name" ".config.service_type" ".config.port")

for required_key in "${required_keys[@]}"; do
  if ! readValue "${required_key}"; then
    echo "Error: The specified key \"$required_key\" does not exist"
    exit 1
  fi
done

# service_domain 값이 존재하면서 .xquare.app으로 끝나지 않는 경우 에러
domain_key=".config.domain.$ENVIRONMENT"
domain_value=$(readValue "${domain_key}")

if [[ -z $domain_value && $domain_value != *.xquare.app && $domain_value != *.dsm-pick.com ]]; then
  echo "Error: The domain ($domain_value) does not end with '.xquare.app' or '.dsm-pick.com'."
  exit 1
fi

echo "name=$(readValue ".config.name")" >> $GITHUB_ENV
echo "prefix=$(readValue ".config.prefix")" >> $GITHUB_ENV
echo "domain=$(readValue "${domain_key}")" >> $GITHUB_ENV
echo "type=$(readValue ".config.service_type")" >> $GITHUB_ENV
echo "port=$(readValue ".config.port")" >> $GITHUB_ENV


endpoint="https://prod-server.xquare.app/merge/deploy"

service_type_uppercase=$(echo "$service_type" | tr '[:lower:]' '[:upper:]')

curl -X PUT "$endpoint" \
  -d "container_name=$container_name&service_type=$service_type_uppercase&prefix=$prefix&domain=$domain"