#!/bin/bash
echo "install start"
context=/app-dir
for file_path in ${context}/app/*
do
    app_name=${file_path##*/}
    if [ "$app_name" != "common" ] && [ "$app_name" != "template.yaml" ] && [ "$app_name" != "template-skeleton.yaml" ] ; then
        mkdir -p ${context}/build/${app_name}

        if [ ! -f ${file_path}/requirements.txt ]; then
            echo "*** Created requirement file for ${app_name}"
            touch ${file_path}/requirements.txt
        fi

        md5_file_path=${context}/build/${app_name}/md5

        current_md5_value=$(md5sum ${file_path}/requirements.txt | cut -f1 -d" ")
        previous_md5_value=$(cat ${md5_file_path} 2>/dev/null)

        if [ ! -f ${md5_file_path} ] || [ ! "$current_md5_value" == "$previous_md5_value" ] ; then
            echo "******************"
            rm -rf ${context}/build/${app_name}/* 2>/dev/null
            echo ${app_name}
            echo ${current_md5_value} > ${md5_file_path}

            pip install -r ${file_path}/requirements.txt -t ${context}/build/${app_name}
            echo "******************"
        fi
    fi
done
echo "done"