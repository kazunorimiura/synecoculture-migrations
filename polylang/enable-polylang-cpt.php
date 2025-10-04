<?php
// 事前条件: Polylang(Pro) が有効化済み。CPT/tax は register_post_type / register_taxonomy 済み。

if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}

$opt = PLL()->options;

// 対象（存在チェックも行う）
$want_post_types = ['blog', 'project', 'case-study', 'member', 'glossary', 'career',];
$want_taxonomies = ['blog_cat', 'blog_tag', 'project_cat', 'project_domain', 'project_tag', 'area', 'case_study_tag', 'member_cat', 'member_tag', 'glossary_tag', 'career_cat', 'career_tag'];

// 存在チェック（警告表示のみ。見つかったものだけ反映）
$valid_pts = [];
foreach ($want_post_types as $pt) {
    $obj = get_post_type_object($pt);
    if ($obj) { $valid_pts[] = $pt; }
    else { fwrite(STDERR, "WARN: post type '{$pt}' が見つかりません。登録済みか確認してください。\n"); }
}

$valid_txs = [];
foreach ($want_taxonomies as $tx) {
    $obj = get_taxonomy($tx);
    if ($obj) { $valid_txs[] = $tx; }
    else { fwrite(STDERR, "WARN: taxonomy '{$tx}' が見つかりません。登録済みか確認してください。\n"); }
}

// 反映（GUIでチェックを入れるのと同等）
// PLL_Settings_CPT::prepare_raw_data() に合わせ、配列のキー名は 'post_types' と 'taxonomies'
$e1 = $opt->set('post_types', $valid_pts);
$e2 = $opt->set('taxonomies', $valid_txs);

// エラーハンドリング
foreach ([['post_types',$e1], ['taxonomies',$e2]] as [$k,$err]) {
    if ($err instanceof WP_Error && $err->has_errors()) {
        foreach ($err->errors as $code=>$msgs) {
            foreach ($msgs as $m) { fwrite(STDERR, "ERROR {$k} {$code}: {$m}\n"); }
        }
        WP_CLI::error("{$k} の保存に失敗しました。");
    }
}

// 反映結果の表示
$translated_pts = PLL()->model->get_translated_post_types(true);
$translated_txs = PLL()->model->get_translated_taxonomies(true);

echo "OK: 翻訳管理を有効化しました。\n";
echo "Post Types (translated): " . implode(', ', $translated_pts) . "\n";
echo "Taxonomies (translated): " . implode(', ', $translated_txs) . "\n";

// 参考: Polylang の内部キャッシュは必要に応じて自動更新されますが、気になる場合は下記で書き換え後に再構築可能。
// PLL()->model->clean_languages_cache();
// flush_rewrite_rules();
