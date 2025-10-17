#!/bin/bash

# ./migrations/fix_media_suffix/migrations.sh

###
### サフィックス付きメディアの検出
###

./migrations/fix_media_suffix/compare_uploads.sh /srv/www/synecoculture/public_html/wp-content/uploads_old /srv/www/synecoculture/public_html/wp-content/uploads

###
### サフィックス付きメディアファイルを正としてDBリネーム
### NOTE: メディアのxmlインポートの際に、同名ファイルは（たとえ年月ディレクトリが異なっても）
### `-{number}`サフィックスがつくため、本文内のsrc指定をサフィックス付きにリネームしている。
### これがアタッチメントIDを変えずに、かつ画像リンク切れも起こさない最適な方法
###

wp eval-file ./migrations/fix_media_suffix/search-replace.php ./migrations/fix_media_suffix/wp_suffix_report.csv

###
### 比較用のuploads_oldディレクトリを削除
###

./migrations/fix_media_suffix/delete_uploads_old.sh

