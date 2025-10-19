<?php
/**
 * CSVファイルを読み込み、wp search-replaceコマンドを実行するスクリプト
 *
 * 使用方法:
 * wp eval-file ./migrations/fix_media_suffix/search-replace.php /path/to/file.csv
 * wp eval-file ./migrations/fix_media_suffix/search-replace.php ./migrations/fix_media_suffix/wp_suffix_report.csv
 */

// 引数からCSVファイルのパスとオプションを取得
$csv_file = $args[0] ?? null;
$dry_run = false;

if (empty($csv_file)) {
    WP_CLI::error('CSVファイルのパスを引数で指定してください。');
    exit;
}

if ($dry_run) {
    WP_CLI::warning('*** DRY RUNモード: 実際の置換は行われません ***');
    WP_CLI::log('');
}

if (!file_exists($csv_file)) {
    WP_CLI::error("CSVファイルが見つかりません: {$csv_file}");
    exit;
}

WP_CLI::log("CSVファイルを読み込んでいます: {$csv_file}");

// CSVファイルを開く
$handle = fopen($csv_file, 'r');
if ($handle === false) {
    WP_CLI::error("CSVファイルを開けませんでした: {$csv_file}");
    exit;
}

// ヘッダー行をスキップ
$headers = fgetcsv($handle);
WP_CLI::log("ヘッダー: " . implode(', ', $headers));

$total_count = 0;
$processed_count = 0;
$skipped_count = 0;

// 各行を処理
while (($row = fgetcsv($handle)) !== false) {
    $total_count++;

    // 列数のチェック
    if (count($row) < 3) {
        WP_CLI::warning("行 {$total_count}: 列数が不足しています。スキップします。");
        $skipped_count++;
        continue;
    }

    $new_file = trim($row[0]);
    $old_file = trim($row[1]);
	$new_filename = $filename = pathinfo($new_file, PATHINFO_FILENAME);
	$old_filename = $filename = pathinfo($old_file, PATHINFO_FILENAME);
    $file_exists = trim($row[2]);
	$attach_id = attachment_url_to_postid( 'http://synecoculture.test/wp-content/uploads/' . $new_file );

    // 元のファイル存在が"Yes"の場合のみ処理
    if (strcasecmp($file_exists, 'Yes') !== 0) {
        // WP_CLI::log("行 {$total_count}: 元のファイルが存在しないためスキップ - {$old_file}");
        $skipped_count++;
        continue;
    }

    // 空の値チェック
    if (empty($old_file) || empty($new_file)) {
        WP_CLI::warning("行 {$total_count}: 空の値が含まれています。スキップします。");
        $skipped_count++;
        continue;
    }

    WP_CLI::log("行 {$total_count}: 置換を実行 - '{$old_file} ({$old_filename})' → '{$new_file} ({$new_filename})'");

	if (!$attach_id) {
		WP_CLI::warning("画像IDが無効です");
        continue;
    }

	$metadata = wp_get_attachment_metadata($attach_id);
	WP_CLI::log("メタデータ: " . print_r($metadata, true));

	if (empty($metadata)) {
		WP_CLI::warning("メタデータを取得しましたが、中身が空でした");
        continue;
    }

	// 置換が必要なすべてのサイズバリエーションのファイル名を収集
	$replaced_files = collectAndReplaceFiles($metadata, $old_filename, $new_filename);
	WP_CLI::log("replaced_files: " . print_r($replaced_files, true));

	foreach ($replaced_files as $replaced_file) {
		WP_CLI::log("元: {$replaced_file['original']} → 新: {$replaced_file['replaced']}");

		try {
			// wp search-replaceコマンドを実行
			$command = sprintf(
				'search-replace %s %s --skip-columns=guid%s',
				escapeshellarg($replaced_file['original']),
				escapeshellarg($replaced_file['replaced']),
				$dry_run ? ' --dry-run' : ''
			);

			WP_CLI::runcommand($command, array(
				'launch' => false,
				'exit_error' => false,
				'return' => false
			));

			$processed_count++;

		} catch (Exception $e) {
			WP_CLI::warning("行 {$total_count}: エラーが発生しました - " . $e->getMessage());
		}
	}

    WP_CLI::log('');
}

fclose($handle);

// 結果のサマリーを表示
WP_CLI::log('');
if ($dry_run) {
    WP_CLI::success("DRY RUN完了: 実際の置換は行われていません。");
} else {
    WP_CLI::success("処理が完了しました。");
}
WP_CLI::log("総行数: {$total_count}");
WP_CLI::log("処理済み: {$processed_count}");
WP_CLI::log("スキップ: {$skipped_count}");


// すべてのfileパスを収集し、オリジナルと置換後の値を二次元配列で返す関数
function collectAndReplaceFiles($array, $oldName, $newName, &$result = []) {
    foreach ($array as $key => $value) {
        if ($key === 'file' && is_string($value)) {
            // オリジナルと置換後の値を配列に格納
            $result[] = [
                'original' => str_replace($newName, $oldName, basename($value)),
                'replaced' => basename($value)
            ];
        } elseif (is_array($value)) {
            // 再帰的に処理
            collectAndReplaceFiles($value, $oldName, $newName, $result);
        }
    }
    return $result;
}
