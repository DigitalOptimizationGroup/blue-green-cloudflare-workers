#!/bin/bash
source .env

init(){
  cd cloudflare && terraform init \
  && cd records && terraform init \
  && cd ../workers/blue && terraform init \
  && cd ../green && terraform init \
  && cd ../proxy && terraform init
}

setup_cloudflare(){
  cd cloudflare && \
	TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
	TF_VAR_proxy_domain=${PROXY_DOMAIN} \
  TF_VAR_blue_domain=${BLUE_DOMAIN} \
  TF_VAR_green_domain=${GREEN_DOMAIN} \
  TF_VAR_default_origin=${DEFAULT_ORIGIN} \
  terraform apply
}

records(){
  cd cloudflare/records && \
	TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  terraform apply
}

deploy_worker(){
  if [[ $1 == "blue" || $1 == "green" ]]; then
    COLOR=$1 npm run build-worker \
    && cd cloudflare/workers/${1} \
    && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
    TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
    terraform apply
  else
      echo "You must call this function with a color (blue or green). Try again with ./commands.sh deploy_worker blue/green"
      exit 1
  fi
}

deploy_proxy(){
  npm run build-proxy \
  && cd cloudflare/workers/proxy \
  && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  terraform apply
}

destroy_cloudflare(){
  cd cloudflare &&
  TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
	TF_VAR_proxy_domain=${PROXY_DOMAIN} \
  TF_VAR_blue_domain=${BLUE_DOMAIN} \
  TF_VAR_green_domain=${GREEN_DOMAIN} \
  TF_VAR_default_origin=${DEFAULT_ORIGIN} \
  terraform destroy
}

destroy_blue(){
  cd cloudflare/workers/blue &&
  TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  terraform destroy
}

destroy_green(){
  cd cloudflare/workers/green &&
  TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  terraform destroy
}

destroy_proxy(){
  cd cloudflare/workers/proxy &&
  TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  terraform destroy
}

destroy_records(){
  cd cloudflare/records &&
  TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  terraform destroy
}

destroy_all(){
  destroy_blue \
  && destroy_green \
  && destroy_proxy \
  && destroy_records \
  && destroy_cloudflare
}

"$@"

# use 
# chmod u+x commands.sh
# ./commands.sh test
# . commands.sh -> then can just call functions