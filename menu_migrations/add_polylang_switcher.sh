#!/bin/bash

# Polylang言語スイッチャー追加スクリプト
# 使用方法: ./add_polylang_switcher.sh [メニュー名またはID] [オプション]

set -e

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘルプ表示
show_help() {
    cat << EOF
使用方法: $0 [オプション] [メニュー名またはID]

オプション:
    -l, --list              利用可能なメニュー一覧を表示
    -h, --help              このヘルプを表示
    --show-flags            フラグを表示 (デフォルト: true)
    --show-names            言語名を表示 (デフォルト: true)
    --dropdown              ドロップダウン形式 (デフォルト: false)
    --hide-current          現在の言語を非表示 (デフォルト: false)
    --hide-no-translation   翻訳がない場合に非表示 (デフォルト: false)
    --force-home            ホームページにリンク (デフォルト: false)

例:
    $0 --list                           # メニュー一覧を表示
    $0 "Main Menu"                      # Main Menuに言語スイッチャーを追加
    $0 --dropdown --hide-current 1      # ID 1のメニューにドロップダウン形式で追加
    $0 --show-flags --show-names "Header" # Headerメニューにフラグと名前を表示

EOF
}

# デフォルトオプション
SHOW_FLAGS=0
SHOW_NAMES=1
DROPDOWN=1
HIDE_CURRENT=0
HIDE_NO_TRANSLATION=0
FORCE_HOME=0
LIST_MENUS=0

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--list)
            LIST_MENUS=1
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --show-flags)
            SHOW_FLAGS=1
            shift
            ;;
        --no-flags)
            SHOW_FLAGS=0
            shift
            ;;
        --show-names)
            SHOW_NAMES=1
            shift
            ;;
        --no-names)
            SHOW_NAMES=0
            shift
            ;;
        --dropdown)
            DROPDOWN=1
            shift
            ;;
        --hide-current)
            HIDE_CURRENT=1
            shift
            ;;
        --hide-no-translation)
            HIDE_NO_TRANSLATION=1
            shift
            ;;
        --force-home)
            FORCE_HOME=1
            shift
            ;;
        -*)
            echo -e "${RED}エラー: 不明なオプション $1${NC}" >&2
            show_help
            exit 1
            ;;
        *)
            MENU_IDENTIFIER="$1"
            shift
            ;;
    esac
done

# WP-CLIが利用可能かチェック
if ! command -v wp &> /dev/null; then
    echo -e "${RED}エラー: WP-CLIが見つかりません。WP-CLIをインストールしてください。${NC}" >&2
    exit 1
fi

# WordPressディレクトリかチェック
if ! wp core is-installed --quiet 2>/dev/null; then
    echo -e "${RED}エラー: WordPressディレクトリではないか、WordPressがインストールされていません。${NC}" >&2
    exit 1
fi

# Polylangプラグインがアクティブかチェック
if ! wp plugin is-active polylang-pro --quiet 2>/dev/null; then
    echo -e "${RED}エラー: Polylangプラグインがアクティブではありません。${NC}" >&2
    exit 1
fi

# メニュー一覧表示
if [[ $LIST_MENUS -eq 1 ]]; then
    echo -e "${BLUE}利用可能なメニュー:${NC}"
    wp eval '
    $menus = wp_get_nav_menus();
    if (empty($menus)) {
        echo "メニューが見つかりません。\n";
        exit(1);
    }

    echo sprintf("%-5s %-20s %-30s\n", "ID", "名前", "場所");
    echo str_repeat("-", 60) . "\n";

    foreach ($menus as $menu) {
        $locations = get_nav_menu_locations();
        $location_names = [];
        foreach ($locations as $location => $menu_id) {
            if ($menu_id == $menu->term_id) {
                $location_names[] = $location;
            }
        }
        $location_str = implode(", ", $location_names);
        echo sprintf("%-5d %-20s %-30s\n", $menu->term_id, $menu->name, $location_str);
    }
    '
    exit 0
fi

# メニュー識別子が指定されていない場合
if [[ -z "$MENU_IDENTIFIER" ]]; then
    echo -e "${RED}エラー: メニュー名またはIDを指定してください。${NC}" >&2
    echo -e "${YELLOW}ヒント: --list オプションでメニュー一覧を確認できます。${NC}" >&2
    show_help
    exit 1
fi

echo -e "${BLUE}言語スイッチャーをメニューに追加中...${NC}"

# 言語スイッチャー追加のPHPコード
wp eval "
// 言語スイッチャー追加関数
function add_polylang_switcher_to_menu(\$menu_id, \$options = array()) {
    // デフォルトオプション
    \$default_options = array(
        'hide_if_no_translation' => 0,
        'hide_current' => 0,
        'force_home' => 0,
        'show_flags' => 1,
        'show_names' => 1,
        'dropdown' => 0
    );

    \$pll_options = array_merge(\$default_options, \$options);

    // 言語スイッチャーのメニューアイテムを作成
    \$menu_item_data = array(
        'menu-item-object-id' => -1,
        'menu-item-object' => '',
        'menu-item-parent-id' => 0,
        'menu-item-position' => 0,
        'menu-item-type' => 'custom',
        'menu-item-title' => __('Languages', 'polylang'),
        'menu-item-url' => '#pll_switcher',
        'menu-item-description' => '',
        'menu-item-attr-title' => '',
        'menu-item-target' => '',
        'menu-item-classes' => '',
        'menu-item-xfn' => '',
        'menu-item-status' => 'publish'
    );

    // メニューアイテムを追加
    \$menu_item_db_id = wp_update_nav_menu_item(\$menu_id, 0, \$menu_item_data);

    // エラーチェック
    if (is_wp_error(\$menu_item_db_id)) {
        return \$menu_item_db_id;
    }

    if (\$menu_item_db_id) {
        // Polylangの言語スイッチャーオプションを設定
        update_post_meta(\$menu_item_db_id, '_pll_menu_item', \$pll_options);
        return \$menu_item_db_id;
    }

    return false;
}

// メニューを取得
\$menu_identifier = '$MENU_IDENTIFIER';
\$menu = null;

// 数値の場合はIDとして扱う
if (is_numeric(\$menu_identifier)) {
    \$menu = wp_get_nav_menu_object(\$menu_identifier);
} else {
    // 文字列の場合は名前として検索
    \$menus = wp_get_nav_menus();
    foreach (\$menus as \$m) {
        if (\$m->name === \$menu_identifier) {
            \$menu = \$m;
            break;
        }
    }
}

if (!\$menu) {
    echo \"エラー: メニュー '\$menu_identifier' が見つかりません。\n\";
    exit(1);
}

// 既に言語スイッチャーが存在するかチェック
\$existing_items = get_posts(array(
    'numberposts' => -1,
    'post_type' => 'nav_menu_item',
    'meta_key' => '_pll_menu_item',
    'meta_query' => array(
        array(
            'key' => '_menu_item_menu_id',
            'value' => \$menu->term_id,
            'compare' => '='
        )
    )
));

if (!empty(\$existing_items)) {
    echo \"警告: メニュー '{\$menu->name}' には既に言語スイッチャーが存在します。\n\";
    echo \"既存の言語スイッチャーのID: \" . \$existing_items[0]->ID . \"\n\";
    exit(1);
}

// オプション設定
\$switcher_options = array(
    'hide_if_no_translation' => $HIDE_NO_TRANSLATION,
    'hide_current' => $HIDE_CURRENT,
    'force_home' => $FORCE_HOME,
    'show_flags' => $SHOW_FLAGS,
    'show_names' => $SHOW_NAMES,
    'dropdown' => $DROPDOWN
);

// 言語スイッチャーを追加
\$result = add_polylang_switcher_to_menu(\$menu->term_id, \$switcher_options);

if (is_wp_error(\$result)) {
    echo \"エラー: \" . \$result->get_error_message() . \"\n\";
    exit(1);
} elseif (\$result) {
    echo \"成功: メニュー '{\$menu->name}' (ID: {\$menu->term_id}) に言語スイッチャーを追加しました。\n\";
    echo \"メニューアイテムID: \$result\n\";
    echo \"オプション:\n\";
    foreach (\$switcher_options as \$key => \$value) {
        echo \"  \$key: \" . (\$value ? 'ON' : 'OFF') . \"\n\";
    }

    // メニューキャッシュをクリア
    wp_cache_delete('all_theme_mods', 'options');

    echo \"\n言語スイッチャーの追加が完了しました。\n\";
} else {
    echo \"エラー: 言語スイッチャーの追加に失敗しました。\n\";
    exit(1);
}
"

if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✓ 言語スイッチャーが正常に追加されました！${NC}"
    echo -e "${YELLOW}注意: 管理画面の「外観 > メニュー」で設定を確認・調整してください。${NC}"
else
    echo -e "${RED}✗ 言語スイッチャーの追加に失敗しました。${NC}" >&2
    exit 1
fi
