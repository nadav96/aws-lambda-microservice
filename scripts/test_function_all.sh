#!/bin/bash

failed_apps=""
failed_apps_count=0
total_apps_count=0

for file_path in $(pwd)/app/*
do
    app_name=${file_path##*/}
    if [ "$app_name" != "common" ] && [ "$app_name" != "template-skeleton.yaml" ] ; then
        python ${file_path}/function-test.py
        exit_code=$?
        echo ${app_name} ":" ${exit_code}

        let "total_apps_count=total_apps_count+1"

        if [ ${exit_code} != 0 ]; then
            failed_apps=${failed_apps}" |"${app_name}"|"
            let "failed_apps_count=failed_apps_count+1"
        fi
    fi
done
echo
echo "Failed apps ("${failed_apps_count}"/"${total_apps_count}"):" ${failed_apps}
echo