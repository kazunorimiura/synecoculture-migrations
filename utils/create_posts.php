<?php
/**
 * WordPress投稿作成スクリプト（post_date対応版）
 * 使用方法: wp eval-file create_posts.php post_type target_lang_slug content_dir title_mapping_file
 * 例: wp eval-file create_posts.php page ja ./migrations/page_migrations/content_files ./migrations/page_migrations/content_files/title_mapping.csv
 *
 * CSV形式:
 * post_slug,lang_slug,title,parent_slug,excerpt,post_date
 */

// コマンドライン引数を取得（wp eval-fileでは$args変数に格納される）
if (!isset($args) || count($args) < 4) {
    echo "使用方法: wp eval-file create_posts.php post_type target_lang_slug content_dir title_mapping_file\n";
    echo "例: wp eval-file create_posts.php page ja ./migrations/page_migrations/content_files ./migrations/page_migrations/content_files/title_mapping.csv\n";
    exit(1);
}

$post_type = $args[0];
$target_lang_slug = $args[1];
$content_dir = $args[2];
$title_mapping_file = $args[3];

echo "=== 言語 '{$target_lang_slug}' のファイルを処理中 ===\n";

/**
 * CSVファイルからタイトルマッピング情報を読み込む
 */
function load_title_mapping($file_path) {
    $mapping = [];

    if (!file_exists($file_path)) {
        echo "エラー: タイトルマッピングファイルが見つかりません: {$file_path}\n";
        return $mapping;
    }

    $handle = fopen($file_path, 'r');
    if ($handle === false) {
        echo "エラー: ファイルを開けません: {$file_path}\n";
        return $mapping;
    }

    // ヘッダー行をスキップ
    $header = fgetcsv($handle);

    while (($data = fgetcsv($handle)) !== false) {
        if (count($data) >= 5) {
            $post_slug = $data[0];
            $lang_slug = $data[1];
            $title = $data[2];
            $parent_slug = !empty($data[3]) ? $data[3] : null;
            $excerpt = !empty($data[4]) ? $data[4] : null;
            $post_date = (count($data) >= 6 && !empty($data[5])) ? $data[5] : null;

            $mapping[$post_slug][$lang_slug] = [
                'title' => $title,
                'parent_slug' => $parent_slug,
                'excerpt' => $excerpt ?: '',
                'post_date' => $post_date
            ];
        }
    }

    fclose($handle);
    return $mapping;
}

/**
 * コンテンツファイルを取得する
 */
function get_content_files($content_dir, $target_lang_slug) {
    $files = [];
    $pattern = $content_dir . '/*__' . $target_lang_slug . '.txt';
    $glob_files = glob($pattern);

    foreach ($glob_files as $file) {
        $filename = basename($file);
        $post_slug = str_replace('__' . $target_lang_slug . '.txt', '', $filename);
        $files[$post_slug] = $file;
    }

    return $files;
}

/**
 * 関連する言語ファイルを取得する
 */
function get_related_language_files($content_dir, $post_slug, $target_lang_slug) {
    $related_files = [];
    $pattern = $content_dir . '/' . $post_slug . '__*.txt';
    $glob_files = glob($pattern);

    foreach ($glob_files as $file) {
        $filename = basename($file);
        $lang_match = [];
        if (preg_match('/^' . preg_quote($post_slug) . '__(.+)\.txt$/', $filename, $lang_match)) {
            $lang = $lang_match[1];
            if ($lang !== $target_lang_slug) {
                $related_files[$lang] = $file;
            }
        }
    }

    return $related_files;
}

/**
 * 投稿を作成する
 */
function create_wordpress_post($post_data) {
    $post_id = wp_insert_post($post_data, true);

    if (is_wp_error($post_id)) {
        echo "エラー: 投稿の作成に失敗しました - " . $post_id->get_error_message() . "\n";
        return 0;
    }

    return $post_id;
}

/**
 * 投稿をコピーする（Polylang使用）
 */
function copy_post_for_language($original_post_id, $lang_slug) {
    // Polylangが利用可能かチェック
    if (!function_exists('PLL') || !PLL()) {
        echo "エラー: Polylangプラグインが利用できません\n";
        return 0;
    }

    // Polylangの copy メソッドを使用して言語版投稿を作成
    $tr_post_id = PLL()->sync_post->sync_model->copy($original_post_id, $lang_slug, 'copy', false);

    if (!$tr_post_id || is_wp_error($tr_post_id)) {
        echo "エラー: 言語版投稿の作成に失敗しました (言語: {$lang_slug})\n";
        return 0;
    }

    return $tr_post_id;
}

/**
 * 言語情報を置き換える
 */
function replace_languages_provided($post_id, $languages) {
    echo "言語情報を設定中: " . implode(', ', $languages) . "\n";
    update_post_meta($post_id, '_languages_provided', $languages);
}

/**
 * 単一の投稿を作成する
 */
function create_single_post($post_slug, $target_lang_slug, $parent_id, $content_file, $title_mapping, $content_dir, $post_type) {
    echo "\n--- 処理中: post_slug='{$post_slug}' ---\n";
    echo "メインファイル: {$content_file}\n";

    // タイトルマッピング情報を取得
    $mapping_info = $title_mapping[$post_slug][$target_lang_slug] ?? null;
    if (!$mapping_info) {
        echo "警告: タイトルマッピング情報が見つかりません: {$post_slug} ({$target_lang_slug})\n";
        return 0;
    }

    $title = $mapping_info['title'];
    $excerpt = $mapping_info['excerpt'] ?: '';
    $post_date = $mapping_info['post_date'];

    echo "    タイトル: {$title}\n";
    echo "    抜粋: {$excerpt}\n";
    echo "    投稿日時: {$post_date}\n";

    // コンテンツファイルを読み込む
    if (!file_exists($content_file)) {
        echo "エラー: コンテンツファイルが見つかりません: {$content_file}\n";
        return 0;
    }

    $content = file_get_contents($content_file);
    echo "    内容: " . substr($content, 0, 100) . "...\n";

    // 投稿データを準備
    $post_data = [
        'post_type' => $post_type,
        'post_title' => $title,
        'post_name' => $post_slug,
        'post_content' => $content,
        'post_status' => 'publish',
        'post_excerpt' => $excerpt ?: ''
    ];

    // post_dateが指定されている場合は追加
    if ($post_date) {
        $post_data['post_date'] = $post_date;
        $post_data['post_date_gmt'] = get_gmt_from_date($post_date);
    }

    // 親ページが指定されている場合
    if ($parent_id) {
        $post_data['post_parent'] = $parent_id;
        echo "    親ページID: {$parent_id}\n";
    }

    // 投稿を作成
    $post_id = create_wordpress_post($post_data);
    if (!$post_id) {
        return 0;
    }

    echo "投稿ID: {$post_id}\n";

    // 関連する言語版を処理
    $languages_found = [$target_lang_slug];
    $related_files = get_related_language_files($content_dir, $post_slug, $target_lang_slug);

    echo "関連する言語版:\n";
    foreach ($related_files as $lang => $related_file) {
        echo "  言語: {$lang} - ファイル: {$related_file}\n";

        $related_mapping = $title_mapping[$post_slug][$lang] ?? null;
        if (!$related_mapping) {
            echo "    警告: 言語 {$lang} のマッピング情報が見つかりません\n";
            continue;
        }

        $related_title = $related_mapping['title'];
        $related_excerpt = $related_mapping['excerpt'] ?: '';
        $related_post_date = $related_mapping['post_date'];
        $related_content = file_get_contents($related_file);

        echo "    タイトル: {$related_title}\n";
        echo "    抜粋: {$related_excerpt}\n";
        echo "    投稿日時: {$related_post_date}\n";
        echo "    内容: " . substr($related_content, 0, 100) . "...\n";

        // 言語版投稿を作成
        $tr_post_id = copy_post_for_language($post_id, $lang);
        if ($tr_post_id) {
            echo "    言語版投稿ID ({$lang}): {$tr_post_id}\n";

            // 投稿を更新
            $update_data = [
                'ID' => $tr_post_id,
                'post_title' => $related_title,
                'post_content' => $related_content,
                'post_excerpt' => $related_excerpt ?: ''
            ];

            // post_dateが指定されている場合は追加
            if ($related_post_date) {
                $update_data['post_date'] = $related_post_date;
                $update_data['post_date_gmt'] = get_gmt_from_date($related_post_date);
            }

            wp_update_post($update_data);
            $languages_found[] = $lang;
        } else {
            echo "    エラー: 言語版投稿の作成に失敗しました ({$lang})\n";
        }
    }

    echo "見つかった言語: " . implode(', ', $languages_found) . "\n";

    // 言語情報をWordPressに追加
    echo "言語情報をWordPressに追加中...\n";
    replace_languages_provided($post_id, $languages_found);

    echo "----------------------------------------\n";
    return $post_id;
}

// メイン処理開始
try {
    // タイトルマッピングを読み込む
    $title_mapping = load_title_mapping($title_mapping_file);
    if (empty($title_mapping)) {
        throw new Exception("タイトルマッピングの読み込みに失敗しました");
    }

    // コンテンツファイルを取得
    $content_files = get_content_files($content_dir, $target_lang_slug);
    if (empty($content_files)) {
        throw new Exception("対象言語のコンテンツファイルが見つかりません");
    }

    // CSVに記載されている順序でpost_slugのリストを作成
    $ordered_post_slugs = [];
    $handle = fopen($title_mapping_file, 'r');
    if ($handle !== false) {
        // ヘッダー行をスキップ
        fgetcsv($handle);

        while (($data = fgetcsv($handle)) !== false) {
            if (count($data) >= 1) {
                $post_slug = $data[0];
                $lang_slug = $data[1];

                // 対象言語の行のみを記録（重複を防ぐ）
                if ($lang_slug === $target_lang_slug && !in_array($post_slug, $ordered_post_slugs)) {
                    $ordered_post_slugs[] = $post_slug;
                }
            }
        }
        fclose($handle);
    }

    echo "\n=== CSV順での投稿作成を開始します ===\n";
    echo "処理順序: " . implode(', ', $ordered_post_slugs) . "\n";

    // 作成済み投稿を記録する配列
    $created_posts = [];

    echo "\n=== 1段階目: 親ページの作成 ===\n";

    // 1段階目: CSV順で親ページを作成
    foreach ($ordered_post_slugs as $post_slug) {
        // コンテンツファイルが存在するかチェック
        if (!isset($content_files[$post_slug])) {
            continue;
        }

        $mapping_info = $title_mapping[$post_slug][$target_lang_slug] ?? null;
        if (!$mapping_info) {
            continue;
        }

        // 親ページが指定されている場合はスキップ
        if (!empty($mapping_info['parent_slug'])) {
            continue;
        }

        echo "\n--- 処理中（親ページ）: post_slug='{$post_slug}' ---\n";

        $post_id = create_single_post(
            $post_slug,
            $target_lang_slug,
            null,
            $content_files[$post_slug],
            $title_mapping,
            $content_dir,
            $post_type
        );

        if ($post_id) {
            $created_posts[$post_slug] = $post_id;
            echo "親ページ作成完了: {$post_slug} (ID: {$post_id})\n";
        }
    }

    echo "\n=== 2段階目: 子ページの作成 ===\n";

    // 2段階目: CSV順で子ページを作成
    foreach ($ordered_post_slugs as $post_slug) {
        // コンテンツファイルが存在するかチェック
        if (!isset($content_files[$post_slug])) {
            continue;
        }

        $mapping_info = $title_mapping[$post_slug][$target_lang_slug] ?? null;
        if (!$mapping_info) {
            continue;
        }

        $parent_slug = $mapping_info['parent_slug'];

        // 親ページが指定されていない場合はスキップ
        if (empty($parent_slug)) {
            continue;
        }

        // 親ページのIDを取得
        $parent_id = $created_posts[$parent_slug] ?? null;
        if (!$parent_id) {
            echo "警告: 親ページ '{$parent_slug}' が見つかりません。子ページ '{$post_slug}' をスキップします。\n";
            continue;
        }

        echo "\n--- 処理中（子ページ）: post_slug='{$post_slug}', parent_slug='{$parent_slug}' ---\n";

        $post_id = create_single_post(
            $post_slug,
            $target_lang_slug,
            $parent_id,
            $content_files[$post_slug],
            $title_mapping,
            $content_dir,
            $post_type
        );

        if ($post_id) {
            $created_posts[$post_slug] = $post_id;
            echo "子ページ作成完了: {$post_slug} (ID: {$post_id}, 親ID: {$parent_id})\n";
        }
    }

    echo "\n=== 全ての投稿の作成が完了しました ===\n";
    echo "作成された投稿数: " . count($created_posts) . "\n";

} catch (Exception $e) {
    echo "エラー: " . $e->getMessage() . "\n";
    exit(1);
}
