#!/bin/bash
set -e

SITE_PATH="/srv/www/synecoculture/public_html"
UPLOADS_DIR="$SITE_PATH/wp-content/uploads"
TEMP_DIR="/tmp/wp-media"

# シンボリックリンク削除
sudo rm "$UPLOADS_DIR"

# 元に戻す
sudo mv "$UPLOADS_DIR.backup" "$UPLOADS_DIR"

# 結果を同期
sudo rsync -av "$TEMP_DIR/uploads/" "$UPLOADS_DIR/"

# 一時ディレクトリ削除
sudo rm -rf "$TEMP_DIR"

echo "Teardown完了: 結果を共有フォルダに同期しました"
