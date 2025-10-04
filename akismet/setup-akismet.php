<?php
/**
 * AkismetプラグインのAPIキーを設定する
 *
 * 使用方法:
 * wp eval-file ./migrations/akismet/setup-akismet.php
 */

// MW WP Formプラグインが有効かチェック
if (!class_exists('Akismet')) {
    WP_CLI::error('Akismetプラグインが有効化されていません。');
    return;
}

$akismet_api_key = getenv('AKISMET_API_KEY') ?: '';
if ( $akismet_api_key === '' ) {
    WP_CLI::error('環境変数 AKISMET_API_KEY が未設定です。');
}

$current_akismet_api_key = get_option('wordpress_api_key');

if (!$current_akismet_api_key) {
	$result = update_option('wordpress_api_key', $akismet_api_key);

	if ($result) {
		WP_CLI::success('AkismetプラグインのAPIキーを更新しました。');
	} else {
		WP_CLI::error('AkismetプラグインのAPIキーの更新に失敗しました。');
	}
} else {
	WP_CLI::log('AkismetプラグインのAPIキーはすでに設定済みであるためスキップします。');
}


$result = update_option('akismet_show_user_comments_approved', '0');

if ($result) {
	WP_CLI::success('コメントの投稿者の横に承認されたコメント数を表示するオプションを無効化しました。');
} else {
	WP_CLI::error('コメントの投稿者の横に承認されたコメント数を表示するオプションの無効化に失敗しました。');
}

?>
