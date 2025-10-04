#!/bin/bash

# ./migrations/blog_migrations/_set_tr_post.sh

###
### 投稿IDとスラッグから翻訳版と思われる投稿のコンテンツを取得してPolylangの翻訳版に設定する
###

source ./migrations/utils/add_languages_provided.sh
source ./migrations/blog_migrations/_maybe_get_tr_post.sh
source ./migrations/blog_migrations/_update_post.sh

set_tr_post() {
  local current_post_id=$1
  local tr_post_id=$2
  local target_post_id=$3
  local target_tr_slug=$4
  local target_tr_lang=$5
  local post_type=$6

  if [ "$current_post_id" == "$target_post_id" ]; then
    maybe_tr_post_id=$(maybe_get_tr_post $target_tr_slug $target_tr_lang $post_type)

    if [ "$maybe_tr_post_id" -ne 0 ]; then
      updated_post_id=$(update_post $tr_post_id $maybe_tr_post_id $current_post_id $post_type $target_tr_slug)
      add_languages_provided $current_post_id $target_tr_lang
      echo "$updated_post_id"
    else
      echo 0
    fi
  fi
}

# set_tr_post 3364 3485 3364 "a-framework-for-collaboration-across-borders-and-sharing-with-society" en blog
# set_tr_post 2707 4582 2707 "interview-featured-in-sonys-social-issues-and-technologies-special-edition" en blog
