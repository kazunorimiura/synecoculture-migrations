<?php
/**
 * 記事本文が参照しているのに実体が無い「切り出しサイズ」の画像を、元画像から作り直す。
 *
 * 移行で登録サイズの構成が変わったため、記事が指している -300x225 のような
 * 古いサイズのファイルが存在しなくなっている。元画像は残っているので、
 * そこから同じ寸法を生成すれば記事を書き換えずに表示が戻る。
 *
 * DB は一切触らない。作るのはファイルだけ。既に在るファイルは上書きしない。
 *
 * 使い方:
 *   wp eval-file regenerate_missing_sizes.php          # ドライラン
 *   wp eval-file regenerate_missing_sizes.php apply    # 生成する
 */

$apply = in_array( 'apply', (array) $args, true );

global $wpdb;
$upload  = wp_get_upload_dir();
$basedir = $upload['basedir'];
$baseurl = $upload['baseurl'];
$host    = wp_parse_url( $baseurl, PHP_URL_HOST );

$rows = $wpdb->get_results(
	"SELECT ID, post_content FROM {$wpdb->posts}
	  WHERE post_content LIKE '%wp-content/uploads%'
	    AND post_status NOT IN ('trash','auto-draft')
	    AND post_type <> 'revision'"
);

$targets  = array(); // rel => [w, h, orig_rel]
$external = array(); // 別ドメインを指しているもの
$noorig   = array(); // 元画像が無いもの
$seen     = array();

foreach ( $rows as $row ) {
	if ( ! preg_match_all( '/<img[^>]*\ssrc="([^"]+)"/i', $row->post_content, $m ) ) {
		continue;
	}
	foreach ( $m[1] as $url ) {
		$url = strtok( $url, '?' );
		if ( false === strpos( $url, '/wp-content/uploads/' ) ) {
			continue;
		}
		$uhost = wp_parse_url( $url, PHP_URL_HOST );
		if ( $uhost && $uhost !== $host ) {
			$external[ $url ][] = $row->ID;
			continue;
		}
		$rel = ltrim( str_replace( $baseurl, '', $url ), '/' );
		if ( isset( $seen[ $rel ] ) ) {
			continue;
		}
		$seen[ $rel ] = true;
		if ( file_exists( $basedir . '/' . $rel ) ) {
			continue;
		}
		if ( ! preg_match( '/^(.+)-(\d+)x(\d+)(\.[^.]+)$/', $rel, $d ) ) {
			$noorig[ $rel ] = '(サイズ指定なし)';
			continue;
		}
		$orig = $d[1] . $d[4];
		if ( ! file_exists( $basedir . '/' . $orig ) ) {
			$noorig[ $rel ] = $orig;
			continue;
		}
		$targets[ $rel ] = array( (int) $d[2], (int) $d[3], $orig );
	}
}

WP_CLI::log( $apply ? '*** APPLY モード ***' : '*** DRY RUN（ファイル生成なし）***' );
WP_CLI::log( '' );
WP_CLI::log( sprintf( '生成できる（元画像あり）: %d 件', count( $targets ) ) );
WP_CLI::log( sprintf( '元画像が無い/自動対象外  : %d 件', count( $noorig ) ) );
WP_CLI::log( sprintf( '別ドメインを参照         : %d 件', count( $external ) ) );
WP_CLI::log( '' );

if ( $noorig ) {
	WP_CLI::log( '=== 元画像が無く手動対応が必要 ===' );
	foreach ( $noorig as $rel => $orig ) {
		WP_CLI::log( sprintf( '  %-58s 元画像: %s', $rel, $orig ) );
	}
	WP_CLI::log( '' );
}
if ( $external ) {
	WP_CLI::log( '=== 別ドメインを参照（本番の画像ではない） ===' );
	foreach ( $external as $url => $ids ) {
		WP_CLI::log( sprintf( '  記事%-24s %s', implode( ',', array_unique( $ids ) ), $url ) );
	}
	WP_CLI::log( '' );
}

WP_CLI::log( '=== 生成対象 ===' );
$done = 0;
$fail = 0;
foreach ( $targets as $rel => $t ) {
	list( $w, $h, $orig ) = $t;
	$src  = $basedir . '/' . $orig;
	$dest = $basedir . '/' . $rel;

	if ( ! $apply ) {
		WP_CLI::log( sprintf( '  %-58s <- %s (%dx%d)', $rel, $orig, $w, $h ) );
		continue;
	}

	$editor = wp_get_image_editor( $src );
	if ( is_wp_error( $editor ) ) {
		WP_CLI::warning( sprintf( '%s: 画像を開けません (%s)', $orig, $editor->get_error_message() ) );
		$fail++;
		continue;
	}
	// まず切り抜きなしで試し、寸法が合わなければ切り抜きで作り直す。
	$editor->resize( $w, $h, false );
	$size = $editor->get_size();
	if ( (int) $size['width'] !== $w || (int) $size['height'] !== $h ) {
		$editor = wp_get_image_editor( $src );
		if ( is_wp_error( $editor ) ) {
			$fail++;
			continue;
		}
		$editor->resize( $w, $h, true );
		$size = $editor->get_size();
	}
	$saved = $editor->save( $dest );
	if ( is_wp_error( $saved ) ) {
		WP_CLI::warning( sprintf( '%s: 保存に失敗 (%s)', $rel, $saved->get_error_message() ) );
		$fail++;
		continue;
	}
	$done++;
	WP_CLI::log( sprintf( '  生成 %-58s %dx%d', $rel, (int) $size['width'], (int) $size['height'] ) );
}

WP_CLI::log( '' );
if ( ! $apply ) {
	WP_CLI::success( 'ドライラン完了。実行するには引数に apply を付けてください。' );
} else {
	WP_CLI::success( sprintf( '%d 件を生成しました（失敗 %d 件）。', $done, $fail ) );
}
