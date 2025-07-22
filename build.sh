#!/bin/bash

set -ex

clone() {
    url=$1
    commit_hash=$2
    dir=$3

    if [[ -d "$dir" ]]; then
        if [[ $(git -C "$dir" rev-parse HEAD) == "$commit_hash" ]]; then
            echo "Correct commit cloned"
            return 0
        fi
    else
        mkdir "$dir"
        git -C "$dir" init
        git -C "$dir" remote add origin "$url"
    fi
    git -C "$dir" fetch origin "$commit_hash"
    git -C "$dir"  reset --hard "$commit_hash"
}

clone https://github.com/root-project/llvm-project.git 156e947058a46ecc1785f98aa9abb8cbfaa45aa7 llvm
clone https://github.com/root-project/cling.git 59fe11129e8c3de4038b296491a4e0844169bcbf cling
#git clone -b cling-llvm18 https://github.com/root-project/llvm-project.git llvm-cling
#git clone https://github.com/root-project/cling.git
docker build . -t cling
