<?php
/**
 * 記事本文（post_content）の img src / a href が、その img が属する添付以外の
 * ファイルを指している箇所を復元する。
 *
 * fix_media_suffix の一括 search-replace は postmeta だけでなく post_content の
 * 画像URLも書き換えた。署名は「サイズ接尾辞の直前に -数字 が1つ余計に入る」
 * （ESMA-600x338.png -> ESMA-1-600x338.png）。この形だけを対象にする。
 *
 * class="wp-image-N" がその img の正解（どの添付のものか）を持っているので、
 * 添付が所有するファイル一覧と突き合わせて判定する。置換は figure / a ブロック
 * 単位に限定するため、同じ本文に正当な ESMA-1-600x338.png があっても巻き込まない。
 *
 * post_modified は変えず、リビジョンも作らないよう $wpdb->update で直接書き込む。
 *
 * 使い方:
 *   wp eval-file restore_content_images.php               # ドライラン
 *   wp eval-file restore_content_images.php apply         # 適用
 *   wp eval-file restore_content_images.php apply norev   # リビジョンは対象外にする
 */

$apply   = in_array( 'apply', (array) $args, true );
$skiprev = in_array( 'norev', (array) $args, true );

global $wpdb;

/** 添付が所有するファイル名の集合を返す。 */
function owned_files( $id ) {
	static $cache = array(); // wp eval-file はメソッドスコープなので static で持つ
	if ( array_key_exists( $id, $cache ) ) {
		return $cache[ $id ];
	}
	$meta = wp_get_attachment_metadata( $id );
	if ( ! is_array( $meta ) || empty( $meta['file'] ) ) {
		return $cache[ $id ] = null;
	}
	$files = array( basename( $meta['file'] ) => true );
	if ( ! empty( $meta['sizes'] ) && is_array( $meta['sizes'] ) ) {
		foreach ( $meta['sizes'] as $s ) {
			if ( ! empty( $s['file'] ) ) {
				$files[ $s['file'] ] = true;
			}
		}
	}
	return $cache[ $id ] = $files;
}

/** $file が所有ファイルに対して「-数字が1つ余計」な形なら正しい名前を、でなければ '' を返す。 */
function find_extra_suffix_fix( $file, $files ) {
	if ( preg_match( '/^(.+)-(\d+x\d+)\.([^.]+)$/', $file, $m ) ) {
		list( , $src_base, $dim, $ext ) = $m;
		foreach ( array_keys( $files ) as $f ) {
			if ( preg_match( '/^(.+)-' . preg_quote( $dim, '/' ) . '\.' . preg_quote( $ext, '/' ) . '$/', $f, $mm )
				&& preg_match( '/^' . preg_quote( $mm[1], '/' ) . '-\d+$/', $src_base ) ) {
				return $f;
			}
		}
		return '';
	}
	if ( preg_match( '/^(.+)\.([^.]+)$/', $file, $m ) ) {
		list( , $src_base, $ext ) = $m;
		foreach ( array_keys( $files ) as $f ) {
			if ( preg_match( '/^(.+)\.' . preg_quote( $ext, '/' ) . '$/', $f, $mm )
				&& preg_match( '/^' . preg_quote( $mm[1], '/' ) . '-\d+$/', $src_base ) ) {
				return $f;
			}
		}
	}
	return '';
}

$upload  = wp_get_upload_dir();
$basedir = $upload['basedir'];
$baseurl = $upload['baseurl'];

$where = "post_content LIKE '%wp-image-%' AND post_status NOT IN ('trash','auto-draft')";
if ( $skiprev ) {
	$where .= " AND post_type <> 'revision'";
}
$rows = $wpdb->get_results( "SELECT ID, post_type, post_title, post_content FROM {$wpdb->posts} WHERE {$where}" );

$plan    = array(); // post_id => [ 'content' => 新本文, 'changes' => [...] ]
$skipped = array();
$total   = 0;

foreach ( $rows as $row ) {
	$changes = array();

	$new_content = preg_replace_callback(
		'/<figure[^>]*>.*?<\/figure>|<a[^>]*>\s*<img[^>]*>\s*<\/a>|<img[^>]*>/is',
		function ( $mm ) use ( &$changes, $basedir, $baseurl ) {
			$block = $mm[0];
			if ( ! preg_match( '/<img[^>]*>/i', $block, $t ) || ! preg_match( '/wp-image-(\d+)/', $t[0], $m ) ) {
				return $block;
			}
			$id    = (int) $m[1];
			$files = owned_files( $id );
			if ( null === $files ) {
				return $block;
			}

			$targets = array();
			if ( preg_match( '/\ssrc="([^"]+)"/i', $t[0], $s ) ) {
				$targets['src'] = $s[1];
			}
			if ( preg_match( '/<a[^>]*\shref="([^"]+)"/i', $block, $h )
				&& preg_match( '/\.(png|jpe?g|gif|webp)$/i', $h[1] ) ) {
				$targets['href'] = $h[1];
			}

			foreach ( $targets as $kind => $url ) {
				$path = parse_url( $url, PHP_URL_PATH );
				if ( ! $path ) {
					continue;
				}
				$file = basename( $path );
				if ( isset( $files[ $file ] ) ) {
					continue;
				}
				$correct = find_extra_suffix_fix( $file, $files );
				if ( '' === $correct ) {
					continue;
				}
				// 復元先ファイルが実在しなければ触らない
				$dir = trim( str_replace( $baseurl, '', dirname( $url ) ), '/' );
				if ( ! file_exists( $basedir . '/' . $dir . '/' . $correct ) ) {
					$changes[] = array( $id, $kind, $file, $correct, 'SKIP_FILE_MISSING' );
					continue;
				}
				// このブロック内に限定して置換する
				$block     = str_replace( $file, $correct, $block );
				$changes[] = array( $id, $kind, $file, $correct, 'FIX' );
			}
			return $block;
		},
		$row->post_content
	);

	if ( ! $changes || $new_content === $row->post_content ) {
		foreach ( $changes as $c ) {
			if ( 'FIX' !== $c[4] ) {
				$skipped[] = array_merge( array( $row->ID ), $c );
			}
		}
		continue;
	}
	$fixes = array_filter( $changes, function ( $c ) { return 'FIX' === $c[4]; } );
	foreach ( $changes as $c ) {
		if ( 'FIX' !== $c[4] ) {
			$skipped[] = array_merge( array( $row->ID ), $c );
		}
	}
	$total += count( $fixes );
	$plan[] = array( 'row' => $row, 'content' => $new_content, 'changes' => $fixes );
}

WP_CLI::log( $apply ? '*** APPLY モード ***' : '*** DRY RUN（書き込みなし）***' );
if ( $skiprev ) {
	WP_CLI::log( '（リビジョンは対象外）' );
}
WP_CLI::log( '' );
WP_CLI::log( sprintf( '対象記事: %d 件 / 置換箇所: %d 件 / スキップ: %d 件', count( $plan ), $total, count( $skipped ) ) );
WP_CLI::log( '' );

foreach ( $plan as $p ) {
	WP_CLI::log( sprintf( '[%d] %s (%s)', $p['row']->ID, mb_substr( $p['row']->post_title, 0, 40 ), $p['row']->post_type ) );
	foreach ( $p['changes'] as $c ) {
		WP_CLI::log( sprintf( '     添付%-6d %-5s %s -> %s', $c[0], $c[1], $c[2], $c[3] ) );
	}
}

if ( $skipped ) {
	WP_CLI::log( '' );
	WP_CLI::log( '=== スキップ（復元先ファイルなし。要手動確認） ===' );
	foreach ( $skipped as $s ) {
		WP_CLI::log( implode( "\t", $s ) );
	}
}

if ( ! $apply ) {
	WP_CLI::log( '' );
	WP_CLI::success( 'ドライラン完了。実行するには引数に apply を付けてください。' );
	return;
}

$done = 0;
foreach ( $plan as $p ) {
	// post_modified を変えず、リビジョンも作らないため直接 UPDATE する
	$ok = $wpdb->update(
		$wpdb->posts,
		array( 'post_content' => $p['content'] ),
		array( 'ID' => $p['row']->ID )
	);
	if ( false === $ok ) {
		WP_CLI::warning( sprintf( '記事 %d の更新に失敗しました', $p['row']->ID ) );
		continue;
	}
	clean_post_cache( $p['row']->ID );
	$done += count( $p['changes'] );
}
WP_CLI::success( sprintf( '%d 記事 / %d 箇所を修正しました。', count( $plan ), $done ) );
