#!/bin/bash

# ./migrations/page_migrations/manual/migrations.sh
# メディアをインポートする場合:
# ./migrations/page_migrations/manual/migrations.sh --import-media

source ./migrations/utils/message.sh
source ./migrations/page_migrations/_attach_cover.sh
source ./migrations/utils/replace_languages_provided.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/page_migrations/manual/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正


###
### Synecocultureマニュアルのカバー画像を設定
###

FILE_NAME="synecoculture-manual-cover.jpg"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  file_id=$(wp media import "$MEDIA_PATH/$FILE_NAME" --porcelain)
  message "file_id (new import): $file_id"
  file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "file_id__en (new copy): $file_id__en"
  file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "file_id__fr (new copy): $file_id__fr"
  file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "file_id__zh (new copy): $file_id__zh"
else
  file_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "file_id (already import): $file_id"
  file_id__en=$(wp eval "echo pll_get_post('$file_id', 'en');")
  message "file_id__en (fetch): $file_id__en"
  file_id__fr=$(wp eval "echo pll_get_post('$file_id', 'fr');")
  message "file_id__fr (fetch): $file_id__fr"
  file_id__zh=$(wp eval "echo pll_get_post('$file_id', 'zh');")
  message "file_id__zh (fetch): $file_id__zh"
fi

# NOTE: 一旦coming soonなのでコメントアウト
# attach_cover "manual" $file_id $file_id__en $file_id__fr $file_id__zh


# manualスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="manual" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 日本語版
  if [ "$lang" == "ja" ]; then
    # 事前にカスタムフィールドをクリーンアップ
    wp post meta delete $post_id --all

    replace_languages_provided $post_id ja
    break
  fi
done
