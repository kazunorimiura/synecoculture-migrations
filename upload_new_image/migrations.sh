#!/bin/bash

# 新規コンテンツの本文で使っている画像をアップロードする

# ./migrations/upload_new_image/migrations.sh

# 各種ライセンスキーは.envファイルで定義

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh

MEDIA_PATH=/srv/www/synecoculture/migrations/upload_new_image/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"

# 画像をアップロード
FILE_NAME="kyoto-univ-members.jpg"
file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
message "file_id (new import): $file_id"
file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
message "file_id__en (new copy): $file_id__en"
file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
message "file_id__fr (new copy): $file_id__fr"
file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
message "file_id__zh (new copy): $file_id__zh"

# 画像をアップロード
FILE_NAME="beyond-2025.jpg"
file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
message "file_id (new import): $file_id"
file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
message "file_id__en (new copy): $file_id__en"
file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
message "file_id__fr (new copy): $file_id__fr"
file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
message "file_id__zh (new copy): $file_id__zh"

# 画像をアップロード
FILE_NAME="shizenshihon.webp"
file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
message "file_id (new import): $file_id"
file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
message "file_id__en (new copy): $file_id__en"
file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
message "file_id__fr (new copy): $file_id__fr"
file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
message "file_id__zh (new copy): $file_id__zh"

# 画像をアップロード
FILE_NAME="beyond-capitalism.webp"
file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
message "file_id (new import): $file_id"
file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
message "file_id__en (new copy): $file_id__en"
file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
message "file_id__fr (new copy): $file_id__fr"
file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
message "file_id__zh (new copy): $file_id__zh"

# 画像をアップロード
FILE_NAME="tokyo-regenerative-food-lab.webp"
file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
message "file_id (new import): $file_id"
file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
message "file_id__en (new copy): $file_id__en"
file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
message "file_id__fr (new copy): $file_id__fr"
file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
message "file_id__zh (new copy): $file_id__zh"

# 画像をアップロード
FILE_NAME="kyoto-univ.png"
file_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
message "file_id (new import): $file_id"
file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
message "file_id__en (new copy): $file_id__en"
file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
message "file_id__fr (new copy): $file_id__fr"
file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
message "file_id__zh (new copy): $file_id__zh"
