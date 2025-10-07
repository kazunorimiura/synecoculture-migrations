#!/bin/bash

# ./migrations/menu_migrations/_create.sh

source ./migrations/utils/message.sh

assign_menu() {
  local menu_name=$1
  local menu_id=$2
  local language=${3:-"ja"}  # デフォルトは"ja"

  case $language in
    "ja")
      wp menu location assign $menu_id $menu_name
      message "Assigned '$menu_name' menu: $menu_id"
      ;;
    "en"|"fr"|"zh")
      wp eval '
      $option_name = "polylang";
      $new_value = '$menu_id';
      $option_value = get_option($option_name);
      // NOTE: nav_menus直下のキーはテーマ名を指定する
      $option_value["nav_menus"]["synecoculture"]["'$menu_name'"]["'$language'"] = $new_value;
      update_option($option_name, $option_value);
      echo "Assigned '$menu_name' menu in '$language': " . get_option($option_name)["nav_menus"]["synecoculture"]["'$menu_name'"]["'$language'"] . "\n";
      '
      ;;
    *)
      echo "Error: Unsupported language code '$language'. Supported: ja, en, fr, zh"
      return 1
      ;;
  esac
}

add_post_type_menu_item() {
  local post_type=$1
  local menu_id=$2
  local page_slug=$3
  local language=$4   # 省略可能
  local parent_id=$5  # 省略可能
  local menu_title=$6 # 省略可能(新規追加)

  # 親子関係の設定
  local parent_setting=""
  if [ -n "$parent_id" ]; then
    parent_setting=', "menu-item-parent-id" => '$parent_id
  fi

  # タイトルの設定
  local title_setting='$page->post_title'
  if [ -n "$menu_title" ]; then
    title_setting='"'$menu_title'"'
  fi

  # 言語コードの処理とメッセージ作成
  local lang_msg=""
  local page_code=""
  if [ -n "$language" ]; then
    page_code='
    $page = get_page_by_path("'$page_slug'", OBJECT, "'$post_type'");
    if (!$page) {
      echo "ERROR: Page not found";
      return;
    }
    $tr_page_id = pll_get_post( $page->ID, "'$language'" );
    if (!$tr_page_id) {
      echo "ERROR: Translation not found";
      return;
    }
    $page = get_post( $tr_page_id );
    if (!$page) {
      echo "ERROR: Translated page not found";
      return;
    }
    '
    lang_msg=" in $language"
  else
    page_code='
    $page = get_page_by_path("'$page_slug'", OBJECT, "'$post_type'");
    if (!$page) {
      echo "ERROR: Page not found";
      return;
    }
    '
  fi

  # メニューアイテムの追加
  local result=$(wp eval "$page_code"'
  $menu_item_id = wp_update_nav_menu_item( '$menu_id', 0, array(
    "menu-item-title" => '$title_setting',
    "menu-item-object-id" => $page->ID,
    "menu-item-object" => "page",
    "menu-item-status" => "publish",
    "menu-item-type" => "post_type"'"$parent_setting"'
  ));

  if (is_wp_error($menu_item_id)) {
    echo "ERROR: " . $menu_item_id->get_error_message();
  } else {
    echo $menu_item_id;
  }
  ')

  # エラーチェック
  if [[ "$result" == *"ERROR:"* ]]; then
    return 1
  fi

  # メニューアイテムIDを返す
  echo $result
}

add_taxonomy_term_menu_item() {
  local taxonomy=$1
  local term_slug=$2
  local menu_id=$3
  local language=$4  # 省略可能
  local parent_id=$5 # 省略可能

  # 引数のチェック
  if [ -z "$taxonomy" ] || [ -z "$term_slug" ] || [ -z "$menu_id" ]; then
    return 1
  fi

  # 親子関係の設定
  local parent_setting=""
  if [ -n "$parent_id" ]; then
    parent_setting=', "menu-item-parent-id" => '$parent_id
  fi

  # 言語コードの処理とメッセージ作成
  local lang_msg=""
  local term_code=""
  if [ -n "$language" ]; then
    term_code='
    $term = get_term_by("slug", "'$term_slug'", "'$taxonomy'");
    if (!$term) {
      echo "ERROR: Term not found";
      return;
    }
    $tr_term_id = pll_get_term( $term->term_id, "'$language'" );
    if (!$tr_term_id) {
      echo "ERROR: Translation not found";
      return;
    }
    $term = get_term( $tr_term_id, "'$taxonomy'" );
    if (!$term) {
      echo "ERROR: Translated term not found";
      return;
    }
    '
    lang_msg=" in $language"
  else
    term_code='
    $term = get_term_by("slug", "'$term_slug'", "'$taxonomy'");
    if (!$term) {
      echo "ERROR: Term not found";
      return;
    }
    '
  fi

  # メニューアイテムの追加
  local result=$(wp eval "$term_code"'
  $menu_item_id = wp_update_nav_menu_item( '$menu_id', 0, array(
    "menu-item-title" => $term->name,
    "menu-item-object-id" => $term->term_id,
    "menu-item-object" => "'$taxonomy'",
    "menu-item-status" => "publish",
    "menu-item-type" => "taxonomy"'"$parent_setting"'
  ));

  if (is_wp_error($menu_item_id)) {
    echo "ERROR: " . $menu_item_id->get_error_message();
  } else {
    echo $menu_item_id;
  }
  ')

  # エラーチェック
  if [[ "$result" == *"ERROR:"* ]]; then
    return 1
  fi

  # 成功メッセージ
  message "Added taxonomy term '$term_slug' ($taxonomy) to menu '$menu_id'${lang_msg}: item ID $result"

  # メニューアイテムIDを返す
  echo $result
}

add_custom_link_menu_item() {
  local menu_id=$1
  local title=$2
  local url=$3
  local parent_id=$4  # 省略可能

  # 引数のチェック
  if [ -z "$menu_id" ] || [ -z "$title" ] || [ -z "$url" ]; then
    return 1
  fi

  # 親子関係の設定
  local parent_setting=""
  if [ -n "$parent_id" ]; then
    parent_setting=', "menu-item-parent-id" => '$parent_id
  fi

  # メニューアイテムの追加
  local result=$(wp eval '
  $menu_item_id = wp_update_nav_menu_item( '$menu_id', 0, array(
    "menu-item-title" => "'"$title"'",
    "menu-item-url" => "'"$url"'",
    "menu-item-object" => "custom",
    "menu-item-status" => "publish",
    "menu-item-type" => "custom"'"$parent_setting"'
  ));

  if (is_wp_error($menu_item_id)) {
    echo "ERROR: " . $menu_item_id->get_error_message();
  } else {
    echo $menu_item_id;
  }
  ')

  # エラーチェック
  if [[ "$result" == *"ERROR:"* ]]; then
    return 1
  fi

  # メニューアイテムIDを返す
  echo $result
}

###
### プライマリ（日本語）
###

# メニューの作成
menu_title="プライマリ（日本語）"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをアサイン
assign_menu "primary" $menu_id

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $menu_id "about")
add_custom_link_menu_item $menu_id "社団の存在意義" "http://synecoculture.test/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $menu_id "about/message" "" $menu_item_id
add_post_type_menu_item page $menu_id "members" "" $menu_item_id
add_post_type_menu_item page $menu_id "about/company-profile" "" $menu_item_id
add_post_type_menu_item page $menu_id "about/history" "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "learn")
add_post_type_menu_item page $menu_id "learn/about-synecoculture" "" $menu_item_id
add_post_type_menu_item project $menu_id "syneco-portal" "" $menu_item_id "シネコポータル"
add_post_type_menu_item page $menu_id "manual" "" $menu_item_id
add_post_type_menu_item page $menu_id "case-studies" "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "projects")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $menu_id "" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $menu_id "" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $menu_id "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "join")
add_custom_link_menu_item $menu_id "ご寄付をお考えの方へ" "http://synecoculture.test/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $menu_id "京都大学連携寄付" "http://synecoculture.test/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $menu_id "寄付金使途報告" "http://synecoculture.test/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $menu_id "共同研究・開発のご相談" "http://synecoculture.test/join/#joint-research-development-inquiries" $menu_item_id

###
### プライマリ（英語）
###

# メニューの作成
tr_menu_title="プライマリ（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "primary" $tr_menu_id "en"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "en")
add_custom_link_menu_item $tr_menu_id "Our Purpose" "http://synecoculture.test/en/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "en")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "en" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "en" $menu_item_id "Syneco Portal"
add_post_type_menu_item page $tr_menu_id "manual" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "en")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "en" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "en" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "en")
add_custom_link_menu_item $tr_menu_id "For Prospective Donors" "http://synecoculture.test/en/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Kyoto University Partnership Donations" "http://synecoculture.test/en/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Donation Usage Report" "http://synecoculture.test/en/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Joint Research & Development Inquiries" "http://synecoculture.test/en/join/#joint-research-development-inquiries" $menu_item_id

###
### プライマリ（フランス語）
###

# メニューの作成
tr_menu_title="プライマリ（フランス語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "primary" $tr_menu_id "fr"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "fr")
add_custom_link_menu_item $tr_menu_id "Notre Objectif" "http://synecoculture.test/fr/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "fr")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "fr" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "fr" $menu_item_id "Portail Syneco"
add_post_type_menu_item page $tr_menu_id "manual" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "fr")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "fr" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "fr" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "fr")
add_custom_link_menu_item $tr_menu_id "Pour les donateurs potentiels" "http://synecoculture.test/fr/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Dons en partenariat avec l'Université de Kyoto" "http://synecoculture.test/fr/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Rapport sur l'utilisation des dons" "http://synecoculture.test/fr/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Consultation pour la recherche collaborative" "http://synecoculture.test/fr/join/#joint-research-development-inquiries" $menu_item_id

###
### プライマリ（中国語）
###

# メニューの作成
tr_menu_title="プライマリ（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "primary" $tr_menu_id "zh"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "zh")
add_custom_link_menu_item $tr_menu_id "我们的宗旨" "http://synecoculture.test/zh/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "zh")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "zh" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "zh" $menu_item_id "Syneco门户"
add_post_type_menu_item page $tr_menu_id "manual" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "zh")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "zh" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "zh" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "zh")
add_custom_link_menu_item $tr_menu_id "致考虑捐赠者" "http://synecoculture.test/zh/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "京都大学合作捐赠" "http://synecoculture.test/zh/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "捐款使用报告" "http://synecoculture.test/zh/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "合作研究·开发咨询" "http://synecoculture.test/zh/join/#joint-research-development-inquiries" $menu_item_id

###
### プライマリCTA（デフォルト言語）
###

# メニューの作成
menu_title="プライマリCTA"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをテーマに設定
assign_menu "primary_cta" $menu_id

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $menu_id

###
### プライマリCTA（英語）
###

# メニューの作成
tr_menu_title="プライマリCTA（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)

# メニューをテーマに設定
assign_menu "primary_cta" $tr_menu_id "en"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### プライマリCTA（フランス語）
###

# メニューの作成
tr_menu_title="プライマリCTA（フランス語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)

# メニューをテーマに設定
assign_menu "primary_cta" $tr_menu_id "fr"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### プライマリCTA（中国語）
###

# メニューの作成
tr_menu_title="プライマリCTA（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)

# メニューをテーマに設定
assign_menu "primary_cta" $tr_menu_id "zh"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### グローバルプライマリ（日本語）
###

# メニューの作成
menu_title="グローバルプライマリ（日本語）"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをアサイン
assign_menu "global_primary" $menu_id

# メニューアイテムを追加
add_post_type_menu_item page $menu_id "home"
menu_item_id=$(add_post_type_menu_item page $menu_id "about")
add_custom_link_menu_item $menu_id "社団の存在意義" "http://synecoculture.test/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $menu_id "about/message" "" $menu_item_id
add_post_type_menu_item page $menu_id "members" "" $menu_item_id
add_post_type_menu_item page $menu_id "about/company-profile" "" $menu_item_id
add_post_type_menu_item page $menu_id "about/history" "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "learn")
add_post_type_menu_item page $menu_id "learn/about-synecoculture" "" $menu_item_id
add_post_type_menu_item project $menu_id "syneco-portal" "" $menu_item_id "シネコポータル"
add_post_type_menu_item page $menu_id "manual" "" $menu_item_id
add_post_type_menu_item page $menu_id "case-studies" "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "projects")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $menu_id "" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $menu_id "" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $menu_id "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "join")
add_custom_link_menu_item $menu_id "ご寄付をお考えの方へ" "http://synecoculture.test/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $menu_id "京都大学連携寄付" "http://synecoculture.test/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $menu_id "寄付金使途報告" "http://synecoculture.test/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $menu_id "共同研究・開発のご相談" "http://synecoculture.test/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $menu_id "blog" ""
add_post_type_menu_item page $menu_id "news" ""
add_post_type_menu_item page $menu_id "contact" ""

###
### グローバルプライマリ（英語）
###

# メニューの作成
tr_menu_title="グローバルプライマリ（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "global_primary" $tr_menu_id "en"

# メニューアイテムを追加
add_post_type_menu_item page $tr_menu_id "home" "en"
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "en")
add_custom_link_menu_item $tr_menu_id "Our Purpose" "http://synecoculture.test/en/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "en")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "en" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "en" $menu_item_id "Syneco Portal"
add_post_type_menu_item page $tr_menu_id "manual" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "en")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "en" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "en" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "en")
add_custom_link_menu_item $tr_menu_id "For Prospective Donors" "http://synecoculture.test/en/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Kyoto University Partnership Donations" "http://synecoculture.test/en/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Donation Usage Report" "http://synecoculture.test/en/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Joint Research & Development Inquiries" "http://synecoculture.test/en/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $tr_menu_id "blog" "en"
add_post_type_menu_item page $tr_menu_id "news" "en"
add_post_type_menu_item page $tr_menu_id "contact" "en"

###
### グローバルプライマリ（フランス語）
###

# メニューの作成
tr_menu_title="グローバルプライマリ（フランス語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "global_primary" $tr_menu_id "fr"

# メニューアイテムを追加
add_post_type_menu_item page $tr_menu_id "home" "fr"
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "fr")
add_custom_link_menu_item $tr_menu_id "Notre Objectif" "http://synecoculture.test/fr/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "fr")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "fr" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "fr" $menu_item_id "Portail Syneco"
add_post_type_menu_item page $tr_menu_id "manual" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "fr")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "fr" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "fr" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "fr")
add_custom_link_menu_item $tr_menu_id "Pour les donateurs potentiels" "http://synecoculture.test/fr/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Dons en partenariat avec l'Université de Kyoto" "http://synecoculture.test/fr/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Rapport sur l'utilisation des dons" "http://synecoculture.test/fr/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Consultation pour la recherche collaborative" "http://synecoculture.test/fr/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $tr_menu_id "blog" "fr"
add_post_type_menu_item page $tr_menu_id "news" "fr"
add_post_type_menu_item page $tr_menu_id "contact" "fr"

###
### グローバルプライマリ（中国語）
###

# メニューの作成
tr_menu_title="グローバルプライマリ（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "global_primary" $tr_menu_id "zh"

# メニューアイテムを追加
add_post_type_menu_item page $tr_menu_id "home" "zh"
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "zh")
add_custom_link_menu_item $tr_menu_id "我们的宗旨" "http://synecoculture.test/zh/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "zh")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "zh" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "zh" $menu_item_id "Syneco门户"
add_post_type_menu_item page $tr_menu_id "manual" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "zh")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "zh" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "zh" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "zh")
add_custom_link_menu_item $tr_menu_id "致考虑捐赠者" "http://synecoculture.test/zh/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "京都大学合作捐赠" "http://synecoculture.test/zh/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "捐款使用报告" "http://synecoculture.test/zh/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "合作研究·开发咨询" "http://synecoculture.test/zh/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $tr_menu_id "blog" "zh"
add_post_type_menu_item page $tr_menu_id "news" "zh"
add_post_type_menu_item page $tr_menu_id "contact" "zh"

###
### グローバルセカンダリ（日本語）
###

# メニューの作成
menu_title="グローバルセカンダリ（日本語）"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをアサイン
assign_menu "global_secondary" $menu_id

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $menu_id "resources")
add_post_type_menu_item page $menu_id "resources/faq" "" $menu_item_id
add_post_type_menu_item page $menu_id "resources/documents" "" $menu_item_id
add_post_type_menu_item page $menu_id "resources/glossary" "" $menu_item_id
add_post_type_menu_item page $menu_id "resources/related-links" "" $menu_item_id
add_post_type_menu_item page $menu_id "careers"
add_post_type_menu_item page $menu_id "privacy-policy"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $menu_id

###
### グローバルセカンダリ（英語）
###

# メニューの作成
tr_menu_title="グローバルセカンダリ（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "global_secondary" $tr_menu_id "en"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "resources" "en")
add_post_type_menu_item page $tr_menu_id "resources/faq" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/documents" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/glossary" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/related-links" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "careers" "en"
add_post_type_menu_item page $tr_menu_id "privacy-policy" "en"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### グローバルセカンダリ（フランス語）
###

# メニューの作成
tr_menu_title="グローバルセカンダリ（フランス語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "global_secondary" $tr_menu_id "fr"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "resources" "fr")
add_post_type_menu_item page $tr_menu_id "resources/faq" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/documents" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/glossary" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/related-links" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "careers" "fr"
add_post_type_menu_item page $tr_menu_id "privacy-policy" "fr"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### グローバルセカンダリ（中国語）
###

# メニューの作成
tr_menu_title="グローバルセカンダリ（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "global_secondary" $tr_menu_id "zh"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "resources" "zh")
add_post_type_menu_item page $tr_menu_id "resources/faq" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/documents" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/glossary" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/related-links" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "careers" "zh"
add_post_type_menu_item page $tr_menu_id "privacy-policy" "zh"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### ソーシャルリンク（日本語）
###

# メニューの作成
menu_title="ソーシャルリンク（日本語）"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをアサイン
assign_menu "social_links" $menu_id "en"

# メニューアイテムを追加
add_custom_link_menu_item $menu_id "note" "https://note.com/syneco_shadan"
add_custom_link_menu_item $menu_id "Instagram" "https://www.instagram.com/synecoculture_association/"
add_custom_link_menu_item $menu_id "Facebook" "https://www.facebook.com/profile.php?id=100066239212911&locale=ja_JP"

###
### ソーシャルリンク（英語）
###

# メニューの作成
tr_menu_title="ソーシャルリンク（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id" bold

# メニューをアサイン
assign_menu "social_links" $tr_menu_id

# メニューアイテムを追加
add_custom_link_menu_item $tr_menu_id "note" "https://note.com/syneco_shadan"
add_custom_link_menu_item $tr_menu_id "Instagram" "https://www.instagram.com/synecoculture_association/"
add_custom_link_menu_item $tr_menu_id "Facebook" "https://www.facebook.com/profile.php?id=100066239212911&locale=ja_JP"

###
### ソーシャルリンク（フランス語）
###

# メニューの作成
tr_menu_title="ソーシャルリンク（フランス語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id" bold

# メニューをアサイン
assign_menu "social_links" $tr_menu_id

# メニューアイテムを追加
add_custom_link_menu_item $tr_menu_id "note" "https://note.com/syneco_shadan"
add_custom_link_menu_item $tr_menu_id "Instagram" "https://www.instagram.com/synecoculture_association/"
add_custom_link_menu_item $tr_menu_id "Facebook" "https://www.facebook.com/profile.php?id=100066239212911&locale=ja_JP"

###
### ソーシャルリンク（中国語）
###

# メニューの作成
tr_menu_title="ソーシャルリンク（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id" bold

# メニューをアサイン
assign_menu "social_links" $tr_menu_id

# メニューアイテムを追加
add_custom_link_menu_item $tr_menu_id "note" "https://note.com/syneco_shadan"
add_custom_link_menu_item $tr_menu_id "Instagram" "https://www.instagram.com/synecoculture_association/"
add_custom_link_menu_item $tr_menu_id "Facebook" "https://www.facebook.com/profile.php?id=100066239212911&locale=ja_JP"

###
### フッタープライマリ（日本語）
###

# メニューの作成
menu_title="フッタープライマリ（日本語）"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをアサイン
assign_menu "footer_primary" $menu_id

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $menu_id "about")
add_custom_link_menu_item $menu_id "社団の存在意義" "http://synecoculture.test/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $menu_id "about/message" "" $menu_item_id
add_post_type_menu_item page $menu_id "members" "" $menu_item_id
add_post_type_menu_item page $menu_id "about/company-profile" "" $menu_item_id
add_post_type_menu_item page $menu_id "about/history" "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "learn")
add_post_type_menu_item page $menu_id "learn/about-synecoculture" "" $menu_item_id
add_post_type_menu_item project $menu_id "syneco-portal" "" $menu_item_id "シネコポータル"
add_post_type_menu_item page $menu_id "manual" "" $menu_item_id
add_post_type_menu_item page $menu_id "case-studies" "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "projects")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $menu_id "" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $menu_id "" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $menu_id "" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $menu_id "join")
add_custom_link_menu_item $menu_id "ご寄付をお考えの方へ" "http://synecoculture.test/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $menu_id "京都大学連携寄付" "http://synecoculture.test/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $menu_id "寄付金使途報告" "http://synecoculture.test/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $menu_id "共同研究・開発のご相談" "http://synecoculture.test/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $menu_id "blog" ""
add_post_type_menu_item page $menu_id "news" ""
add_post_type_menu_item page $menu_id "contact" ""

###
### フッタープライマリ（英語）
###

# メニューの作成
tr_menu_title="フッタープライマリ（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "footer_primary" $tr_menu_id "en"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "en")
add_custom_link_menu_item $tr_menu_id "Our Purpose" "http://synecoculture.test/en/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "en")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "en" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "en" $menu_item_id "Syneco Portal"
add_post_type_menu_item page $tr_menu_id "manual" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "en")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "en" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "en" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "en" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "en")
add_custom_link_menu_item $tr_menu_id "For Prospective Donors" "http://synecoculture.test/en/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Kyoto University Partnership Donations" "http://synecoculture.test/en/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Donation Usage Report" "http://synecoculture.test/en/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Joint Research & Development Inquiries" "http://synecoculture.test/en/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $tr_menu_id "blog" "en"
add_post_type_menu_item page $tr_menu_id "news" "en"
add_post_type_menu_item page $tr_menu_id "contact" "en"

###
### フッタープライマリ（フランス）
###

# メニューの作成
tr_menu_title="フッタープライマリ（フランス）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "footer_primary" $tr_menu_id "fr"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "fr")
add_custom_link_menu_item $tr_menu_id "Notre Objectif" "http://synecoculture.test/fr/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "fr")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "fr" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "fr" $menu_item_id "Portail Syneco"
add_post_type_menu_item page $tr_menu_id "manual" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "fr")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "fr" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "fr" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "fr" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "fr")
add_custom_link_menu_item $tr_menu_id "Pour les donateurs potentiels" "http://synecoculture.test/fr/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Dons en partenariat avec l'Université de Kyoto" "http://synecoculture.test/fr/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Rapport sur l'utilisation des dons" "http://synecoculture.test/fr/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "Consultation pour la recherche collaborative" "http://synecoculture.test/fr/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $tr_menu_id "blog" "fr"
add_post_type_menu_item page $tr_menu_id "news" "fr"
add_post_type_menu_item page $tr_menu_id "contact" "fr"

###
### フッタープライマリ（中国語）
###

# メニューの作成
tr_menu_title="フッタープライマリ（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "footer_primary" $tr_menu_id "zh"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "about" "zh")
add_custom_link_menu_item $tr_menu_id "我们的宗旨" "http://synecoculture.test/zh/about/#our-purpose" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/message" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "members" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/company-profile" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "about/history" "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "learn" "zh")
add_post_type_menu_item page $tr_menu_id "learn/about-synecoculture" "zh" $menu_item_id
add_post_type_menu_item project $tr_menu_id "syneco-portal" "zh" $menu_item_id "Syneco门户"
add_post_type_menu_item page $tr_menu_id "manual" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "case-studies" "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "projects" "zh")
add_taxonomy_term_menu_item "project_cat" "academics-and-research" $tr_menu_id "zh" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "collaboration-and-partnership" $tr_menu_id "zh" $menu_item_id
add_taxonomy_term_menu_item "project_cat" "education-and-outreach" $tr_menu_id "zh" $menu_item_id
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "join" "zh")
add_custom_link_menu_item $tr_menu_id "致考虑捐赠者" "http://synecoculture.test/zh/join/#for-prospective-donors" $menu_item_id
add_custom_link_menu_item $tr_menu_id "京都大学合作捐赠" "http://synecoculture.test/zh/join/#kyoto-university-partnership-donations" $menu_item_id
add_custom_link_menu_item $tr_menu_id "捐款使用报告" "http://synecoculture.test/zh/join/#donation-usage-report" $menu_item_id
add_custom_link_menu_item $tr_menu_id "合作研究·开发咨询" "http://synecoculture.test/zh/join/#joint-research-development-inquiries" $menu_item_id
add_post_type_menu_item page $tr_menu_id "blog" "zh"
add_post_type_menu_item page $tr_menu_id "news" "zh"
add_post_type_menu_item page $tr_menu_id "contact" "zh"





###
### フッターセカンダリ（日本語）
###

# メニューの作成
menu_title="フッターセカンダリ（日本語）"
menu_id=$(wp menu create "$menu_title" --porcelain)
message "menu_id: $menu_id" bold

# メニューをアサイン
assign_menu "footer_secondary" $menu_id

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $menu_id "resources")
add_post_type_menu_item page $menu_id "resources/faq" "" $menu_item_id
add_post_type_menu_item page $menu_id "resources/documents" "" $menu_item_id
add_post_type_menu_item page $menu_id "resources/glossary" "" $menu_item_id
add_post_type_menu_item page $menu_id "resources/related-links" "" $menu_item_id
add_post_type_menu_item page $menu_id "careers"
add_post_type_menu_item page $menu_id "privacy-policy"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $menu_id

###
### フッターセカンダリ（英語）
###

# メニューの作成
tr_menu_title="フッターセカンダリ（英語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "footer_secondary" $tr_menu_id "en"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "resources" "en")
add_post_type_menu_item page $tr_menu_id "resources/faq" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/documents" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/glossary" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/related-links" "en" $menu_item_id
add_post_type_menu_item page $tr_menu_id "careers" "en"
add_post_type_menu_item page $tr_menu_id "privacy-policy" "en"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### フッターセカンダリ（フランス語）
###

# メニューの作成
tr_menu_title="フッターセカンダリ（フランス語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "footer_secondary" $tr_menu_id "fr"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "resources" "fr")
add_post_type_menu_item page $tr_menu_id "resources/faq" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/documents" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/glossary" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/related-links" "fr" $menu_item_id
add_post_type_menu_item page $tr_menu_id "careers" "fr"
add_post_type_menu_item page $tr_menu_id "privacy-policy" "fr"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### フッターセカンダリ（中国語）
###

# メニューの作成
tr_menu_title="フッターセカンダリ（中国語）"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)
message "tr_menu_id: $tr_menu_id"

# メニューをアサイン
assign_menu "footer_secondary" $tr_menu_id "zh"

# メニューアイテムを追加
menu_item_id=$(add_post_type_menu_item page $tr_menu_id "resources" "zh")
add_post_type_menu_item page $tr_menu_id "resources/faq" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/documents" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/glossary" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "resources/related-links" "zh" $menu_item_id
add_post_type_menu_item page $tr_menu_id "careers" "zh"
add_post_type_menu_item page $tr_menu_id "privacy-policy" "zh"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id
