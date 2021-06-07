#!/bin/sh
jazzy \
    --clean \
    --author "Varun Santhanam" \
    --author_url https://www.vsanthanam.com \
    --swift-build-tool spm \
    --build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5 \
    --module Ombi \
    --module-version 1.0.3 \
    --github_url https://www.github.com/vsanthanam/Ombi \
    --root-url https://docs.ombi.network \
    --output Documentation \
