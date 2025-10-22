#!/bin/bash

# ./migrations/page_migrations/contact/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

# homeスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="contact" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  replace_languages_provided $post_id ja
done
