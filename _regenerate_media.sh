#!/bin/bash

# ./migrations/_regenerate_media.sh

###
### メディアのサイズバリエーションを再生成（未生成のもののみ対象。旧ブログのメディアには画像サイズバリエーションが一切なかった）
###

# wp media regenerate --only-missing --yes

# # メモリの問題なのか仕様なのか不明だが、作成されないサイズバリエーションがあるので個別で実行
# wp media regenerate --image_size=1536x1536 --only-missing --yes

# もしくは単体での再生成だと正常に1536x1536も作成されるのでこれで試してみるか
attachment_ids=$(wp post list --post_type="attachment" --format=ids)
for attachment_id in $attachment_ids; do
  wp media regenerate $attachment_id --only-missing --yes
done
