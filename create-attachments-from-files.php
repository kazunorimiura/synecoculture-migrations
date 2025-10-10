<?php
// wp eval-file ./migrations/create-attachments-from-files.php

$xml_path = '/srv/www/synecoculture/migrations/blog/media.xml'; // ← ここを実際のパスに変更

// ファイル存在チェック
if (!file_exists($xml_path)) {
    WP_CLI::error("XMLファイルが見つかりません: {$xml_path}");
    exit;
}

WP_CLI::log("XMLファイル読み込み中: {$xml_path}");

// XML読み込み
libxml_use_internal_errors(true);
$xml = simplexml_load_file($xml_path);

if ($xml === false) {
    WP_CLI::error("XML解析エラー:");
    foreach(libxml_get_errors() as $error) {
        WP_CLI::log("  " . $error->message);
    }
    exit;
}

WP_CLI::log("XML読み込み成功");

$upload_dir = wp_upload_dir();
$processed = 0;
$skipped = 0;
$errors = 0;

foreach ($xml->channel->item as $item) {
    $post_type = (string)$item->children('wp', true)->post_type;

    if ($post_type !== 'attachment') {
        continue;
    }

    $attachment_url = (string)$item->children('wp', true)->attachment_url;
    WP_CLI::log("処理中: {$attachment_url}");

    // URLからファイル名とパスを抽出
    $parsed = parse_url($attachment_url);
    $path_parts = pathinfo($parsed['path']);

    // 複数のパスパターンを試行
    $possible_paths = array(
        $upload_dir['basedir'] . $parsed['path'], // フルパス
        $upload_dir['basedir'] . '/' . basename($parsed['path']), // ファイル名のみ
    );

    // パスからuploads以降を抽出してみる
    if (preg_match('#/uploads/(.+)$#', $parsed['path'], $matches)) {
        $possible_paths[] = $upload_dir['basedir'] . '/' . $matches[1];
    }

    $filepath = null;
    foreach ($possible_paths as $path) {
        if (file_exists($path)) {
            $filepath = $path;
            break;
        }
    }

    if (!$filepath) {
        WP_CLI::warning("ファイルが見つかりません。試行パス:");
        foreach ($possible_paths as $path) {
            WP_CLI::log("  - {$path}");
        }
        $skipped++;
        continue;
    }

    WP_CLI::log("ファイル発見: {$filepath}");

    // attachment作成
    $attachment_data = array(
        'post_title' => (string)$item->title,
        'post_content' => (string)$item->children('content', true)->encoded,
        'post_excerpt' => (string)$item->children('excerpt', true)->encoded,
        'post_status' => 'inherit',
        'post_mime_type' => wp_check_filetype($filepath)['type'],
        'guid' => $attachment_url,
        'post_date' => (string)$item->children('wp', true)->post_date,
    );

    $post_parent = (int)$item->children('wp', true)->post_parent;
    $attach_id = wp_insert_attachment($attachment_data, $filepath, $post_parent);

    if (is_wp_error($attach_id)) {
        WP_CLI::error("エラー: " . $attach_id->get_error_message());
        $errors++;
        continue;
    }

    require_once(ABSPATH . 'wp-admin/includes/image.php');
    // wp_update_attachment_metadata($attach_id, wp_generate_attachment_metadata($attach_id, $filepath));
	$attach_data = array('file' => _wp_relative_upload_path($filepath));
	wp_update_attachment_metadata($attach_id, $attach_data);

    WP_CLI::success("作成成功 ID: {$attach_id}");
    $processed++;
}

WP_CLI::success("完了: 成功={$processed}, スキップ={$skipped}, エラー={$errors}");
