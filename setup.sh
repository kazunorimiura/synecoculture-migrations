#!/bin/bash
set -e

SITE_PATH="/srv/www/synecoculture/public_html"
UPLOADS_DIR="$SITE_PATH/wp-content/uploads"
TEMP_DIR="/tmp/wp-media"

# VM内ローカルにコピー
sudo mkdir -p "$TEMP_DIR"
sudo cp -r "$UPLOADS_DIR" "$TEMP_DIR/"

# 所有者とパーミッションを変更（これが重要！）
sudo chown -R vagrant:www-data "$TEMP_DIR"
sudo chmod -R 755 "$TEMP_DIR"

# シンボリックリンクに置き換え
sudo mv "$UPLOADS_DIR" "$UPLOADS_DIR.backup"
sudo ln -s "$TEMP_DIR/uploads" "$UPLOADS_DIR"

echo "Setup完了: uploadsは$TEMP_DIR/uploadsを参照しています"
