#!/bin/bash

# ./migrations/case_studies/roppongi/migrations.sh

source ./migrations/utils/message.sh

###
### コンテンツマイグレーション
###

WP_UPLOADS_DIR=http://synecoculture.test/wp-content/uploads

# アイキャッチ画像を定義
thumbnail_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/08/DSC01529-scaled.jpeg' );")
message "thumbnail_id: $thumbnail_id"
thumbnail_id__en=$(wp eval "echo pll_get_post('$thumbnail_id', 'en');")
thumbnail_id__fr=$(wp eval "echo pll_get_post('$thumbnail_id', 'fr');")
thumbnail_id__zh=$(wp eval "echo pll_get_post('$thumbnail_id', 'zh');")

# 特定のスラッグの投稿を全言語分取得
post_ids=$(wp post list --post_type="case-study" --name="roppongi-hills-rooftop-synecoculture-farm" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  if [ "$lang" == "ja" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id
    wp post term add $post_id area japan-tokyo
  fi
done
