<?php
/**
 * WordPress 複数ユーザー一括作成スクリプト（既存ユーザー削除対応版）
 * 使用方法: wp eval-file ./migrations/users/create-users.php
 */

/**
 * .envファイルを読み込む関数
 */
function load_env_file( $file_path ) {
    if ( ! file_exists( $file_path ) ) {
        WP_CLI::error( ".envファイルが見つかりません: {$file_path}" );
        return array();
    }

    $env_vars = array();
    $lines = file( $file_path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES );

    foreach ( $lines as $line ) {
        // コメント行をスキップ
        if ( strpos( trim( $line ), '#' ) === 0 ) {
            continue;
        }

        // KEY=VALUE形式をパース
        if ( strpos( $line, '=' ) !== false ) {
            list( $key, $value ) = explode( '=', $line, 2 );
            $key = trim( $key );
            $value = trim( $value );

            // クォートを削除
            $value = trim( $value, '"' );
            $value = trim( $value, "'" );

            $env_vars[ $key ] = $value;
        }
    }

    return $env_vars;
}

// .envファイルを読み込み
$env_file = '/srv/www/synecoculture/migrations/.env';
WP_CLI::log( ".envファイルパス: {$env_file}" );

$env = load_env_file( $env_file );

WP_CLI::log( ".envファイルを読み込みました: {$env_file}" );

// ユーザーデータを配列で定義
$users = array(
	array(
        'username'     => 'synecoculture',
        'email'        => 'synecoculture@example.com',
        'password'     => isset( $env['SYNECOCULTURE_PASSWORD'] ) ? $env['SYNECOCULTURE_PASSWORD'] : $env['DEFAULT_PASSWORD'],
        'role'         => 'administrator',
        'first_name'   => '編集部',
        'last_name'    => 'シネコ',
        'nickname' => 'シネコ編集部',
        'display_name' => 'シネコ編集部',
        'description_ja'  => '一般社団法人シネコカルチャーは、拡張生態系の研究・普及に取り組む団体です。シネコカルチャーという総合的な文化圏の構築を目指しています。',
        'description_en'  => '一般社団法人シネコカルチャーは、拡張生態系の研究・普及に取り組む団体です。シネコカルチャーという総合的な文化圏の構築を目指しています。',
        'description_fr'  => '一般社団法人シネコカルチャーは、拡張生態系の研究・普及に取り組む団体です。シネコカルチャーという総合的な文化圏の構築を目指しています。',
        'description_zh'  => '一般社団法人シネコカルチャーは、拡張生態系の研究・普及に取り組む団体です。シネコカルチャーという総合的な文化圏の構築を目指しています。',
		'avatar' => '2025/10/site-icon.png',
    ),
	// array(
    //     'username'     => 'masatoshi-funabashi',
    //     'email'        => 'masatoshi-funabashi@example.com',
    //     'password'     => isset( $env['FUNABASHI_PASSWORD'] ) ? $env['FUNABASHI_PASSWORD'] : $env['DEFAULT_PASSWORD'],
    //     'role'         => 'administrator',
    //     'first_name'   => '真俊',
    //     'last_name'    => '舩橋',
    //     'display_name' => '舩橋 真俊',
    //     'description_ja'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    //     'description_en'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    //     'description_fr'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    //     'description_zh'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    // ),
    // array(
    //     'username'     => 'tatsuya-kawaoka',
    //     'email'        => 'tatsuya-kawaoka@example.com',
    //     'password'     => isset( $env['KAWAOKA_PASSWORD'] ) ? $env['KAWAOKA_PASSWORD'] : $env['DEFAULT_PASSWORD'],
    //     'role'         => 'editor',
    //     'first_name'   => '辰弥',
    //     'last_name'    => '河岡',
    //     'display_name' => '河岡 辰弥',
    //     'description_ja'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    //     'description_en'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    //     'description_fr'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    //     'description_zh'  => '一般社団法人シネコカルチャー リサーチャー。人間活動により生態系が回復する拡張生態系の研究や社会実装に従事。専門は生命科学。経済発展に伴う食料生産手段の変化や生態系機能の低下と免疫関連疾患の増加に関する研究を行う。長期的社会課題に対する根本的な解決策に繋がる社会装置の開発や文化形成に取り組んでいる。株式会社ソニーコンピュータサイエンス研究所 トランスバウンダリーリサーチ プロジェクトリサーチャー、京都大学 人と社会の未来研究院 非常勤研究員。',
    // ),
);

// カウンター
$created = 0;
$replaced = 0;
$failed = 0;

WP_CLI::log( '========================================' );
WP_CLI::log( 'ユーザー作成を開始します...' );
WP_CLI::log( '========================================' );

foreach ( $users as $index => $user_data ) {
    WP_CLI::log( '' );
    WP_CLI::log( sprintf( '[%d/%d] %s を処理中...', $index + 1, count( $users ), $user_data['username'] ) );

    // 必須フィールドのチェック
    if ( empty( $user_data['username'] ) || empty( $user_data['email'] ) || empty( $user_data['password'] ) ) {
        WP_CLI::warning( '  ⚠ スキップ: 必須フィールド（username, email, password）が不足しています。' );
        $failed++;
        continue;
    }

    $existing_user_id = null;
    $is_replacing = false;

    // ユーザー名の重複チェック
    $existing_user_id_by_username = username_exists( $user_data['username'] );
    if ( $existing_user_id_by_username ) {
        WP_CLI::log( "  → ユーザー名 '{$user_data['username']}' が既に存在します（ID: {$existing_user_id_by_username}）" );
        $existing_user_id = $existing_user_id_by_username;
        $is_replacing = true;
    }

    // メールアドレスの重複チェック
    $existing_user_id_by_email = email_exists( $user_data['email'] );
    if ( $existing_user_id_by_email ) {
        WP_CLI::log( "  → メールアドレス '{$user_data['email']}' が既に使用されています（ID: {$existing_user_id_by_email}）" );
        if ( ! $existing_user_id ) {
            $existing_user_id = $existing_user_id_by_email;
        }
        $is_replacing = true;
    }

    // 既存ユーザーを削除
    if ( $existing_user_id ) {
        // 管理者ユーザー（ID=1）の削除を防止
        if ( $existing_user_id == 1 ) {
            WP_CLI::error( '  ✗ 失敗: 管理者ユーザー（ID=1）は削除できません。', false );
            $failed++;
            continue;
        }

        WP_CLI::log( "  → 既存ユーザー（ID: {$existing_user_id}）を削除しています..." );

        // ユーザーを削除（投稿の再割り当てなし）
        // 第二引数をnullにすると投稿も削除される
        // 特定のユーザーに再割り当てしたい場合は、そのユーザーIDを指定
        $deleted = wp_delete_user( $existing_user_id );

        if ( ! $deleted ) {
            WP_CLI::error( '  ✗ 失敗: 既存ユーザーの削除に失敗しました。', false );
            $failed++;
            continue;
        }

        WP_CLI::log( "  ✓ 既存ユーザー（ID: {$existing_user_id}）を削除しました。" );
    }

    // ユーザー作成用のデータを準備
    $user_args = array(
        'user_login'   => $user_data['username'],
        'user_pass'    => $user_data['password'],
        'user_email'   => $user_data['email'],
        'role'         => isset( $user_data['role'] ) ? $user_data['role'] : 'subscriber',
        'first_name'   => isset( $user_data['first_name'] ) ? $user_data['first_name'] : '',
        'last_name'    => isset( $user_data['last_name'] ) ? $user_data['last_name'] : '',
        'display_name' => isset( $user_data['display_name'] ) ? $user_data['display_name'] : $user_data['username'],
        'nickname' => isset( $user_data['nickname'] ) ? $user_data['nickname'] : $user_data['username'],
    );

    // ユーザーを作成
    $user_id = wp_insert_user( $user_args );

    if ( is_wp_error( $user_id ) ) {
        WP_CLI::error( '  ✗ 失敗: ' . $user_id->get_error_message(), false );
        $failed++;
    } else {
        // カスタムメタデータを追加
        $description_ja = isset( $user_data['description_ja'] ) ? $user_data['description_ja'] : '';
        $description_en = isset( $user_data['description_en'] ) ? $user_data['description_en'] : '';
        $description_fr = isset( $user_data['description_fr'] ) ? $user_data['description_fr'] : '';
        $description_zh = isset( $user_data['description_zh'] ) ? $user_data['description_zh'] : '';

        update_metadata( 'user', $user_id, "description", $description_ja );
        update_metadata( 'user', $user_id, "description_en", $description_en );
        update_metadata( 'user', $user_id, "description_fr", $description_fr );
        update_metadata( 'user', $user_id, "description_zh", $description_zh );

		if ( isset( $user_data['avatar'] ) ) {
			$attach_id = attachment_url_to_postid('http://synecoculture.test/wp-content/uploads/' . $user_data['avatar']);

			if ($attach_id) {
				delete_user_meta($user_id, 'mm_sua_attachment_id');
				add_user_meta($user_id, 'mm_sua_attachment_id', (int) $attach_id);
			}
		}

        if ( $is_replacing ) {
            WP_CLI::success( sprintf(
                '  ✓ 置き換え完了: ID=%d, ユーザー名=%s, 権限=%s',
                $user_id,
                $user_data['username'],
                $user_args['role']
            ) );
            $replaced++;
        } else {
            WP_CLI::success( sprintf(
                '  ✓ 作成完了: ID=%d, ユーザー名=%s, 権限=%s',
                $user_id,
                $user_data['username'],
                $user_args['role']
            ) );
            $created++;
        }
    }
}

// 結果サマリー
WP_CLI::log( '' );
WP_CLI::log( '========================================' );
WP_CLI::log( '処理完了' );
WP_CLI::log( '========================================' );
WP_CLI::log( sprintf( '新規作成: %d件', $created ) );
WP_CLI::log( sprintf( '置き換え: %d件', $replaced ) );
WP_CLI::log( sprintf( '失敗: %d件', $failed ) );
WP_CLI::log( sprintf( '合計: %d件', count( $users ) ) );
WP_CLI::log( '========================================' );

if ( $created > 0 || $replaced > 0 ) {
    WP_CLI::success( sprintf( '%d件のユーザーが正常に処理されました！（新規: %d件、置き換え: %d件）',
        $created + $replaced, $created, $replaced ) );
}
