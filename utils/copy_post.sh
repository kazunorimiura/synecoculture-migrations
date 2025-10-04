#!/bin/bash

###
### 投稿を指定言語へコピー
###

source ./migrations/utils/message.sh

copy_post() {
  local post_id=$1
  local lang=$2

  # 投稿をコピーして tr_post_id を取得
  # clean_languages_cacheは、翻訳の投稿数を正確に記録するために必要
  tr_post_id=$(wp eval "echo PLL()->sync_post->sync_model->copy( $post_id, '$lang', 'copy', false );")

  # 戻り値として tr_post_id を返す
  echo "$tr_post_id"
}
