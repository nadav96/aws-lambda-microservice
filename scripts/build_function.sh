#!/usr/bin/env bash
buildDir=$(pwd)/build
appDir=$(pwd)/app

checkForDependencies () {
    # $1 function name
    # $2 dependency name (if empty will download all)
    # $3 level (for debugging)

    if [ $2 ]; then
        # print the dependency tree nicely
        echo -n "   *"
        for i in `seq 1 ${3}`; do
            echo -n "-"
        done
        echo -n " ${2}"
        echo

        # If module exist, link it.
        moduleFilePath=${appDir}/common/${2}.py

        # First, copy the module itself
        if [ -f ${moduleFilePath} ]; then
            ln -sf ${moduleFilePath} ${appDir}/$1/common/
        else
            echo "  ### No module for dependency ${2}"
            return 0
        fi

        # After the module was linked successfully, check for dependencies.
        dependencyLine=$(head -n 1 ${moduleFilePath})
        if [[ ${dependencyLine} = "# DI:"* ]]; then
            moduleDependencies="${dependencyLine#*:}"
        else
            # If the dependencies file doesn't exist, exit the function.
            return 0
        fi
    else
        # No dependency supplied in the function args, means it's root caller, fetch the function first dependencies
        functionFilePath=${appDir}/$1/function.py

        dependencyLine=$(head -n 1 ${functionFilePath})

        if [[ ${dependencyLine} = "# DI:"* ]]; then
            moduleDependencies="${dependencyLine#*:}"
        else
            # If the dependencies file doesn't exist, exit the function.
            return 0
        fi
    fi

    if [ -z "$moduleDependencies" ]; then
        # If the dependencies variable doesn't exist, exit the function.
        return 0
    fi

    # This will loop on the dependency dependencies!
    for dependency in ${moduleDependencies}; do
        checkForDependencies $1 ${dependency} $(($3 + 1))
    done
}

mkdir -p ${appDir}/$1/common
# Remove all previous files in the common dir
rm ${appDir}/$1/common/*
touch ${appDir}/$1/common/__init__.py

echo "  [B] dependencies tree for ${1}:"
checkForDependencies $1

echo
echo
mkdir -p ${buildDir}
cp -r ${appDir}/$1 ${buildDir}

# remove all the config files
rm ${buildDir}/$1/*.txt 2>/dev/null

# navigate to the target dir
cd ${buildDir}/$1
zip -r ../${1}.zip * > /dev/null
echo "  [B] zipped the function"

# Return to root
cd ../../