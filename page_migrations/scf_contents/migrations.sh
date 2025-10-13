#!/bin/bash

# ./migrations/page_migrations/scf_contents/migrations.sh
# メディアをインポートする場合:
# ./migrations/page_migrations/scf_contents/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh

IMPORT_MEDIA=$1

###
### ホームページのマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/scf_contents/home/migrations.sh --import-media
else
  ./migrations/page_migrations/scf_contents/home/migrations.sh
fi

###
### 私たちについてのマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/scf_contents/about/migrations.sh --import-media
else
  ./migrations/page_migrations/scf_contents/about/migrations.sh
fi
