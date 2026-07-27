#!/usr/bin/env bash
set -e
make download -j8 V=s || make download -j1 V=s
