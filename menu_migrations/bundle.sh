#!/bin/bash

# メニューを作成
# ./migrations/menu_migrations/bundle.sh

SECONDS=0

###
### クリーンアップ
###

./migrations/menu_migrations/cleanup.sh

###
### メニュー作成
###

./migrations/menu_migrations/_create.sh

echo "処理時間 (migrations/menu_migrations): ${SECONDS}秒"
