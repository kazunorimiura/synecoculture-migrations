#!/bin/bash

# ./migrations/page_migrations/blog/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/page_migrations/_attach_cover.sh


WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

###
### ブログアーカイブページのカバー画像を設定
###

# NOTE: homeのマイグレーションでブログカバーをインポートしているので、ここでは不要
FILE_NAME="blog-cover.jpg"
file_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
message "file_id (already import): $file_id"
file_id__en=$(wp eval "echo pll_get_post('$file_id', 'en');")
message "file_id__en (fetch): $file_id__en"
file_id__fr=$(wp eval "echo pll_get_post('$file_id', 'fr');")
message "file_id__fr (fetch): $file_id__fr"
file_id__zh=$(wp eval "echo pll_get_post('$file_id', 'zh');")
message "file_id__zh (fetch): $file_id__zh"

attach_cover "blog" $file_id $file_id__en $file_id__fr $file_id__zh
