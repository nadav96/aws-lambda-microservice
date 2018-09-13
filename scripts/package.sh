#!/bin/bash

stack_name_file="./package/stack_name.txt"
storage_bucket_name_file="./package/storage_bucket.txt"

if [ -f ${stack_name_file} ] && [ -f ${storage_bucket_name_file} ]; then
    stack_name=$(cat ${stack_name_file})
    bucket_name=$(cat ${storage_bucket_name_file})

    echo "Package details: Stack name:" ${stack_name} ", Storage bucket name:" ${bucket_name}

    sam package --template-file ./build/template.yaml --output-template-file ./build/packaged.yaml --s3-bucket ${bucket_name}
    sam deploy --template-file ./build/packaged.yaml --stack-name ${stack_name} --capabilities CAPABILITY_IAM
else
    echo "Missing package details, creating defaults in package folder"
    mkdir -p ./package
    echo "STACK_NAME" > ${stack_name_file}
    echo "BUCKET_NAME" > ${storage_bucket_name_file}
fi