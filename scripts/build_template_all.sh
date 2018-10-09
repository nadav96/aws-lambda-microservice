#!/usr/bin/env bash

echo "{}" > ./sam_local_env.json
echo "{}" > ./sam_auth_resources.json
rm ./build/template.yaml

for file_path in ./app/*
do
    app_name=${file_path##*/}
    if [ "$app_name" != "common" ] && [ "$app_name" != "template.yaml" ] && [ "$app_name" != "template-full.yaml" ] && [ "$app_name" != "template-skeleton.yaml" ] ; then
        python ./scripts/build_template.py ${app_name}
    fi
done

python ./scripts/template_authlevels.py