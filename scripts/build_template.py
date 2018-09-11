import yaml
import sys
import os
from shutil import copyfile

function_path = sys.argv[1]
app_dir = "./app"
build_dir = "./build"

if not os.path.exists("{}/template.yaml".format(build_dir)):
    print "Created blank template"
    copyfile("{}/template-skeleton.yaml".format(app_dir), "{}/template.yaml".format(build_dir))

with file("{}/{}/template.yaml".format(app_dir, function_path)) as f:
    function_template = yaml.load(f)

function_name = function_template["Name"]
code_uri = function_template["CodeUri"]
is_api = function_template["IsApi"]
is_authenticated = function_template["IsAuthenticated"]
exclude_security = function_template["ExcludeSecurity"]

api_path = None
api_method = None
api_function_arn = "arn:aws:apigateway:${{AWS::Region}}:lambda:path/2015-03-31/functions/${{{}.Arn}}/invocations".format(
    function_name)

if is_api is True:
    api_data = function_template["Events"]["Main"]["Properties"]
    api_path = api_data["Path"]
    api_method = api_data["Method"]

with file("{}/template.yaml".format(build_dir)) as f:
    full_template = yaml.load(f)

function_resource = {
    "Type": "AWS::Serverless::Function",
    "Properties": {
        "CodeUri": code_uri,
        "Handler": "function.handler",
        "Runtime": "python2.7"
    }
}

if "Environment" in function_template:
    function_resource["Properties"]["Environment"] = function_template["Environment"]
if "Events" in function_template:
    function_resource["Properties"]["Events"] = function_template["Events"]
if "Timeout" in function_template:
    function_resource["Properties"]["Timeout"] = function_template["Timeout"]
if "Policies" in function_template:
    function_resource["Properties"]["Policies"] = function_template["Policies"]

full_template["Resources"][function_name] = function_resource

if is_api is True:
    function_api_result = {
        api_method: {
            "x-amazon-apigateway-integration": {
                "httpMethod": "post",
                "type": "aws_proxy",
                "uri": {
                    "Fn::Sub": api_function_arn
                }
            },
            "responses": {}
        }
    }
    if exclude_security is False:
        function_api_result[api_method]["security"] = [
            {
                "auth_tokenorizer": []
            }
        ]

    full_template["Resources"]["ApiGateway"]["Properties"]["DefinitionBody"]["paths"][api_path] = function_api_result

with file('{}/template.yaml'.format(build_dir), 'w') as out:
    yaml.dump(full_template, out, default_flow_style=False)

print "Finished adding {}".format(function_name)