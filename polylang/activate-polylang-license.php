<?php
/**
 * Polylang Pro / アドオンのライセンスを「設定して有効化」するスクリプト
 * 使い方:
 *   POLYLANG_LICENSE_KEY='xxxxx' wp eval-file activate-polylang-license.php
 * 必要に応じて以下を環境変数で上書き可能:
 *   PRODUCT_NAME  … 既定: "Polylang Pro"
 *   PLUGIN_FILE   … 既定: "polylang-pro/polylang.php"
 *   AUTHOR        … 既定: "WP SYNTEX"
 */

if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}
if ( ! class_exists('PLL_License') ) {
    WP_CLI::error('PLL_License クラスが見つかりません。Polylang Pro/アドオンが正しく読み込まれているか確認してください。');
}

$license_key = getenv('POLYLANG_LICENSE_KEY') ?: '';
if ( $license_key === '' ) {
    WP_CLI::error('環境変数 POLYLANG_LICENSE_KEY が未設定です。');
}

echo " - license_key       : " . substr($license_key, 0, 10) . "...\n";

$product_name = getenv('PRODUCT_NAME') ?: 'Polylang Pro';
$plugin_file  = getenv('PLUGIN_FILE')  ?: 'polylang-pro/polylang.php';
$author       = getenv('AUTHOR')       ?: 'WP SYNTEX';

require_once ABSPATH . 'wp-admin/includes/plugin.php';
$plugins = get_plugins();

if ( ! isset($plugins[$plugin_file]) ) {
    WP_CLI::error("プラグインファイルが見つかりません: {$plugin_file}");
}
$version = $plugins[$plugin_file]['Version'] ?? '';
if ( $version === '' ) {
    // 念のためのフォールバック（空でも動作はします）
    $version = '0.0.0';
}

$license = new PLL_License(WP_PLUGIN_DIR . '/' . $plugin_file, $product_name, $version, $author);

// 有効化を実行（キー保存 + APIへ edd_action=activate_license）
$license->activate_license($license_key);

// 結果の確認表示
$licenses = (array) get_option( 'polylang_licenses', array() );
$id = sanitize_title($product_name);
$license           = isset( $licenses[ $id ] ) && is_array( $licenses[ $id ] ) ? $licenses[ $id ] : array();
$license_key = ! empty( $license['key'] ) ? (string) $license['key'] : '';

$license_data = (object) array();
if ( ! empty( $license['data'] ) ) {
	$license_data = (object) $license['data'];
}

$success = is_object($license_data) && isset($license_data->success) && $license_data->success ? 'enabled' : 'unknown';
$error = is_object($license_data) && isset($license_data->error) ? $license_data->error : 'unknown';
$expires = is_object($license_data) && isset($license_data->expires) ? $license_data->expires : 'n/a';

echo "OK: {$product_name} ライセンスを有効化しました。\n";
echo " - id       : {$id}\n";
echo " - key       : " . substr($license_key, 0, 10) . "...\n";
echo " - success   : {$success}\n";
echo " - error   : {$error}\n";
echo " - expires  : {$expires}\n";

// アップデート検出を確認したい場合は、続けて CLI で以下を実行:
// wp plu
