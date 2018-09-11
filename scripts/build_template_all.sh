#!/usr/bin/env bash
for file_path in ./app/*
do
    app_name=${file_path##*/}
    if [ "$app_name" != "common" ] && [ "$app_name" != "template.yaml" ] && [ "$app_name" != "template-full.yaml" ] && [ "$app_name" != "template-skeleton.yaml" ] ; then
        python ./scripts/build_template.py ${app_name}
    fi
done