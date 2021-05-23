#!/bin/sh

# Update the index
git update-index -q --ignore-submodules --refresh
err=0

# Disallow unstaged changes in the working tree
if ! git diff-files --quiet --ignore-submodules --
then
    echo >&2 "cannot $1: you have unstaged changes."
    git diff-files --name-status -r --ignore-submodules -- >&2
    err=1
fi

# Disallow uncommitted changes in the index
if ! git diff-index --cached --quiet HEAD --ignore-submodules --
then
    echo >&2 "cannot $1: your index contains uncommitted changes."
    git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
    err=1
fi

if [ $err = 1 ]
then
    echo >&2 "Please commit or stash them."
    exit 1
fi

comby '[:[1]](x-source:[2])' '`:[1]`' -matcher .generic -i

jazzy \
    --clean \
    --author "Varun Santhanam" \
    --author_url https://www.vsanthanam.com \
    --swift-build-tool spm \
    --build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5 \
    --module Ombi \
    --module-version 1.0.2 \
    --github_url https://www.github.com/vsanthanam/Ombi \
    --root-url https://docs.ombi.network \
    --output Documentation \

git reset --hard