<?php
// 事前条件: Polylang(Pro) が有効化済みで、既定言語が ja に設定されている想定。

if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}

$pll = PLL();
$model = $pll->model;

// 既定言語の確認
$def = $model->get_default_language();
if ( ! $def ) {
    WP_CLI::error('既定言語が未設定です。先に既定言語を設定してください。');
}
echo "Default language: {$def->slug}\n";

// 参考: 対象を投稿/用語に限定して実行したい場合は第2引数に ['post','term'] を渡す
// このスクリプトは「投稿・固定ページ・カテゴリー・タグ」を意図しているため、明示的に両方指定します。
$types = ['post','term'];

// 実行前の未割当件数（ログ用）
$pre_posts = $model->get_posts_with_no_lang( $model->get_translated_post_types(), -1 );
$translated_taxonomies = $model->get_translated_taxonomies();
$pre_terms  = $model->get_terms_with_no_lang( $translated_taxonomies, -1 );

echo "Before: posts without lang = " . count($pre_posts) . ", terms without lang = " . count($pre_terms) . "\n";

// ★ 本命：未設定オブジェクトに既定言語を一括割当（内部で 1000 件ずつ再帰処理）
$model->set_language_in_mass( null, $types );

// 実行後の未割当件数（確認）
$post_after = $model->get_posts_with_no_lang( $model->get_translated_post_types(), -1 );
$term_after = $model->get_terms_with_no_lang( $translated_taxonomies, -1 );

echo "After : posts without lang = " . count($post_after) . ", terms without lang = " . count($term_after) . "\n";

// 補足: 大量件数でもモデル側で 1000 件バッチの再帰になっているため、そのままでOK。
// 必要なら PHP のメモリ/実行時間は WP-CLI 側で調整（例: WP_CLI_PHP_ARGS='-d memory_limit=512M' など）。
