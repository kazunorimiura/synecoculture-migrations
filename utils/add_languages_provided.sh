#!/bin/bash

# ./migrations/blog_migrations/_add_languages_provided.sh

# 提供言語を追加する関数
add_languages_provided() {
  local post_id="$1"
  shift
  local langs=("$@")

  # 新しい言語コードをJSONに変換
  local langs_json
  langs_json=$(printf '%s\n' "${langs[@]}" | jq -R . | jq -s .)

  # wp eval に渡す
  wp eval "
    \$meta_key = '_wpf_languages_provided';
    \$post_id = $post_id;
    \$existing = get_post_meta(\$post_id, \$meta_key, true);

    // null や false のときは空配列にする
    if (!is_array(\$existing)) {
      \$existing = [];
    }

    // 新しい言語（PHP配列）を追加（重複を避ける）
    \$new_langs = json_decode('$langs_json');
    \$merged = array_unique(array_merge(\$existing, \$new_langs));

    // メタデータを更新
    update_post_meta(\$post_id, \$meta_key, \$merged);
    echo 'Add language provided: ' . json_encode(\$merged) . \"\n\";
  "
}

# add_languages_provided 3485 en

# 使用例
# ./script.sh 123 ja en fr
# 最初の引数が post_id、それ以降が言語コード
