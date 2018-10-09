import yaml
import json

build_dir = "./build"

with file("./sam_auth_resources.json") as f:
    auth_resources = json.loads(f.read())

with file("{}/template.yaml".format(build_dir)) as f:
    full_template = yaml.load(f)

variables = full_template["Globals"]["Function"]["Environment"]["Variables"]

for key in sorted(auth_resources.iterkeys()):
    full_template["Globals"]["Function"]["Environment"]["Variables"]["{}".format(key)] = "{}".format(",".join(auth_resources[key]))

full_template["Globals"]["Function"]["Environment"]["Variables"] = variables
with file('{}/template.yaml'.format(build_dir), 'w') as out:
    yaml.dump(full_template, out, default_flow_style=False)
    out.close()
