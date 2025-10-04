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

add_page_menu_item() {
  local menu_id=$1
  local page_slug=$2
  local language=$3  # 省略可能
  local parent_id=$4      # 省略可能

  # 親子関係の設定
  local parent_setting=""
  if [ -n "$parent_id" ]; then
    parent_setting=', "menu-item-parent-id" => '$parent_id
  fi

  # 言語コードの処理とメッセージ作成
  local lang_msg=""
  local page_code=""
  if [ -n "$language" ]; then
    page_code='
    $page = get_page_by_path("'$page_slug'", OBJECT, "page");
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
    $page = get_page_by_path("'$page_slug'", OBJECT, "page");
    if (!$page) {
      echo "ERROR: Page not found";
      return;
    }
    '
  fi

  # メニューアイテムの追加
  local result=$(wp eval "$page_code"'
  $menu_item_id = wp_update_nav_menu_item( '$menu_id', 0, array(
    "menu-item-title" => $page->post_title,
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
    message "Failed to add '$page_slug' menu item for '$menu_id'$lang_msg: ${result#ERROR: }" "warning"
    return 1
  fi

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
    message "Error: menu_id, title, and url are required" "warning"
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
    message "Failed to add custom link '$title' to menu '$menu_id': ${result#ERROR: }" "warning"
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
menu_item_id=$(add_page_menu_item $menu_id "about")
add_custom_link_menu_item $menu_id "社団の存在意義" "http://synecoculture.test/about/#our-purpose"
add_page_menu_item $menu_id "message" "" $menu_item_id
add_page_menu_item $menu_id "members" "" $menu_item_id
add_page_menu_item $menu_id "company-profile" "" $menu_item_id
add_page_menu_item $menu_id "history" "" $menu_item_id
menu_item_id=$(add_page_menu_item $menu_id "learn")
add_page_menu_item $menu_id "about-synecoculture" "" $menu_item_id
add_page_menu_item $menu_id "syneco-portal" "" $menu_item_id
add_page_menu_item $menu_id "manual" "" $menu_item_id
add_page_menu_item $menu_id "case-studies" "" $menu_item_id

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
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "en")
add_page_menu_item $tr_menu_id "about-synecoculture" "en" $menu_item_id

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
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "fr")
add_page_menu_item $tr_menu_id "about-synecoculture" "fr" $menu_item_id

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
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "zh")
add_page_menu_item $tr_menu_id "about-synecoculture" "zh" $menu_item_id

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
tr_menu_title="Primary CTA"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)

# メニューをテーマに設定
assign_menu "primary_cta" $tr_menu_id "en"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### プライマリCTA（フランス語）
###

# メニューの作成
tr_menu_title="Appel à l'action principal"
tr_menu_id=$(wp menu create "$tr_menu_title" --porcelain)

# メニューをテーマに設定
assign_menu "primary_cta" $tr_menu_id "fr"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

###
### プライマリCTA（中国語）
###

# メニューの作成
tr_menu_title="主要号召性用语"
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
add_page_menu_item $menu_id "home"
menu_item_id=$(add_page_menu_item $menu_id "about")
add_page_menu_item $menu_id "about-synecoculture" "" $menu_item_id

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
add_page_menu_item $tr_menu_id "home" "en"
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "en")
add_page_menu_item $tr_menu_id "about-synecoculture" "" $menu_item_id "en"

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
add_page_menu_item $tr_menu_id "home" "fr"
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "fr")
add_page_menu_item $tr_menu_id "about-synecoculture" "" $menu_item_id "fr"

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
add_page_menu_item $tr_menu_id "home" "zh"
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "zh")
add_page_menu_item $tr_menu_id "about-synecoculture" "" $menu_item_id "zh"

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
add_page_menu_item $menu_id "resources"
add_page_menu_item $menu_id "careers"
add_page_menu_item $menu_id "privacy-policy"

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
add_page_menu_item $tr_menu_id "resources" "en"
add_page_menu_item $tr_menu_id "careers" "en"
add_page_menu_item $tr_menu_id "privacy-policy" "en"

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
add_page_menu_item $tr_menu_id "resources" "fr"
add_page_menu_item $tr_menu_id "careers" "fr"
add_page_menu_item $tr_menu_id "privacy-policy" "fr"

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
add_page_menu_item $tr_menu_id "resources" "zh"
add_page_menu_item $tr_menu_id "careers" "zh"
add_page_menu_item $tr_menu_id "privacy-policy" "zh"

# 言語スイッチャーを追加
./migrations/menu_migrations/add_polylang_switcher.sh $tr_menu_id

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
menu_item_id=$(add_page_menu_item $menu_id "about")
add_page_menu_item $menu_id "about-synecoculture" "" $menu_item_id

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
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "en")
add_page_menu_item $tr_menu_id "about-synecoculture" "en" $menu_item_id

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
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "fr")
add_page_menu_item $tr_menu_id "about-synecoculture" "fr" $menu_item_id

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
menu_item_id=$(add_page_menu_item $tr_menu_id "about" "zh")
add_page_menu_item $tr_menu_id "about-synecoculture" "zh" $menu_item_id
