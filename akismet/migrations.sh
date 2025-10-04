#!/bin/bash

# ./migrations/akismet/migrations.sh

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

###
### AkismetプラグインのAPIキーを設定する
###

wp eval-file ./migrations/akismet/setup-akismet.php
