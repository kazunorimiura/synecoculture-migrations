#!/bin/bash

# 提供言語を設定する関数
replace_languages_provided() {
  local post_id="$1"
  shift
  local langs=("$@")

  # 配列をJSON形式に変換（例: ["ja","en"]）
  local langs_json
  langs_json=$(printf '%s\n' "${langs[@]}" | jq -R . | jq -s .)

  # まず既存のメタデータを削除してから追加
  wp eval "
    delete_post_meta($post_id, '_wpf_languages_provided');
    \$result = add_post_meta($post_id, '_wpf_languages_provided', json_decode('$langs_json'), true);
    echo \$result ? 'success' : 'failed';
  "

  echo "Set language provided: $langs_json"
}
