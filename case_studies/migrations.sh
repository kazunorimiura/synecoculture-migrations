#!/bin/bash

# ./migrations/case_studies/migrations.sh
# メディアをインポートする場合:
# ./migrations/case_studies/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh
source ./migrations/utils/import_media.sh

IMPORT_MEDIA=$1

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php case-study ja ./migrations/case_studies/content_files ./migrations/case_studies/content_files/title_mapping.csv

###
### コンテンツマイグレーション
###

WP_UPLOADS_DIR=http://synecoculture.test/wp-content/uploads

# アイキャッチ画像を定義
eyecatch_1_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/08/DSC01529-scaled.jpeg' );")
message "eyecatch_1_id: $eyecatch_1_id"
eyecatch_1_id__en=$(wp eval "echo pll_get_post('$eyecatch_1_id', 'en');")
eyecatch_1_id__fr=$(wp eval "echo pll_get_post('$eyecatch_1_id', 'fr');")
eyecatch_1_id__zh=$(wp eval "echo pll_get_post('$eyecatch_1_id', 'zh');")

eyecatch_2_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/12/IMG_1186.jpeg' );")
message "eyecatch_2_id: $eyecatch_2_id"
eyecatch_2_id__en=$(wp eval "echo pll_get_post('$eyecatch_2_id', 'en');")
eyecatch_2_id__fr=$(wp eval "echo pll_get_post('$eyecatch_2_id', 'fr');")
eyecatch_2_id__zh=$(wp eval "echo pll_get_post('$eyecatch_2_id', 'zh');")

eyecatch_3_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2019/03/FermeDesFemmes.png' );")
message "eyecatch_3_id: $eyecatch_3_id"
eyecatch_3_id__en=$(wp eval "echo pll_get_post('$eyecatch_3_id', 'en');")
eyecatch_3_id__fr=$(wp eval "echo pll_get_post('$eyecatch_3_id', 'fr');")
eyecatch_3_id__zh=$(wp eval "echo pll_get_post('$eyecatch_3_id', 'zh');")

MEDIA_PATH=/srv/www/synecoculture/migrations/case_studies/media

post_type="case-study"
post_ids=$(wp post list --post_type="$post_type" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold

  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  if [ "$lang" != "ja" ]; then
    continue
  fi

  post_slug=$(wp post get $post_id --field=post_name)

  if [ "$post_slug" == "burkina-faso-mahadaga-synecoculture-farm" ]; then
    message "burkina-faso-mahadaga-synecoculture-farm"
    wp post meta update $post_id _thumbnail_id $eyecatch_3_id
    wp post term add $post_id area africa-burkina-faso
  elif [ "$post_slug" == "roppongi-hills-rooftop-synecoculture-farm" ]; then
    message "roppongi-hills-rooftop-synecoculture-farm"
    wp post meta update $post_id _thumbnail_id $eyecatch_1_id
    wp post term add $post_id area japan-tokyo
  elif [ "$post_slug" == "ise-chihara-synecoculture-tea-garden" ]; then
    message "ise-chihara-synecoculture-tea-garden"
    wp post meta update $post_id _thumbnail_id $eyecatch_2_id
    wp post term add $post_id area japan-mie
  fi
done
