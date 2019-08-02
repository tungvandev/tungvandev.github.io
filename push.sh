#!/bin/sh
git add . -A
git commit -m "New blogging at $(date)"
git push origin master