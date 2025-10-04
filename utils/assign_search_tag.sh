#!/bin/bash

# デフォルト言語のcategoryタームを指定のタクソノミーにコピーし、投稿に再割り当てを行う
# コンテンツをサブ言語へコピーする前にこれを処理することで、サブ言語版のタームも作られる

# ./migrations/utils/assign_search_tag.sh <POST_TYPE>

post_type=$1

source ./migrations/utils/message.sh

categories=$(wp term list category --field=term_id)
for cat_id in $categories; do
  lang=$(wp eval "echo pll_get_term_language('$cat_id', 'slug');")
  if [ "$lang" != "ja" ]; then
    continue
  fi

  # カテゴリスラッグを取得
  cat_name=$(wp term get category $cat_id --field=slug)
  message "cat_name: $cat_name" bold

  # コピーしたタームを投稿に割り当てる
  post_ids=$(wp post list --post_type="$post_type" --category_name=$cat_name --field=ID)
  for post_id in $post_ids; do
    lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
    message "lang: $lang"
    if [ "$lang" == "ja" ]; then
      wp post term add $post_id "search_tag" "$cat_name"
    fi
  done
done

tags=$(wp term list post_tag --field=term_id)
for tag_id in $tags; do
  lang=$(wp eval "echo pll_get_term_language('$tag_id', 'slug');")
  if [ "$lang" != "ja" ]; then
    continue
  fi

  # タグスラッグを取得
  tag_name=$(wp term get post_tag $tag_id --field=slug)
  message "tag_name: $tag_name"

  # コピーしたタームを投稿に割り当てる
  post_ids=$(wp post list --post_type="$post_type" --tag=$tag_name --field=ID)
  for post_id in $post_ids; do
    lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
    message "lang: $lang"
    if [ "$lang" == "ja" ]; then
      wp post term add $post_id "search_tag" "$tag_name"
    fi
  done
done
