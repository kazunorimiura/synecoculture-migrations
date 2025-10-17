#!/bin/bash

# ./migrations/fix_media_suffix/delete_uploads_old.sh

if [ -d "/srv/www/synecoculture/public_html/wp-content/uploads_old" ]; then
    rm -rf /srv/www/synecoculture/public_html/wp-content/uploads_old
    echo "uploads_oldディレクトリを削除しました"
fi
