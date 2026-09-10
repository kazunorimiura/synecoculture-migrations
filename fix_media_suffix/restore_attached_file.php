<?php
/**
 * fix_media_suffix の一括 search-replace が壊した添付メタを復元する。
 *
 * 症状:
 *   _wp_attached_file / _wp_attachment_metadata['file'] だけが `-N` 付きの
 *   別画像を指し、sizes[*]['file'] と width/height は元画像のまま残っている。
 *   ディレクトリを含むパス（2019/03/Picture1.png）だけが置換にヒットし、
 *   ベース名だけの sizes（Picture1-600x400.png）は取り残されたため。
 *
 * 使い方:
 *   wp eval-file fix_attached_file.php            # ドライラン
 *   wp eval-file fix_attached_file.php apply      # 実適用
 */

$apply = in_array('apply', (array) $args, true);

global $wpdb;
$upload  = wp_get_upload_dir();
$basedir = $upload['basedir'];

$rows = $wpdb->get_results(
	"SELECT post_id, meta_value FROM {$wpdb->postmeta} WHERE meta_key = '_wp_attachment_metadata'"
);

$plan    = array();
$skipped = array();
$scanned = 0;

foreach ( $rows as $row ) {
	$meta = maybe_unserialize( $row->meta_value );
	if ( ! is_array( $meta ) || empty( $meta['file'] ) || empty( $meta['sizes'] ) || ! is_array( $meta['sizes'] ) ) {
		continue;
	}
	$scanned++;

	// meta['file'] のベース名。-scaled / -rotated は WP 標準なので退避して比較対象から外す。
	$file_base = pathinfo( basename( $meta['file'] ), PATHINFO_FILENAME );
	$core      = preg_replace( '/-(scaled|rotated)$/', '', $file_base );
	$wp_suffix = substr( $file_base, strlen( $core ) );

	// sizes[*]['file'] から -WxH を落として共通のベース名を求める。
	$bases = array();
	foreach ( $meta['sizes'] as $size ) {
		if ( empty( $size['file'] ) ) {
			continue;
		}
		$bases[ preg_replace( '/-\d+x\d+$/', '', pathinfo( $size['file'], PATHINFO_FILENAME ) ) ] = true;
	}
	if ( count( $bases ) !== 1 ) {
		continue; // ベース名が割れているものは自動判定しない
	}
	// PHP は数字だけのキーを int に変換するので、必ず文字列に戻してから比較する。
	$size_base = (string) key( $bases );

	if ( $core === $size_base ) {
		continue; // 正常
	}
	// 「sizes のベース名 + -数字」の形のときだけ本件の破損とみなす。
	if ( ! preg_match( '/^' . preg_quote( $size_base, '/' ) . '-\d+$/', $core ) ) {
		continue;
	}

	$dir     = dirname( $meta['file'] );
	$ext     = pathinfo( $meta['file'], PATHINFO_EXTENSION );
	$correct = ( '.' === $dir ? '' : $dir . '/' ) . $size_base . $wp_suffix . '.' . $ext;

	$id      = (int) $row->post_id;
	$attached = get_post_meta( $id, '_wp_attached_file', true );

	// --- 安全確認 3 点 ---------------------------------------------------
	// 1. 復元先のファイルが実在するか
	if ( ! file_exists( $basedir . '/' . $correct ) ) {
		$skipped[] = array( $id, $meta['file'], $correct, 'FILE_MISSING' );
		continue;
	}
	// 2. meta の width/height が復元先ファイルの実寸と一致するか
	$dim = @getimagesize( $basedir . '/' . $correct );
	if ( ! $dim || (int) ( $meta['width'] ?? 0 ) !== (int) $dim[0] || (int) ( $meta['height'] ?? 0 ) !== (int) $dim[1] ) {
		$skipped[] = array( $id, $meta['file'], $correct, 'DIM_MISMATCH' );
		continue;
	}
	// 3. guid（search-replace が --skip-columns=guid で除外していた）と突き合わせ
	$guid     = get_post_field( 'guid', $id );
	$guid_ok  = ( $guid && false !== strpos( $guid, '/' . $correct ) ) ? 'GUID_OK' : 'GUID_NG';

	$plan[] = array(
		'id'       => $id,
		'from'     => $meta['file'],
		'to'       => $correct,
		'attached' => $attached,
		'guid'     => $guid_ok,
		'meta'     => $meta,
	);
}

// --- レポート -------------------------------------------------------------
WP_CLI::log( $apply ? '*** APPLY モード ***' : '*** DRY RUN（--書き込みなし）***' );
WP_CLI::log( '' );
WP_CLI::log( sprintf( '走査した添付メタ: %d 件 / 復元対象: %d 件 / スキップ: %d 件', $scanned, count( $plan ), count( $skipped ) ) );
WP_CLI::log( '' );

if ( $skipped ) {
	WP_CLI::log( '=== スキップ（要手動確認） ===' );
	foreach ( $skipped as $s ) {
		WP_CLI::log( implode( "\t", $s ) );
	}
	WP_CLI::log( '' );
}

WP_CLI::log( '=== 復元プラン（ID / 現在 → 復元先 / guid 照合 / _wp_attached_file の現在値が meta と一致するか） ===' );
$guid_ng = 0;
foreach ( $plan as $p ) {
	$sync = ( $p['attached'] === $p['from'] ) ? 'IN_SYNC' : 'ATTACHED=' . $p['attached'];
	if ( 'GUID_NG' === $p['guid'] ) {
		$guid_ng++;
	}
	WP_CLI::log( sprintf( "%-6d %s\n       -> %s\n       %s / %s", $p['id'], $p['from'], $p['to'], $p['guid'], $sync ) );
}
WP_CLI::log( '' );
WP_CLI::log( sprintf( 'guid と一致しなかったもの: %d 件', $guid_ng ) );
WP_CLI::log( '' );

// --- 適用 -----------------------------------------------------------------
if ( ! $apply ) {
	WP_CLI::success( 'ドライラン完了。実行するには引数に apply を付けてください。' );
	return;
}

$done = 0;
foreach ( $plan as $p ) {
	$meta         = $p['meta'];
	$meta['file'] = $p['to'];
	update_post_meta( $p['id'], '_wp_attached_file', $p['to'] );
	update_post_meta( $p['id'], '_wp_attachment_metadata', $meta );
	clean_post_cache( $p['id'] );
	$done++;
	WP_CLI::log( sprintf( '修正: %d  %s -> %s', $p['id'], $p['from'], $p['to'] ) );
}
WP_CLI::success( sprintf( '%d 件を修正しました。', $done ) );
