<?php
// 事前条件: Polylang(Pro) が有効化済み
if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}

$want = [
  'taxonomies',         // タクソノミー
  'comment_status',     // コメントのステータス
  'ping_status',        // Ping のステータス
  'sticky_posts',       // 固定投稿
  'post_date',          // 公開日
  'post_format',        // 投稿フォーマット
  'post_parent',        // 親ページ
  '_wp_page_template',  // ページテンプレート
  'menu_order',         // ページの順序
  '_thumbnail_id',      // アイキャッチ画像
  // 'post_meta',       // カスタムフィールドも必要なら追加
];

$opt = PLL()->options;
$err = $opt->set('sync', $want);
if ( $err instanceof WP_Error && $err->has_errors() ) {
    foreach ($err->errors as $code=>$msgs){
        foreach($msgs as $m){ fwrite(STDERR, "ERROR {$code}: {$m}\n"); }
    }
    WP_CLI::error('同期設定の保存に失敗しました。');
}

$current = $opt->get('sync');
echo "OK: 同期を有効化しました。\n";
echo "SYNC: " . implode(', ', (array)$current) . "\n";
