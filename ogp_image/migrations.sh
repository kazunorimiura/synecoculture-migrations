#!/bin/bash

# ./migrations/ogp_image/migrations.sh
# メディアをインポートする場合:
# ./migrations/ogp_image/migrations.sh --import-media

# 各種ライセンスキーは.envファイルで定義

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/ogp_image/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

# シネコな話バナーの背景画像を定義
FILE_NAME="no-image.png"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
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

wp eval "set_theme_mod( 'wpf_no_image', '$file_id' );"
