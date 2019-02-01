#!/bin/bash
if [ "$builder" = "" ];then
    builder=$(whoami)
fi
rel=7
docker build . --build-arg rel="$rel" --tag "${builder}"/gwms-frontend
