import hashlib
import os
import sys
import base64


def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


function_folder_name = sys.argv[1]
function_dir_path = "./app/{}/".format(function_folder_name)
function_common_dir_path = "{}/common".format(function_dir_path)

function_file_hash = md5("{}/function.py".format(function_dir_path))
common_dependency_hash = md5("{}/common_dependencies.txt".format(function_dir_path))

xor_result = ''.join(chr(ord(a) ^ ord(b)) for a, b in zip(function_file_hash, common_dependency_hash))

if os.path.exists(function_common_dir_path):
    for filename in os.listdir(function_common_dir_path):
        filename_md5 = md5("{}/{}".format(function_common_dir_path, filename))
        xor_result = ''.join(chr(ord(a) ^ ord(b)) for a, b in zip(xor_result, filename_md5))

result = base64.b64encode(xor_result)
f = open("./build/{}/function_dir_hash".format(function_folder_name), "w")
f.write(result)
f.close()
