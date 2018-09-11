#!/bin/bash
sam local start-api --template ./build/template.yaml -n ./sam_local_env.json --host 0.0.0.0

