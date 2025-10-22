#!/bin/bash

# ./migrations/page_migrations/migrations.sh
# メディアをインポートする場合:
# ./migrations/page_migrations/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

IMPORT_MEDIA=$1

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php page ja ./migrations/page_migrations/content_files ./migrations/page_migrations/content_files/title_mapping.csv

###
### 問い合わせフォームおよびページを作成
###

wp eval-file ./migrations/page_migrations/create-contact-form.php

###
### ホームページのマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/home/migrations.sh --import-media
else
  ./migrations/page_migrations/home/migrations.sh
fi

###
### 私たちについてのマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/about/migrations.sh --import-media
else
  ./migrations/page_migrations/about/migrations.sh
fi

###
### ご挨拶のマイグレーション
###

./migrations/page_migrations/message/migrations.sh

###
### 組織概要のマイグレーション
###

./migrations/page_migrations/company_profile/migrations.sh

###
### 沿革のマイグレーション
###

./migrations/page_migrations/history/migrations.sh

###
### 問い合わせのマイグレーション
###

./migrations/page_migrations/contact/migrations.sh

###
### ブログのマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/blog/migrations.sh --import-media
else
  ./migrations/page_migrations/blog/migrations.sh
fi

###
### Synecocultureマニュアルのマイグレーション
###

# NOTE: 一旦Coming soonなので、カバー画像のマイグレーションのみなのでコメントアウト
# if [ "$IMPORT_MEDIA" == "--import-media" ]; then
#   ./migrations/page_migrations/manual/migrations.sh --import-media
# else
#   ./migrations/page_migrations/manual/migrations.sh
# fi

###
### ホームページの表示設定を更新
###

./migrations/page_migrations/_update_show_on_front.sh page
./migrations/page_migrations/_attach_option_page.sh page_on_front home
./migrations/page_migrations/_attach_option_page.sh page_for_posts news
./migrations/page_migrations/_attach_option_page.sh wp_page_for_privacy_policy privacy-policy
