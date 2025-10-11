#!/bin/bash

# ./migrations/projects/migrations.sh
# メディアをインポートする場合:
# ./migrations/projects/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh
source ./migrations/utils/import_media.sh
source ./migrations/utils/cleanup_posts.sh
source ./migrations/utils/member_ids.sh

IMPORT_MEDIA=$1

# 投稿をクリーンアップ
./migrations/utils/cleanup_posts.sh project

###
### 新規固定ページを作成
###

wp eval-file ./migrations/utils/create_posts.php project ja ./migrations/projects/content_files ./migrations/projects/content_files/title_mapping.csv

###
### コンテンツマイグレーション
###

MEDIA_PATH=/srv/www/synecoculture/migrations/projects/media

post_type="project"
post_ids=$(wp post list --post_type="$post_type" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold

  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  if [ "$lang" != "ja" ]; then
    continue
  fi

  post_slug=$(wp post get $post_id --field=post_name)

  # 第11回国際高齢化とeヘルスのための情報通信技術会議
  if [ "$post_slug" == "ict4awe-2025" ]; then
    message "ict4awe-2025"

    result=$(get_multilingual_media_ids "ict4awe-2025.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post meta update $post_id _wpf_pickup_flag '1'

    wp post term add $post_id project_cat conference-presentation
    wp post term add $post_id project_domain healthcare

    # 関連メンバーを設定
    if [ -n "$tatsuya_kawaoka" ]; then
      wp eval '
      delete_post_meta('$post_id', "_wpf_related_members"); // 既存のメタデータを削除
      echo add_post_meta('$post_id', "_wpf_related_members", array('$tatsuya_kawaoka')) . "\n";
      '
    fi
  fi

  # 拡張生態系入門キット・シネコポータル
  if [ "$post_slug" == "syneco-portal" ]; then
    message "syneco-portal"

    result=$(get_multilingual_media_ids "syneco-portal.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post meta update $post_id _wpf_pickup_flag '1'

    wp post term add $post_id project_cat educational-platform
    wp post term add $post_id project_domain food-production

    # 関連メンバーを設定
    if [ -n "$masatoshi_funabashi" ] && [ -n "$yoko_honjo" ] && [ -n "$kei_fukuda" ]; then
      wp eval '
      delete_post_meta('$post_id', "_wpf_related_members"); // 既存のメタデータを削除
      echo add_post_meta('$post_id', "_wpf_related_members", array('$masatoshi_funabashi', '$yoko_honjo', '$kei_fukuda')) . "\n";
      '
    fi
  fi

  # 京都大学「社会的共通資本と未来」寄附研究部門
  if [ "$post_slug" == "social-common-capital-and-the-future" ]; then
    message "social-common-capital-and-the-future"

    result=$(get_multilingual_media_ids "social-common-capital-and-the-future.jpg" "$MEDIA_PATH" "$IMPORT_MEDIA")
    parse_media_ids "$result"
    echo "メディアID: ${media_ids[default]}, ${media_ids[en]}, ${media_ids[fr]}, ${media_ids[zh]}"
    wp post meta update $post_id _thumbnail_id "${media_ids[default]}"

    wp post meta update $post_id _wpf_pickup_flag '1'

    wp post term add $post_id project_cat university-collaboration

    # 関連メンバーを設定
    if [ -n "$masatoshi_funabashi" ] && [ -n "$godai_suzuki" ] && [ -n "$tatsuya_kawaoka" ] && [ -n "$shinnosuke_yoshikawa" ]; then
      wp eval '
      delete_post_meta('$post_id', "_wpf_related_members"); // 既存のメタデータを削除
      echo add_post_meta('$post_id', "_wpf_related_members", array('$masatoshi_funabashi', '$godai_suzuki', '$tatsuya_kawaoka', '$shinnosuke_yoshikawa')) . "\n";
      '
    fi
  fi

  # 高齢化社会における免疫関連疾患へのICT活用によるオープン・コンプレックス・システム・アプローチ
  if [ "$post_slug" == "open-complex-systems-approach" ]; then
    message "open-complex-systems-approach"

    wp post term add $post_id project_cat peer-peviewed-paper
    wp post term add $post_id project_domain healthcare

    # 関連メンバーを設定
    if [ -n "$masatoshi_funabashi" ] && [ -n "$ryota_sakayama" ] && [ -n "$kousaku_ohta" ]; then
      wp eval '
      delete_post_meta('$post_id', "_wpf_related_members"); // 既存のメタデータを削除
      echo add_post_meta('$post_id', "_wpf_related_members", array('$masatoshi_funabashi', '$ryota_sakayama', '$kousaku_ohta')) . "\n";
      '
    fi
  fi
done
