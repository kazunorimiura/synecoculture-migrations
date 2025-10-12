#!/bin/bash

# ./migrations/update_img_sizes/after.sh

# サムネイルサイズを変更
wp option update thumbnail_size_w 150
wp option update thumbnail_size_h 150

# 中サイズを変更
wp option update medium_size_w 300
wp option update medium_size_h 300

echo "新画像サイズの設定が完了しました"
