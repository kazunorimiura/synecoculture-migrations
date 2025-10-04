#!/bin/bash

# ./migrations/projects/migrations.sh
# メディアをインポートする場合:
# ./migrations/projects/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh
source ./migrations/utils/import_media.sh
source ./migrations/utils/cleanup_posts.sh

IMPORT_MEDIA=$1

# 投稿をクリーンアップ
./migrations/utils/cleanup_posts.sh project

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php project ja ./migrations/projects/content_files ./migrations/projects/content_files/title_mapping.csv

###
### コンテンツマイグレーション
###

MEDIA_PATH=/srv/www/synecoculture/migrations/projects/media

post_type="project"
post_ids=$(wp post list --post_type="$post_type" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold

  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  if [ "$lang" != "ja" ]; then
    continue
  fi

  post_slug=$(wp post get $post_id --field=post_name)

  if [ "$post_slug" == "ict4awe-2025" ]; then
    message "ict4awe-2025"

    result=$(get_multilingual_media_ids "ict4awe-2025.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post meta update $post_id _wpf_pickup_flag '1'

    wp post term add $post_id project_cat conference-presentation
    wp post term add $post_id project_domain healthcare
  elif [ "$post_slug" == "syneco-portal" ]; then
    message "syneco-portal"

    result=$(get_multilingual_media_ids "syneco-portal.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post meta update $post_id _wpf_pickup_flag '1'

    wp post term add $post_id project_cat educational-platform
    wp post term add $post_id project_domain food-production
  elif [ "$post_slug" == "social-common-capital-and-the-future" ]; then
    message "social-common-capital-and-the-future"

    result=$(get_multilingual_media_ids "social-common-capital-and-the-future.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post meta update $post_id _wpf_pickup_flag '1'

    wp post term add $post_id project_cat university-collaboration
  elif [ "$post_slug" == "open-complex-systems-approach" ]; then
    message "open-complex-systems-approach"

    wp post term add $post_id project_cat peer-peviewed-paper
    wp post term add $post_id project_domain healthcare
  fi
done
