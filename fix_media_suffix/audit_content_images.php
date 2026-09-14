<?php
/**
 * 記事本文（post_content）の img src / a href が、その img が属する添付以外の
 * ファイルを指している箇所を検出する。
 *
 * fix_media_suffix の一括 search-replace は postmeta だけでなく post_content の
 * 画像URLも書き換えた。その署名は「サイズ接尾辞の直前に -数字 が1つ余計に入る」
 * （ESMA-600x338.png -> ESMA-1-600x338.png）。この形だけを対象にする。
 *
 * -scaled / 旧サイズ / 画像編集版(-eXXXX) の不一致は別要因なので、件数だけ報告する。
 *
 * 使い方:
 *   wp eval-file audit_content_images.php
 */

global $wpdb;

$rows = $wpdb->get_results(
	"SELECT ID, post_type, post_status, post_title, post_content
	   FROM {$wpdb->posts}
	  WHERE post_content LIKE '%wp-image-%'
	    AND post_status NOT IN ('trash','auto-draft')"
);

/** 添付が所有するファイル名の集合を返す。先頭はフルサイズ。 */
function owned_files( $id ) {
	// wp eval-file はメソッドスコープで評価されるため、キャッシュは static で持つ。
	static $cache = array();
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

/**
 * $file がこの添付の所有ファイルに対して「-数字が1つ余計」な形なら、正しい名前を返す。
 * それ以外は '' を返す。
 */
function find_extra_suffix_fix( $file, $files ) {
	// サイズ付き: base-<N>-600x338.png  <-> base-600x338.png
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
	// フルサイズ: base-<N>.png <-> base.png
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

$damaged = array();   // 今回の署名に合致
$other   = 0;         // 不一致だが署名外（-scaled・旧サイズ・編集版など）
$no_meta = 0;
$imgs    = 0;

foreach ( $rows as $row ) {
	if ( ! preg_match_all( '/<figure[^>]*>.*?<\/figure>|<a[^>]*>\s*<img[^>]*>\s*<\/a>|<img[^>]*>/is', $row->post_content, $blocks ) ) {
		continue;
	}
	foreach ( $blocks[0] as $block ) {
		if ( ! preg_match( '/<img[^>]*>/i', $block, $t ) || ! preg_match( '/wp-image-(\d+)/', $t[0], $m ) ) {
			continue;
		}
		$tag = $t[0];
		$id  = (int) $m[1];
		$imgs++;

		$files = owned_files( $id );
		if ( null === $files ) {
			$no_meta++;
			continue;
		}

		$targets = array();
		if ( preg_match( '/\ssrc="([^"]+)"/i', $tag, $s ) ) {
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
				continue; // 正常
			}
			$correct = find_extra_suffix_fix( $file, $files );
			if ( '' === $correct ) {
				$other++;
				continue;
			}
			// 復元先ファイルが実在するか（URLのディレクトリ部分を流用）
			$dir    = trim( str_replace( $upload['baseurl'], '', dirname( $url ) ), '/' );
			$exists = file_exists( $basedir . '/' . $dir . '/' . $correct ) ? 'OK' : 'MISSING';
			$damaged[] = array( $row->ID, $row->post_type, $id, $kind, $file, $correct, $exists, $row->post_title );
		}
	}
}

printf( "検査した img（wp-image-N 付き）: %d 件 / 対象記事: %d 件\n", $imgs, count( $rows ) );
printf( "署名外の不一致（-scaled・旧サイズ・編集版など／対象外）: %d 件\n", $other );
printf( "添付メタなし: %d 件\n\n", $no_meta );

printf( "=== 今回の破損（-数字が1つ余計）: %d 件 ===\n", count( $damaged ) );
printf( "%-6s %-8s %-6s %-5s %-34s %-34s %-8s %s\n", '記事', 'type', '添付', '箇所', '現在', '正しい', 'ファイル', 'タイトル' );
foreach ( $damaged as $d ) {
	printf( "%-6d %-8s %-6d %-5s %-34s %-34s %-8s %s\n", $d[0], $d[1], $d[2], $d[3], $d[4], $d[5], $d[6], mb_substr( $d[7], 0, 30 ) );
}
