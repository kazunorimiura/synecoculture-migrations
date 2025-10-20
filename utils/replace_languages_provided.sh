#!/bin/bash

# 提供言語を設定する関数
replace_languages_provided() {
  local post_id="$1"
  shift
  local langs=("$@")

  # 配列をJSON形式に変換（例: ["ja","en"]）
  local langs_json
  langs_json=$(printf '%s\n' "${langs[@]}" | jq -R . | jq -s .)

  # update_post_meta を使う（add_post_meta ではなく）
  updated=$(wp eval "
    \$result = update_post_meta($post_id, '_wpf_languages_provided', json_decode('$langs_json'));
    echo \$result ? 'success' : 'failed';
  ")
  echo "Set language provided: $langs_json ($updated)"
}

# 使用例
# ./script.sh 123 ja en fr
# 最初の引数が post_id、それ以降が言語コード
