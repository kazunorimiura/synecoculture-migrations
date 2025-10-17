#!/bin/bash

###
### 投稿を指定言語へコピー
###

source ./migrations/utils/message.sh

copy_post() {
  local post_id=$1
  local lang=$2

  # 投稿をコピーして tr_post_id を取得
  tr_post_id=$(wp eval "echo PLL()->sync_post->sync_model->copy( $post_id, '$lang', 'copy', false ); PLL()->model->clean_languages_cache();")

  # 戻り値として tr_post_id を返す
  echo "$tr_post_id"
}
