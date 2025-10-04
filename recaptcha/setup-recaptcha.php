<?php
/**
 * reCAPTCHAのサイトキー、シークレットキーを設定する（MW WP Form reCAPTCHAプラグイン用）
 *
 * 使用方法:
 * wp eval-file ./migrations/page_migrations/setup-recaptcha.php
 */

// MW WP Formプラグインが有効かチェック
if (!class_exists('MW_WP_Form_reCAPTCHA')) {
    WP_CLI::error('MW WP Form reCAPTCHAプラグインが有効化されていません。');
    return;
}

$recaptcha_site_key = getenv('RECAPTCHA_SITE_KEY') ?: '';
if ( $recaptcha_site_key === '' ) {
    WP_CLI::error('環境変数 RECAPTCHA_SITE_KEY が未設定です。');
}

$recaptcha_secret_key = getenv('RECAPTCHA_SECRET_KEY') ?: '';
if ( $recaptcha_secret_key === '' ) {
    WP_CLI::error('環境変数 RECAPTCHA_SECRET_KEY が未設定です。');
}

$options = array(
	'site_key' => $recaptcha_site_key,
	'secret_key' => $recaptcha_secret_key,
	'threshold_score' => ''
);

$option_key = 'mwfrv3';

$result = update_option($option_key, $options);
if ($result) {
	WP_CLI::success('MW WP Form reCAPTCHAプラグインのサイトキー、シークレットキーを更新しました。');
} else {
	WP_CLI::error('MW WP Form reCAPTCHAプラグインのサイトキー、シークレットキーの更新に失敗しました。');
}
?>
