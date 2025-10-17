<?php
/**
 * WordPress XML エクスポートファイルから添付ファイルをインポート
 *
 * 使用方法: wp eval-file ./migrations/create-attachments-from-files.php /srv/www/synecoculture/migrations/blog/media.xml
 */

// XMLファイルのパスを引数から取得
$xml_file = $args[0] ?? '';

if (empty($xml_file) || !file_exists($xml_file)) {
    WP_CLI::error('XMLファイルのパスを指定してください。例: wp eval-file import-media.php /path/to/export.xml');
    return;
}

WP_CLI::log('XMLファイルを読み込んでいます...');

// XMLを読み込む
$xml = simplexml_load_file($xml_file);

if ($xml === false) {
    WP_CLI::error('XMLファイルの読み込みに失敗しました。');
    return;
}

// 名前空間を登録
$namespaces = $xml->getNamespaces(true);
$wp_namespace = $namespaces['wp'] ?? 'http://wordpress.org/export/1.2/';

// 統計情報
$total_count = 0;
$success_count = 0;
$error_count = 0;

WP_CLI::log('添付ファイルを処理しています...');

// 各アイテムを走査
foreach ($xml->channel->item as $item) {
    // 名前空間を使用して要素を取得
    $wp = $item->children($wp_namespace);

    // post_typeがattachmentかチェック
    $post_type = (string)$wp->post_type;

    if ($post_type !== 'attachment') {
        continue;
    }

    $total_count++;

    // post_idとattachment_urlを取得
    $post_id = (int)$wp->post_id;
    $attachment_url = (string)$wp->attachment_url;

    if (empty($post_id) || empty($attachment_url)) {
        WP_CLI::warning("スキップ: post_id または attachment_url が空です。");
        $error_count++;
        continue;
    }

    // URLからパスを抽出（ドメイン部分を除去）
    $parsed_url = parse_url($attachment_url);
    $path = $parsed_url['path'] ?? '';

    if (empty($path)) {
        WP_CLI::warning("スキップ (ID: {$post_id}): URLからパスを抽出できませんでした。");
        $error_count++;
        continue;
    }

    // 接頭辞を付けてフルパスを作成
    $full_path = '/srv/www/synecoculture/public_html' . $path;

    // ファイルの存在確認
    if (!file_exists($full_path)) {
        WP_CLI::warning("スキップ (ID: {$post_id}): ファイルが存在しません - {$full_path}");
        $error_count++;
        continue;
    }

    // wp media import コマンドを実行
    try {
        WP_CLI::log("インポート中 (ID: {$post_id}): {$full_path}");

        $result = WP_CLI::runcommand(
            "media import '{$full_path}' --post_id={$post_id} --skip-copy --porcelain",
            [
                'return' => 'all',
                'parse' => 'json',
                'launch' => false,
                'exit_error' => false
            ]
        );

        if ($result->return_code === 0) {
            WP_CLI::success("完了 (ID: {$post_id})");
            $success_count++;
        } else {
            WP_CLI::warning("エラー (ID: {$post_id}): " . $result->stderr);
            $error_count++;
        }

    } catch (Exception $e) {
        WP_CLI::warning("エラー (ID: {$post_id}): " . $e->getMessage());
        $error_count++;
    }
}

// 結果サマリーを表示
WP_CLI::log('');
WP_CLI::log('=== インポート完了 ===');
WP_CLI::log("総数: {$total_count}");
WP_CLI::success("成功: {$success_count}");
if ($error_count > 0) {
    WP_CLI::warning("エラー: {$error_count}");
}
