#!/bin/bash

# ./migrations/update_img_sizes/before.sh

# サムネイルサイズを変更
wp option update thumbnail_size_w 160
wp option update thumbnail_size_h 160

# 中サイズを変更
wp option update medium_size_w 600
wp option update medium_size_h 600

echo "旧画像サイズの設定が完了しました"
