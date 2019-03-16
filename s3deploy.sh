#!/bin/bash
source .env


init(){
  cd cloudflare/aws_s3_bucket && terraform init \
  && cd ../s3_workers/blue && terraform init \
  && cd ../green && terraform init \
  && cd ../proxy && terraform init
}

build_s3_bucket(){
  cd cloudflare/aws_s3_bucket \
  && TF_VAR_bucket_name=${S3_BUCKET_NAME} \
  terraform apply
}

build_s3_bucket_with_versioning(){
  cd cloudflare/aws_s3_bucket \
  && TF_VAR_bucket_name=${S3_BUCKET_NAME} \
  && TF_VAR_versioning=true \
  terraform apply
}

save_worker_to_s3(){
    aws s3 ls s3://${S3_BUCKET_NAME}/workers/v${WORKER_VERSION}/worker.js
    if [[ $? -ne 0 ]]; then
        aws s3 cp ./dist/worker.js s3://${S3_BUCKET_NAME}/workers/v${WORKER_VERSION}/worker.js --content-type text/plain
    else
      echo -n "

This version already exists on S3. If this should be a new release,
then bump the version in your .env file and try again. 

Whould you like to deploy version ${WORKER_VERSION}? 
Only 'yes' will be accepted.

Enter a value: "
      read reply </dev/tty

      if [ -z "$reply" ]; then
        reply=no
      fi

      if [ $reply == yes ]; then
        echo "Attempting to deploy version ${WORKER_VERSION}"
      else
        echo "Deploy cancelled"
        exit 1
      fi
    fi
}

save_proxy_to_s3(){
    aws s3 ls s3://${S3_BUCKET_NAME}/workers/v${PROXY_VERSION}/worker_proxy.js
    if [[ $? -ne 0 ]]; then
  	    aws s3 cp ./dist/worker_proxy.js s3://${S3_BUCKET_NAME}/proxy_worker/v${PROXY_VERSION}/worker_proxy.js --content-type text/plain
    else
      echo -n "

This version already exists on S3. If this should be a new release,
then bump the version in your .env file and try again. 

Whould you like to deploy proxy version ${PROXY_VERSION}? 
Only 'yes' will be accepted.

Enter a value: "
      read reply </dev/tty

      if [ -z "$reply" ]; then
        reply=no
      fi

      if [ $reply == yes ]; then
        echo "Attempting to deploy proxy version ${PROXY_VERSION}"
      else
        echo "Deploy cancelled"
        exit 1
      fi
    fi
}

deploy_worker(){
  if [[ $1 == "blue" || $1 == "green" ]]; then
    COLOR=$1 npm run build-worker \
    && save_worker_to_s3 \
    && cd cloudflare/workers/${1} \
    && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
    TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
    TF_VAR_worker_s3_key=workers/v${WORKER_VERSION}/worker.js \
    terraform apply
  else
      echo "You must call this function with a color (blue or green). Try again with ./commands.sh deploy_worker blue/green"
      exit 1
  fi
}

deploy_proxy(){
  npm run build-proxy \
  && save_proxy_to_s3 \
  && cd cloudflare/workers/proxy \
  && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  TF_VAR_worker_s3_key=proxy_worker/v${PROXY_VERSION}/worker_proxy.js \
  terraform apply
}


destroy_blue(){
  cd cloudflare/s3_workers/blue \
  && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  TF_VAR_worker_s3_key=workers/v${WORKER_VERSION}/worker.js \
  terraform destroy
}

destroy_green(){
  cd cloudflare/s3_workers/green \
  && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  TF_VAR_worker_s3_key=workers/v${WORKER_VERSION}/worker.js \
  terraform destroy
}

destroy_proxy(){
  cd cloudflare/s3_workers/proxy \
  && TF_VAR_cloudflare_email=${ACCOUNT_EMAIL} \
  TF_VAR_cloudflare_token=${ACCOUNT_AUTH_KEY} \
  TF_VAR_worker_s3_key=proxy_worker/v${PROXY_VERSION}/worker_proxy.js \
  terraform destroy
}

destroy_s3_bucket(){
  cd cloudflare/aws_s3_bucket \
  && TF_VAR_bucket_name=${S3_BUCKET_NAME} \
  terraform destroy
}

destroy_all(){
  destroy_blue \
  && destroy_green \
  && destroy_proxy \
  && destroy_s3_bucket
}

"$@"