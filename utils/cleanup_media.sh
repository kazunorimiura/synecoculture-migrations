#!/bin/bash

# ./migrations/utils/cleanup_media.sh

wp post delete $(wp post list --post_type=attachment --format=ids) --force
