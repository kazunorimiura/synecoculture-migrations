#!/bin/bash

# ./migrations/page_migrations/privacy-policy/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

### メイン処理 ###

# privacy-policyスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="privacy-policy" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  # 日本語版
  if [ "$lang" == "ja" ]; then
    replace_languages_provided $post_id ja
  fi
done
