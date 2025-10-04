#!/bin/bash

# ./migrations/utils/cleanup_posts.sh <POST_TYPE>

# 削除する投稿タイプ
post_type=$1

# wp post delete $(wp post list --post_type=$post_type --field=ID --format=ids) --force
wp db query 'DELETE FROM wp_posts WHERE post_type="'$post_type'";'
