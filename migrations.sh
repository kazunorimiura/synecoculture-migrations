#!/bin/bash

# ./migrations/migrations.sh
# メディアをインポートする場合:
# ./migrations/migrations.sh --import-media

# 各種ライセンスキーは.envファイルで定義

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

IMPORT_MEDIA=$1

SECONDS=0

###
### 必須プラグインを有効化
###

./migrations/_install_plugins.sh

###
### `wp-multibyte-patch` プラグインを無効化
### NOTE: 旧画像の日本語ファイル名が変更されるのを防ぐため
###

wp plugin deactivate wp-multibyte-patch

###
### WordPressのデフォルトコンテンツ等をクリーンアップ
###

./migrations/utils/cleanup_posts.sh post
./migrations/utils/cleanup_posts.sh page

###
### パーマリンク構造を更新
###

wp option update permalink_structure '/news/%postname%/'

###
### テーマを有効化
###

wp theme activate synecoculture

###
### Polylangセットアップ
###

wp eval-file ./migrations/polylang/add-languages.php
wp eval-file ./migrations/polylang/assign-default-lang.php
wp eval-file ./migrations/polylang/activate-polylang-license.php
wp eval-file ./migrations/polylang/enable-polylang-sync.php
wp eval-file ./migrations/polylang/enable-polylang-cpt.php
wp eval-file ./migrations/polylang/enable-polylang-media.php
wp eval-file ./migrations/polylang/update-string-translation.php

###
### AkismetプラグインのAPIキーを設定する
###

./migrations/akismet/migrations.sh

###
### reCAPTCHAのサイトキー、シークレットキーを設定する（MW WP Form reCAPTCHAプラグイン用）
###

./migrations/recaptcha/migrations.sh

###
### メディアのインポート
###

# wp import migrations/inc/media.xml --authors=skip --skip=image_resize
wp import migrations/blog/media.xml --authors=skip --skip=image_resize

###
### taxのインポート
###

# wp import migrations/inc/all-contents-edited.xml --authors=skip --skip=attachment,image_resize
wp import migrations/blog/all-contents-edited.xml --authors=skip --skip=attachment,image_resize


###
### ブログのインポート
###

wp import migrations/blog/posts-edited.xml --authors=skip --skip=image_resize

# ###
# ### 固定ページのインポート
# ###

# # NOTE: 古い固定ページはどれも使わなそうなのでインポートしないことにした
# # wp import migrations/inc/pages.xml --authors=skip --skip=image_resize

###
### URLリネーム
###

./migrations/_url_rename.sh

###
### タームを作成
###

./migrations/utils/create_terms.sh migrations/_category_terms.csv category
./migrations/utils/create_terms.sh migrations/_member_cat_terms.csv member_cat
./migrations/utils/create_terms.sh migrations/_project_cat_terms.csv project_cat
./migrations/utils/create_terms.sh migrations/_project_domain_terms.csv project_domain

###
### ブログマイグレーション
### ※ブログマイグレーションでメディアも翻訳されるため、その他の投稿タイプの前に実行する必要がある
###

./migrations/blog_migrations/migrations.sh

###
### メンバー作成、マイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/members/migrations.sh --import-media
else
  ./migrations/members/migrations.sh
fi

###
### 固定ページマイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/page_migrations/migrations.sh --import-media
else
  ./migrations/page_migrations/migrations.sh
fi

###
### 研究・活動投稿作成、マイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/projects/migrations.sh --import-media
else
  ./migrations/projects/migrations.sh
fi

###
### 実践事例投稿作成、マイグレーション
###

if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  ./migrations/case_studies/migrations.sh --import-media
else
  ./migrations/case_studies/migrations.sh
fi

###
### メニューマイグレーション
###

./migrations/menu_migrations/bundle.sh

###
### `wp-multibyte-patch` プラグインを有効化
###

wp plugin activate wp-multibyte-patch

###
### ユーザーインポート用のプラグインを無効化
###

wp plugin deactivate users-customers-import-export-for-wp-woocommerce

###
### メディアのサイズバリエーションを再生成（未生成のもののみ対象。旧ブログのメディアには画像サイズバリエーションが一切なかった）
###

./migrations/_regenerate_media.sh

###
### Polylangの言語ごとの投稿数カウントを手動設定
### Polylangのバグなのか、コードでサブ言語を作成するとメディアの翻訳もカウントしてしまい、カウント数がおかしくなる。
### どうしようもないので、DBにある実際の投稿数をもとにカウント数を再計算している。
###

./migrations/polylang/fix_polylang_counts.sh

###
### フロントページでは、URL にページ名や ID ではなく言語コードを使用するオプションを有効化
###

wp eval-file ./migrations/polylang/update-redirect-lang.php

echo "処理時間 (migrations/migrations.sh): ${SECONDS}秒"
