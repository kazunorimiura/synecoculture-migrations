#!/bin/bash

# ./migrations/akismet/migrations.sh

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

###
### reCAPTCHAのサイトキー、シークレットキーを設定する（MW WP Form reCAPTCHAプラグイン用）
###

wp eval-file ./migrations/recaptcha/setup-recaptcha.php
