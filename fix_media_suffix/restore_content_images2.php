<?php
/**
 * 記事本文の画像参照のうち、restore_content_images.php の対象外だった残りを直す。
 *
 *  (1) テスト環境ドメイン（kzmr.work）を指しているURL
 *      → 同じパスの画像が本番にあるものだけ、本番ドメインに書き換える。
 *        本番に無いものは触らない（差し替えても表示できないため）。
 *
 *  (2) 移行でファイル名が変わった個別ケース（下の MAP）
 *      - IMG_5420: 本文が古い画像編集版(-e1547632954311)を指している。
 *                  添付の実体は -e1547633006885。
 *      - 鯛ノ浦 IMG_0629: 移行時に全角スペースがハイフンへ正規化された。
 *
 * いずれも「置き換え先のファイルが実在すること」を確認してから書き込む。
 * post_modified は変えず、リビジョンも作らない。
 *
 * 使い方:
 *   wp eval-file restore_content_images2.php          # ドライラン
 *   wp eval-file restore_content_images2.php apply    # 適用
 */

$apply = in_array( 'apply', (array) $args, true );

global $wpdb;
$upload  = wp_get_upload_dir();
$basedir = $upload['basedir'];
$baseurl = $upload['baseurl'];

// (2) 個別の置き換え表: 現在の相対パス => 正しい相対パス
$MAP = array(
	'2019/01/IMG_5420-e1547632954311-450x600.jpg' => '2019/01/IMG_5420-e1547633006885-450x600.jpg',
	'2019/01/IMG_5420-e1547632954311.jpg'         => '2019/01/IMG_5420-e1547633006885.jpg',
	'2019/06/鯛ノ浦　IMG_0629-600x338.jpg'        => '2019/06/鯛ノ浦-IMG_0629-600x338.jpg',
	'2019/06/鯛ノ浦　IMG_0629.jpg'                => '2019/06/鯛ノ浦-IMG_0629.jpg',
);

$rows = $wpdb->get_results(
	"SELECT ID, post_type, post_title, post_content FROM {$wpdb->posts}
	  WHERE (post_content LIKE '%kzmr.work%' OR post_content LIKE '%IMG_5420-e1547632954311%' OR post_content LIKE '%鯛ノ浦　IMG_0629%')
	    AND post_status NOT IN ('trash','auto-draft')"
);

$plan    = array();
$skipped = array();

foreach ( $rows as $row ) {
	$content = $row->post_content;
	$changes = array();

	// (1) テスト環境ドメイン
	if ( preg_match_all( '/https?:\/\/[^"\'\s<>]*kzmr\.work\/wp-content\/uploads\/([^"\'\s<>]+)/i', $content, $m, PREG_SET_ORDER ) ) {
		foreach ( $m as $hit ) {
			$full = $hit[0];
			$rel  = $hit[1];
			if ( ! file_exists( $basedir . '/' . rawurldecode( $rel ) ) ) {
				$skipped[] = array( $row->ID, $rel, '本番に無いため据え置き' );
				continue;
			}
			$new = $baseurl . '/' . $rel;
			if ( false === strpos( $content, $full ) ) {
				continue;
			}
			$content   = str_replace( $full, $new, $content );
			$changes[] = array( 'ドメイン', $rel );
		}
	}

	// (2) 個別の置き換え
	foreach ( $MAP as $from => $to ) {
		if ( false === strpos( $content, $from ) ) {
			continue;
		}
		if ( ! file_exists( $basedir . '/' . $to ) ) {
			$skipped[] = array( $row->ID, $from, '置き換え先が無い: ' . $to );
			continue;
		}
		$content   = str_replace( $from, $to, $content );
		$changes[] = array( 'ファイル名', $from . ' -> ' . $to );
	}

	if ( $changes && $content !== $row->post_content ) {
		$plan[] = array( 'row' => $row, 'content' => $content, 'changes' => $changes );
	}
}

WP_CLI::log( $apply ? '*** APPLY モード ***' : '*** DRY RUN（書き込みなし）***' );
WP_CLI::log( '' );
$total = array_sum( array_map( function ( $p ) { return count( $p['changes'] ); }, $plan ) );
WP_CLI::log( sprintf( '対象記事: %d 件 / 置換箇所: %d 件 / 据え置き: %d 件', count( $plan ), $total, count( $skipped ) ) );
WP_CLI::log( '' );

foreach ( $plan as $p ) {
	WP_CLI::log( sprintf( '[%d] %s (%s)', $p['row']->ID, mb_substr( $p['row']->post_title, 0, 40 ), $p['row']->post_type ) );
	foreach ( $p['changes'] as $c ) {
		WP_CLI::log( sprintf( '     %-10s %s', $c[0], $c[1] ) );
	}
}

if ( $skipped ) {
	WP_CLI::log( '' );
	WP_CLI::log( '=== 据え置き（手動対応が必要） ===' );
	foreach ( $skipped as $s ) {
		WP_CLI::log( sprintf( '  記事%-7d %-58s %s', $s[0], $s[1], $s[2] ) );
	}
}

if ( ! $apply ) {
	WP_CLI::log( '' );
	WP_CLI::success( 'ドライラン完了。実行するには引数に apply を付けてください。' );
	return;
}

$done = 0;
foreach ( $plan as $p ) {
	$ok = $wpdb->update( $wpdb->posts, array( 'post_content' => $p['content'] ), array( 'ID' => $p['row']->ID ) );
	if ( false === $ok ) {
		WP_CLI::warning( sprintf( '記事 %d の更新に失敗しました', $p['row']->ID ) );
		continue;
	}
	clean_post_cache( $p['row']->ID );
	$done += count( $p['changes'] );
}
WP_CLI::success( sprintf( '%d 記事 / %d 箇所を修正しました。', count( $plan ), $done ) );
