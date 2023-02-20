#!/usr/bin/env bash
docker buildx build --platform linux/amd64,linux/arm64 -t faraazkhan/diagnostics:latest --push .
