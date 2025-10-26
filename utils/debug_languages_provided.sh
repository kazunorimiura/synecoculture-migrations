#!/bin/bash

# ./migrations/utils/debug_languages_provided.sh

# _wpf_languages_provided の状態を表示する関数
debug_languages_provided() {
  local post_id="$1"
  local label="$2"

  echo ""
  echo "=========================================="
  echo "DEBUG: $label"
  echo "Post ID: $post_id"
  echo "------------------------------------------"

  # メタデータの件数と内容を取得
  wp eval "
    \$post_id = $post_id;
    \$meta_key = '_wpf_languages_provided';
    \$all_values = get_post_meta(\$post_id, \$meta_key, false);

    echo 'Record count: ' . count(\$all_values) . \"\n\";

    if (!empty(\$all_values)) {
      foreach (\$all_values as \$index => \$value) {
        echo 'Record #' . (\$index + 1) . ': ' . json_encode(\$value) . \"\n\";
      }
    } else {
      echo 'No records found.' . \"\n\";
    }
  "

  echo "=========================================="
  echo ""
}
