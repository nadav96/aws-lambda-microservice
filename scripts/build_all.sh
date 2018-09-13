#!/usr/bin/env bash

modified_apps_count=0
total_apps_count=0

for file_path in ./app/*
do
    app_name=${file_path##*/}
    if [ "$app_name" != "common" ] && [ "$app_name" != "template-skeleton.yaml" ] ; then
        let "total_apps_count=total_apps_count+1"

        # Fetch the previous hash if exists
        if [  -f  $(pwd)/build/${app_name}/function_dir_hash ]; then
            previous_hash=$(cat $(pwd)/build/${app_name}/function_dir_hash)
            # Compute the current hash of the entire function folder
            python $(pwd)/scripts/hash_function.py ${app_name}
            current_hash=$(cat $(pwd)/build/${app_name}/function_dir_hash)
        else
            previous_hash="0"
            current_hash="1"
        fi


        if [ "$previous_hash" != "$current_hash" ]; then
            # The function dir hash was changed, rebuild the function, and compute the hash again.

            let "modified_apps_count=modified_apps_count+1"

            echo "[M]" ${app_name}
            ./scripts/build_function.sh ${app_name}

            # Compute the hash again after the build
            python $(pwd)/scripts/hash_function.py ${app_name}
        fi
    fi
done

echo "[B] ** Modified apps ("${modified_apps_count}"/"${total_apps_count}") **"