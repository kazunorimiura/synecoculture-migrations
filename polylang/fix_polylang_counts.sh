#!/bin/bash

# ./migrations/polylang/fix_polylang_counts.sh

# Polylang投稿数修正スクリプト
# メディアファイルを除外して正しい投稿数に修正します

set -e  # エラー時に停止

# 色付きメッセージ関数
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# WP-CLIの存在確認
if ! command -v wp &> /dev/null; then
    print_error "WP-CLIがインストールされていません"
    exit 1
fi

print_info "Polylang投稿数修正スクリプトを開始します"

# 現在の投稿数確認
print_info "修正前の投稿数を確認中..."
echo "=== 修正前の投稿数 ==="
wp db query "
SELECT t.name as language, tt.count, tt.taxonomy
FROM wp_term_taxonomy tt
JOIN wp_terms t ON tt.term_id = t.term_id
WHERE tt.taxonomy = 'language'
ORDER BY t.name;
" --skip-column-names

# 実際の投稿数確認
print_info "実際の投稿数（メディア除外）を確認中..."
echo "=== 実際の投稿数（メディア除外） ==="
wp db query "
SELECT t.name as language, COUNT(p.ID) as actual_count
FROM wp_terms t
JOIN wp_term_taxonomy tt ON t.term_id = tt.term_id
JOIN wp_term_relationships tr ON tt.term_taxonomy_id = tr.term_taxonomy_id
JOIN wp_posts p ON tr.object_id = p.ID
WHERE tt.taxonomy = 'language'
AND p.post_type NOT IN ('attachment', 'revision', 'nav_menu_item', 'custom_css', 'customize_changeset')
AND p.post_status IN ('publish', 'private')
GROUP BY t.name, tt.term_taxonomy_id
ORDER BY t.name;
" --skip-column-names

# 確認プロンプト
echo ""
read -p "投稿数を修正しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "処理をキャンセルしました"
    exit 0
fi

# 投稿数修正実行
print_info "投稿数を修正中..."

UPDATE_RESULT=$(wp db query "
UPDATE wp_term_taxonomy
SET count = (
    SELECT COUNT(*)
    FROM wp_posts p
    INNER JOIN wp_term_relationships tr ON p.ID = tr.object_id
    WHERE tr.term_taxonomy_id = wp_term_taxonomy.term_taxonomy_id
    AND p.post_type NOT IN ('attachment', 'revision', 'nav_menu_item', 'custom_css', 'customize_changeset')
    AND p.post_status IN ('publish', 'private')
)
WHERE taxonomy = 'language';
" 2>&1)

if [ $? -eq 0 ]; then
    print_success "投稿数の修正が完了しました"
else
    print_error "投稿数の修正に失敗しました: $UPDATE_RESULT"
    exit 1
fi

# Polylangキャッシュクリア
print_info "Polylangキャッシュをクリア中..."
wp eval "if (function_exists('PLL') && PLL()) { PLL()->model->clean_languages_cache(); echo 'キャッシュクリア完了'; } else { echo 'Polylangが見つかりません'; }"

# 修正後の結果確認
print_info "修正後の投稿数を確認中..."
echo "=== 修正後の投稿数 ==="
wp db query "
SELECT t.name as language, tt.count, tt.taxonomy
FROM wp_term_taxonomy tt
JOIN wp_terms t ON tt.term_id = t.term_id
WHERE tt.taxonomy = 'language'
ORDER BY t.name;
" --skip-column-names

print_success "すべての処理が完了しました！"
