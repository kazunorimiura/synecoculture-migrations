#!/bin/bash

# ./migrations/case_studies/migrations.sh
# メディアをインポートする場合:
# ./migrations/case_studies/migrations.sh --import-media

source ./migrations/utils/message.sh

IMPORT_MEDIA=$1

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php case-study ja ./migrations/case_studies/content_files ./migrations/case_studies/content_files/title_mapping.csv

###
### コンテンツマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/case_studies/roppongi/migrations.sh --import-media
else
  ./migrations/case_studies/roppongi/migrations.sh
fi

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/case_studies/ise-chihara/migrations.sh --import-media
else
  ./migrations/case_studies/ise-chihara/migrations.sh
fi

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/case_studies/burkina-faso/migrations.sh --import-media
else
  ./migrations/case_studies/burkina-faso/migrations.sh
fi
