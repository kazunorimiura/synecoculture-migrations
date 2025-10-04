#!/bin/bash

###
### 投稿タイトル、本文を更新
###

update_post() {
  local post_id=$1
  local maybe_tr_post_id=$2
  local ja_post_id=$3
  local post_type=$4
  local slug=$5

  # 英語版のコンテンツを取得
  tr_post_title=$(wp post get $maybe_tr_post_id --field=post_title)
  tr_post_content=$(wp post get $maybe_tr_post_id --field=post_content)

  # 古い英語版投稿を削除（英語版コンテンツのスラッグのサフィックスに「-2」がついてしまうため）
  # なお、すでに翻訳版のコピーがなされているかもしれないので、同じスラッグの投稿をすべて削除
  _post_ids=$(wp post list --post_type="$post_type" --name="$slug" --format=ids)
  for _post_id in $_post_ids; do
    wp post delete "$_post_id" --force
  done

  # 英語版のコンテンツを設定
  if [ -n "$tr_post_title" ]; then
    wp post update $post_id --post_type="$post_type" --post_title="$tr_post_title" --post_name="$tr_post_title" --post_content="$tr_post_content"
  fi

  # 英語タイトルを使ってその他の言語の投稿スラッグを修正
  if [ -n "$tr_post_title" ]; then
    wp post update $ja_post_id --post_type="$post_type" --post_name="$tr_post_title"

    fr_post_id=$(wp eval "echo pll_get_post('$ja_post_id', 'fr');")
    wp post update $fr_post_id --post_type="$post_type" --post_name="$tr_post_title"

    zh_post_id=$(wp eval "echo pll_get_post('$ja_post_id', 'zh');")
    wp post update $zh_post_id --post_type="$post_type" --post_name="$tr_post_title"
  fi

  echo "$post_id"
}
