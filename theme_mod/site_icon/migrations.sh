#!/bin/bash

# ./migrations/theme_mod/site_icon/migrations.sh
# メディアをインポートする場合:
# ./migrations/theme_mod/site_icon/migrations.sh --import-media

# 各種ライセンスキーは.envファイルで定義

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/theme_mod/site_icon/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

# OGP画像を定義
FILE_NAME="site-icon.png"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
  message "file_id (new import): $file_id"
else
  file_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "file_id (already import): $file_id"
fi

wp eval "update_option( 'site_icon', '$file_id' );"
