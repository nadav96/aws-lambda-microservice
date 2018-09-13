# sam-app lambda micro service skeleton

This is a sample template for sam-app - Below is a brief explanation of what we have generated for you:

```bash
.
├── app - Containing all functions (each function is a folder, except common)
│   ├── function01
│   │   ├── common - Ignored folder, automaticly built, contains the shared libraries the function needs
│   │   ├── common_dependencies.txt - A list of files which the function needs from the common folder (can include sub folders in the common folder as well).
│   │   ├── requirements.txt - the python modules needs by the function
│   │   ├── function.py - the function code itself
│   │   ├── function-test.py - executed by the test script, test the core of the function, and return exit code (0 is success)
│   │   └── template.yaml - the template instructions for the function (will be use to append to the resulting template the function part)
│   ├── template-skeleton.yaml - the skeleton of the final template file use to deploy to aws
│   └── common - shared libraries across the functions in the app
├── build - auto created by the scripts of the project
├── package - the package & deploy env folder (created by the script if not exist)
│   ├── stack_name.txt - the stack name
│   └── storage_bucket.txt - the storage bucket name (store the functions before deployment)

```

## Scripts
* run **./scripts/docker/docker-configure.sh** script (to set up the docker env for the app).
* run **./scripts/docker/docker-configure.sh** script (to set up the docker env for the app).
* run **./script/docker-install.sh** use the install.sh script and run it inside docker. the install script loop through all of the project functions and populate their python dependencies.
* run **./script/build_function.sh** build a specific function (in the build folder, python dependencies not included and should be already available).
* run **./script/build_all.sh** to run the build_function on all of the project functions (compute hash, only changed functions will be rebuilt).
* run **python ./script/build_template.py** to append to the already built template in the build folder the function template requirements (or create if doesn't exist, from the skeleton)
* run **./script/build_template_all.sh** to run build_template.py on all of the project functions
* run **./script/package.sh** deploy the project to aws (pulling the stack name and storage bucket name from the package folder, if not existed the script create the env files and exit).
* run **./script/sam-start.sh** Start the local server with the functions
* run **./script/test_function_all.sh** Execute all of the functions function-test.py scripts, report success and failures.

Special note: the deploy script only deploy changed functions, or template changes, to change function, one must build it again.

## Sam local README

## Requirements

* AWS CLI already configured with at least PowerUser permission
* [Python 2.7 installed](https://www.python.org/downloads/)
* [Docker installed](https://www.docker.com/community-edition)
* [Python Virtual Environment](http://docs.python-guide.org/en/latest/dev/virtualenvs/)


### Local development

**Invoking function locally through local API Gateway**

```bash
sam local start-api
```

If the previous command ran successfully you should now be able to hit the following local endpoint to invoke your function `http://localhost:3000/hello`

**SAM CLI** is used to emulate both Lambda and API Gateway locally and uses our `template.yaml` to understand how to bootstrap this environment (runtime, where the source code is, etc.) - The following excerpt is what the CLI will read in order to initialize an API and its routes:

```yaml
...
Events:
    HelloWorld:
        Type: Api # More info about API Event Source: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#api
        Properties:
            Path: /hello
            Method: get
```

## Packaging and deployment

AWS Lambda Python runtime requires a flat folder with all dependencies including the application. SAM will use `CodeUri` property to know where to look up for both application and dependencies:

```yaml
...
    HelloWorldFunction:
        Type: AWS::Serverless::Function
        Properties:
            CodeUri: hello_world/
            ...
```

Firstly, we need a `S3 bucket` where we can upload our Lambda functions packaged as ZIP before we deploy anything - If you don't have a S3 bucket to store code artifacts then this is a good time to create one:

```bash
aws s3 mb s3://BUCKET_NAME
```

Next, run the following command to package our Lambda function to S3:

```bash
sam package \
    --template-file template.yaml \
    --output-template-file packaged.yaml \
    --s3-bucket REPLACE_THIS_WITH_YOUR_S3_BUCKET_NAME
```

Next, the following command will create a Cloudformation Stack and deploy your SAM resources.

```bash
sam deploy \
    --template-file packaged.yaml \
    --stack-name sam-app \
    --capabilities CAPABILITY_IAM
```

> **See [Serverless Application Model (SAM) HOWTO Guide](https://github.com/awslabs/serverless-application-model/blob/master/HOWTO.md) for more details in how to get started.**

After deployment is complete you can run the following command to retrieve the API Gateway Endpoint URL:

```bash
aws cloudformation describe-stacks \
    --stack-name sam-app \
    --query 'Stacks[].Outputs'
``` 

## Testing

We use **Pytest** for testing our code and you can install it using pip: ``pip install pytest`` 

Next, we run `pytest` against our `tests` folder to run our initial unit tests:

```bash
python -m pytest tests/ -v
```

**NOTE**: It is recommended to use a Python Virtual environment to separate your application development from  your system Python installation.

# Appendix

### Python Virtual environment
**In case you're new to this**, python2 `virtualenv` module is not available in the standard library so we need to install it and then we can install our dependencies:

1. Create a new virtual environment
2. Install dependencies in the new virtual environment

```bash
pip install virtualenv
virtualenv .venv
. .venv/bin/activate
pip install -r requirements.txt
```


**NOTE:** You can find more information about Virtual Environment at [Python Official Docs here](https://docs.python.org/3/tutorial/venv.html). Alternatively, you may want to look at [Pipenv](https://github.com/pypa/pipenv) as the new way of setting up development workflows
## AWS CLI commands

AWS CLI commands to package, deploy and describe outputs defined within the cloudformation stack:

```bash
sam package \
    --template-file template.yaml \
    --output-template-file packaged.yaml \
    --s3-bucket REPLACE_THIS_WITH_YOUR_S3_BUCKET_NAME

sam deploy \
    --template-file packaged.yaml \
    --stack-name sam-app \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides MyParameterSample=MySampleValue

aws cloudformation describe-stacks \
    --stack-name sam-app --query 'Stacks[].Outputs'
```

## Bringing to the next level

Here are a few ideas that you can use to get more acquainted as to how this overall process works:

* Create an additional API resource (e.g. /hello/{proxy+}) and return the name requested through this new path
* Update unit test to capture that
* Package & Deploy

Next, you can use the following resources to know more about beyond hello world samples and how others structure their Serverless applications:

* [AWS Serverless Application Repository](https://aws.amazon.com/serverless/serverlessrepo/)
* [Chalice Python Serverless framework](https://github.com/aws/chalice)
* Sample Python with 3rd party dependencies, pipenv and Makefile: ``sam init --location https://github.com/aws-samples/cookiecutter-aws-sam-python``
