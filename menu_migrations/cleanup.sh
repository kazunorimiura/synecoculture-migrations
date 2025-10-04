#!/bin/bash

# ./migrations/menu_migrations/cleanup.sh

###
### クリーンアップ
###

wp menu delete $(wp menu list --fields=term_id)
