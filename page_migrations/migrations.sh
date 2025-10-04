#!/bin/bash

# ./migrations/page_migrations/migrations.sh

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

IMPORT_MEDIA=$1

# NOTE: 古い固定ページは使わなそうなのでコメントアウト
# source ./migrations/utils/message.sh
# source ./migrations/utils/copy_post.sh
# source ./migrations/utils/replace_languages_provided.sh
# source ./migrations/blog_migrations/_set_tr_post.sh

# post_type="page"
# post_ids=$(wp post list --post_type="$post_type" --field=ID)
# for post_id in $post_ids; do
#   message "$post_id" bold

#   replace_languages_provided $post_id ja

#   ###
#   ### 投稿を英語版へコピー
#   ###

#   tr_post_id=$(copy_post $post_id en)
#   if [ "$tr_post_id" -ne 0 ]; then
#     message "tr_post_id (en): $tr_post_id" success
#   else
#     message "Failed to create en post" error
#   fi

#   # 「個人情報の取り扱いについて」のタイトルを翻訳
#   if [ "$post_id" == "187" ]; then
#     wp post update $tr_post_id --post_type="$post_type" --post_title="Handling of Personal Information"
#   fi

#   ###
#   ### 英語版コンテンツのマイグレーション
#   ###

#   # トップ
#   set_tr_post $post_id $tr_post_id 242 "top-2" en page

#   # FAQ
#   set_tr_post $post_id $tr_post_id 3451 "faq-2" en page

#   # 協生農法の5W1H
#   set_tr_post $post_id $tr_post_id 3450 "ホームページ-2" en page

#   # 協生農法™とは
#   set_tr_post $post_id $tr_post_id 151 "about-en" en page

#   # 社団情報
#   set_tr_post $post_id $tr_post_id 3452 "info" en page

#   ###
#   ### 投稿をフランス語版へコピー
#   ###

#   tr_post_id=$(copy_post $post_id fr)
#   if [ "$tr_post_id" -ne 0 ]; then
#     message "tr_post_id (fr): $tr_post_id" success
#   else
#     message "Failed to create fr post" error
#   fi

#   # 「協生農法™とは」のタイトルを翻訳
#   if [ "$post_id" == "151" ]; then
#     wp post update $tr_post_id --post_type="$post_type" --post_title="Qu’est-ce que l’agriculture synecoculturelle™ ?"
#   fi

#   # 「個人情報の取り扱いについて」のタイトルを翻訳
#   if [ "$post_id" == "187" ]; then
#     wp post update $tr_post_id --post_type="$post_type" --post_title="Concernant le traitement des données personnelles"
#   fi

#   ###
#   ### 投稿を中国語版へコピー
#   ###

#   tr_post_id=$(copy_post $post_id zh)
#   if [ "$tr_post_id" -ne 0 ]; then
#     message "tr_post_id (zh): $tr_post_id" success
#   else
#     message "Failed to create zh post" error
#   fi

#   # 「協生農法™とは」のタイトルを翻訳
#   if [ "$post_id" == "151" ]; then
#     wp post update $tr_post_id --post_type="$post_type" --post_title="什么是协生农业™？"
#   fi

#   # 「個人情報の取り扱いについて」のタイトルを翻訳
#   if [ "$post_id" == "187" ]; then
#     wp post update $tr_post_id --post_type="$post_type" --post_title="关于个人信息的处理"
#   fi
# done

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php page ja ./migrations/page_migrations/content_files ./migrations/page_migrations/content_files/title_mapping.csv

###
### 問い合わせフォームおよびページを作成
###

wp eval-file ./migrations/page_migrations/create-contact-form.php

###
### ホームページのSCFを更新
###


if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/scf_contents/migrations.sh --import-media
else
  ./migrations/page_migrations/scf_contents/migrations.sh
fi

###
### ホームページの表示設定を更新
###

./migrations/page_migrations/_update_show_on_front.sh page
./migrations/page_migrations/_attach_option_page.sh page_on_front home
./migrations/page_migrations/_attach_option_page.sh page_for_posts news
./migrations/page_migrations/_attach_option_page.sh wp_page_for_privacy_policy privacy-policy
