#!/usr/bin/env bash
for file_path in ./app/*
do
    app_name=${file_path##*/}
    if [ "$app_name" != "common" ] && [ "$app_name" != "template.yaml" ] ; then
        ./scripts/build_function.sh $app_name
    fi
done