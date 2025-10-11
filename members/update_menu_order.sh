#!/bin/bash

# `member_cat` タクソノミーの順序をもとに投稿のメニューオーダーを設定する

# ./migrations/members/update_menu_order.sh <POST_ID>

post_id=$1

source ./migrations/utils/message.sh

post_type="member"
taxonomy="member_cat"

lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")

if [ "$lang" != "ja" ]; then
  exit 0  # 日本語以外の場合はスクリプトを終了
fi

post_title=$(wp post get $post_id --field=post_title --format=csv)
message "post_title: $post_title" bold
term_ids=$(wp post term list $post_id $taxonomy --field=term_id --format=csv)
message "term_ids: $term_ids"

orders=()

# タームとその親および祖先の `_wpf_term_order` 属性値の合計を取得
for term_id in $term_ids; do
  message "Term ID: $term_id"
  # ここに各term_idに対する処理を追加

  term_name=$(wp term get $taxonomy $term_id --field=name --format=csv)
  message "Term name: $term_name"

  order=$(wp eval "
    \$term_id = $term_id;
    \$taxonomy = '$taxonomy';
    \$term = get_term( \$term_id, \$taxonomy );
    echo (int) get_term_meta( \$term->term_id, '_wpf_term_order', true );
  ")
  message "Term order: $order"
  orders+=($order)
done

# `order` 属性の最小値を取得する
# 複数のタームに属していた場合、職位の高い所属のオーダー値を優先するため
min_order=${orders[0]}
for order in "${orders[@]}"; do
    if (( order < min_order )); then
        min_order=$order
    fi
done

message "Term min_order: $min_order"

wp post update $post_id --menu_order=$min_order
