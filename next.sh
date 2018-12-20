#!/bin/bash

git checkout `git rev-list HEAD..demo-end | tail -1`
