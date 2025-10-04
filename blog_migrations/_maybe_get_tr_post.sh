#!/bin/bash

###
### スラッグから翻訳版と思われる投稿IDを取得
###

maybe_get_tr_post() {
  local slug=$1
  local target_lang=$2
  local post_type=$3

  tr_post_id=0

  post_ids=$(wp post list --post_type="$post_type" --name="$slug" --format=ids)
  for post_id in $post_ids; do
    lang=$(wp eval "echo pll_get_post_language($post_id);")
    if [ "$lang" == "$target_lang" ]; then
        tr_post_id=$post_id
        break
    fi
  done

  echo "$tr_post_id"
}
