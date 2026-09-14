<?php
/**
 * 本番サイトの「いま誰か作業しているか」「指定時刻以降に更新があったか」を確認する。
 *
 * 使い方:
 *   wp eval-file check_activity.php                        # 直近24時間
 *   wp eval-file check_activity.php 2026-09-14T02:19:00    # 指定時刻(UTC)以降
 *
 * 本番のログインシェルが csh 系で引用符の扱いが異なるため、日付は T 区切りでも受ける。
 */

global $wpdb;

$cutoff_gmt = str_replace( 'T', ' ', $args[0] ?? gmdate( 'Y-m-d H:i:s', time() - DAY_IN_SECONDS ) );
$now        = time();

function jst( $gmt ) {
	return get_date_from_gmt( $gmt, 'Y-m-d H:i:s' );
}

WP_CLI::log( '現在時刻 : ' . wp_date( 'Y-m-d H:i:s' ) . ' (' . wp_timezone_string() . ')' );
WP_CLI::log( '基準時刻 : ' . jst( $cutoff_gmt ) . ' 以降を対象' );
WP_CLI::log( str_repeat( '=', 70 ) );

// --- 1. 基準時刻以降に更新された投稿 -------------------------------------
$posts = $wpdb->get_results(
	$wpdb->prepare(
		"SELECT ID, post_type, post_status, post_title, post_modified, post_modified_gmt, post_author
		   FROM {$wpdb->posts}
		  WHERE post_modified_gmt > %s
		    AND post_type NOT IN ('revision')
		  ORDER BY post_modified_gmt DESC
		  LIMIT 50",
		$cutoff_gmt
	)
);
WP_CLI::log( sprintf( "\n【1】基準時刻以降に更新された投稿: %d 件", count( $posts ) ) );
foreach ( $posts as $p ) {
	$u = get_userdata( $p->post_author );
	WP_CLI::log( sprintf( '  %-7d %-10s %-9s %s  %s  [%s]',
		$p->ID, $p->post_type, $p->post_status, $p->post_modified,
		mb_substr( $p->post_title, 0, 30 ), $u ? $u->user_login : '?' ) );
}

// --- 2. リビジョン / オートセーブ ----------------------------------------
$revs = $wpdb->get_results(
	$wpdb->prepare(
		"SELECT ID, post_parent, post_name, post_date
		   FROM {$wpdb->posts}
		  WHERE post_type = 'revision' AND post_date_gmt > %s
		  ORDER BY post_date_gmt DESC LIMIT 30",
		$cutoff_gmt
	)
);
WP_CLI::log( sprintf( "\n【2】基準時刻以降のリビジョン/オートセーブ: %d 件", count( $revs ) ) );
foreach ( $revs as $r ) {
	$kind = ( false !== strpos( $r->post_name, 'autosave' ) ) ? 'オートセーブ' : 'リビジョン';
	WP_CLI::log( sprintf( '  %-7d 親=%-7d %-12s %s', $r->ID, $r->post_parent, $kind, $r->post_date ) );
}

// --- 3. 編集ロック（いま管理画面で開かれている投稿） ----------------------
$locks = $wpdb->get_results(
	"SELECT post_id, meta_value FROM {$wpdb->postmeta} WHERE meta_key = '_edit_lock'"
);
$active = array();
foreach ( $locks as $l ) {
	list( $ts, $uid ) = array_pad( explode( ':', $l->meta_value ), 2, 0 );
	$age = $now - (int) $ts;
	if ( $age <= 900 ) { // 15分以内 = 実質いま開いている
		$active[] = array( $l->post_id, (int) $uid, $age );
	}
}
usort( $active, function ( $a, $b ) { return $a[2] <=> $b[2]; } );
WP_CLI::log( sprintf( "\n【3】いま編集画面で開かれている投稿（直近15分のロック）: %d 件", count( $active ) ) );
foreach ( $active as $a ) {
	$u = get_userdata( $a[1] );
	WP_CLI::log( sprintf( '  投稿%-7d %-14s %d 秒前  "%s"',
		$a[0], $u ? $u->user_login : '?', $a[2], mb_substr( get_the_title( $a[0] ), 0, 30 ) ) );
}

// --- 4. 有効なログインセッション ------------------------------------------
$rows = $wpdb->get_results(
	"SELECT user_id, meta_value FROM {$wpdb->usermeta} WHERE meta_key = 'session_tokens'"
);
WP_CLI::log( "\n【4】有効なログインセッション" );
$n = 0;
foreach ( $rows as $r ) {
	$tokens = maybe_unserialize( $r->meta_value );
	if ( ! is_array( $tokens ) ) {
		continue;
	}
	$u = get_userdata( $r->user_id );
	foreach ( $tokens as $t ) {
		if ( empty( $t['expiration'] ) || $t['expiration'] < $now ) {
			continue;
		}
		$n++;
		WP_CLI::log( sprintf( '  %-16s ログイン: %s  有効期限: %s',
			$u ? $u->user_login : ( 'user#' . $r->user_id ),
			isset( $t['login'] ) ? wp_date( 'Y-m-d H:i', $t['login'] ) : '?',
			wp_date( 'Y-m-d H:i', $t['expiration'] ) ) );
	}
}
if ( 0 === $n ) {
	WP_CLI::log( '  （なし）' );
}

WP_CLI::log( "\n" . str_repeat( '=', 70 ) );
WP_CLI::log( sprintf( '判定材料: 更新 %d 件 / リビジョン %d 件 / 編集中 %d 件 / セッション %d 件',
	count( $posts ), count( $revs ), count( $active ), $n ) );
