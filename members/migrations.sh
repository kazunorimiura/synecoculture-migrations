#!/bin/bash

# ./migrations/members/migrations.sh
# メディアをインポートする場合:
# ./migrations/members/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh
source ./migrations/utils/import_media.sh

IMPORT_MEDIA=$1

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php member ja ./migrations/members/content_files ./migrations/members/content_files/title_mapping.csv

###
### コンテンツマイグレーション
###

MEDIA_PATH=/srv/www/synecoculture/migrations/members/media

post_type="member"
post_ids=$(wp post list --post_type="$post_type" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold

  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  if [ "$lang" != "ja" ]; then
    continue
  fi

  post_slug=$(wp post get $post_id --field=post_name)

  if [ "$post_slug" == "masatoshi-funabashi" ]; then
    message "masatoshi-funabashi"

    result=$(get_multilingual_media_ids "masatoshi-funabashi.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post term add $post_id member_cat representative-director
  elif [ "$post_slug" == "kengo-nagahashi" ]; then
    wp post term add $post_id member_cat director
  elif [ "$post_slug" == "godai-suzuki" ]; then
    wp post term add $post_id member_cat director
  elif [ "$post_slug" == "yoko-honjo" ]; then
    message "yoko-honjo"

    result=$(get_multilingual_media_ids "yoko-honjo.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post term add $post_id member_cat director
  elif [ "$post_slug" == "tatsuya-kawaoka" ]; then
    wp post term add $post_id member_cat researcher
  elif [ "$post_slug" == "ryota-sakayama" ]; then
    wp post term add $post_id member_cat researcher
  elif [ "$post_slug" == "kousaku-ohta" ]; then
    message "kousaku-ohta"

    result=$(get_multilingual_media_ids "kousaku-ohta.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post term add $post_id member_cat researcher
  elif [ "$post_slug" == "shinnosuke-yoshikawa" ]; then
    wp post term add $post_id member_cat researcher
  elif [ "$post_slug" == "satoru-okamoto" ]; then
    wp post term add $post_id member_cat navigator
  elif [ "$post_slug" == "kei-fukuda" ]; then
    wp post term add $post_id member_cat navigator
  fi

  ./migrations/members/update_menu_order.sh $post_id
done
