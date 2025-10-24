<?php
/**
 * WP-CLI: 投稿の投稿者を一括変更
 * 実行方法: wp eval-file ./migrations/users/update-post-authors.php
 */

// 投稿の設定を配列で定義
$posts_to_update = [
    [
        'post_type' => 'blog',
        'post_slug' => 'post-3312', // Dubai World Expo 2020 へシネコ茶を提供
        'username'  => 'synecoculture',
    ],
    // 必要に応じて追加
];

WP_CLI::log('投稿者の一括変更を開始します...');
WP_CLI::log('---');

$success_count = 0;
$error_count = 0;

foreach ($posts_to_update as $index => $item) {
    $post_type = $item['post_type'];
    $post_slug = $item['post_slug'];
    $username  = $item['username'];

    WP_CLI::log(sprintf(
        '[%d/%d] 処理中: タイプ=%s, スラッグ=%s, ユーザー=%s',
        $index + 1,
        count($posts_to_update),
        $post_type,
        $post_slug,
        $username
    ));

    // ユーザーを取得
    $user = get_user_by('login', $username);
    if (!$user) {
        WP_CLI::warning("ユーザー '{$username}' が見つかりません。スキップします。");
        $error_count++;
        WP_CLI::log('---');
        continue;
    }

    // 投稿を取得
    $args = [
        'post_type'      => $post_type,
        'name'           => $post_slug,
        'posts_per_page' => 1,
        'post_status'    => 'any',
    ];

    $posts = get_posts($args);

    if (empty($posts)) {
        WP_CLI::warning("投稿が見つかりません (タイプ: {$post_type}, スラッグ: {$post_slug})");
        $error_count++;
        WP_CLI::log('---');
        continue;
    }

	foreach ($posts as $post) {
		// 投稿者を更新
		$result = wp_update_post([
			'ID'          => $post->ID,
			'post_author' => $user->ID,
		], true);

		if (is_wp_error($result)) {
			WP_CLI::error(
				sprintf('投稿ID %d の更新に失敗しました: %s', $post->ID, $result->get_error_message()),
				false
			);
			$error_count++;
		} else {
			WP_CLI::success(
				sprintf(
					'投稿ID %d の投稿者を %s (ID: %d) に変更しました',
					$post->ID,
					$username,
					$user->ID
				)
			);
			$success_count++;
		}
	}

    WP_CLI::log('---');
}

// 結果サマリー
WP_CLI::log('');
WP_CLI::log('=== 処理結果 ===');
WP_CLI::log(sprintf('成功: %d件', $success_count));
if ($error_count > 0) {
    WP_CLI::log(sprintf('失敗: %d件', $error_count));
}
WP_CLI::log('すべての処理が完了しました');
