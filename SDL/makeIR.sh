#!/bin/bash

script_dir=$(dirname "$(realpath $0)")

clang ${script_dir}/app.c -o ${script_dir}/app.ll -S -emit-llvm -O2
