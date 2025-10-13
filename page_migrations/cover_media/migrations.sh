#!/bin/bash

# ./migrations/page_migrations/cover_media/migrations.sh
# メディアをインポートする場合:
# ./migrations/page_migrations/cover_media/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/page_migrations/cover_media/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

attach_cover() {
  local post_name=$1
  local file_id=$2
  local file_id__en=$3
  local file_id__fr=$4
  local file_id__zh=$5

  post_ids=$(wp post list --post_type=page --name="$post_name" --field=ID)

  for post_id in $post_ids; do
    lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
    message "lang: $lang"

    # # 事前にカスタムフィールドをクリーンアップ
    # wp post meta delete $post_id --all

    if [ "$lang" == "ja" ]; then
      wp post meta add $post_id _wpf_cover_media_id $file_id

      wp eval '
      $media_url = wp_get_attachment_url('$file_id');
      $mime_type = get_post_mime_type('$file_id');
      $meta_value = (object) array(
          "type" => "image",
          "mime" => $mime_type,
          "url"  => $media_url,
      );
      echo $mime_type . "\n";
      echo $media_url . "\n";
      echo add_post_meta('$post_id', "_wpf_cover_media_metadata", $meta_value) . "\n";
      '
    fi

    if [ "$lang" == "en" ]; then
      wp post meta add $post_id _wpf_cover_media_id $file_id__en

      wp eval '
      $media_url = wp_get_attachment_url('$file_id__en');
      $mime_type = get_post_mime_type('$file_id__en');
      $meta_value = (object) array(
          "type" => "image",
          "mime" => $mime_type,
          "url"  => $media_url,
      );
      echo $mime_type . "\n";
      echo $media_url . "\n";
      echo add_post_meta('$post_id', "_wpf_cover_media_metadata", $meta_value) . "\n";
      '
    fi

    if [ "$lang" == "fr" ]; then
      wp post meta add $post_id _wpf_cover_media_id $file_id__fr

      wp eval '
      $media_url = wp_get_attachment_url('$file_id__fr');
      $mime_type = get_post_mime_type('$file_id__fr');
      $meta_value = (object) array(
          "type" => "image",
          "mime" => $mime_type,
          "url"  => $media_url,
      );
      echo $mime_type . "\n";
      echo $media_url . "\n";
      echo add_post_meta('$post_id', "_wpf_cover_media_metadata", $meta_value) . "\n";
      '
    fi

    if [ "$lang" == "zh" ]; then
      wp post meta add $post_id _wpf_cover_media_id $file_id__zh

      wp eval '
      $media_url = wp_get_attachment_url('$file_id__zh');
      $mime_type = get_post_mime_type('$file_id__zh');
      $meta_value = (object) array(
          "type" => "image",
          "mime" => $mime_type,
          "url"  => $media_url,
      );
      echo $mime_type . "\n";
      echo $media_url . "\n";
      echo add_post_meta('$post_id', "_wpf_cover_media_metadata", $meta_value) . "\n";
      '
    fi
  done
}

# ###
# ### Synecocultureマニュアルのカバー画像を設定
# ###

# FILE_NAME="synecoculture-manual-cover.jpg"
# if [ "$IMPORT_MEDIA" == "--import-media" ]; then
#   file_id=$(wp media import "$MEDIA_PATH/$FILE_NAME" --porcelain)
#   message "file_id (new import): $file_id"
#   file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
#   message "file_id__en (new copy): $file_id__en"
#   file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
#   message "file_id__fr (new copy): $file_id__fr"
#   file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
#   message "file_id__zh (new copy): $file_id__zh"
# else
#   file_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
#   message "file_id (already import): $file_id"
#   file_id__en=$(wp eval "echo pll_get_post('$file_id', 'en');")
#   message "file_id__en (fetch): $file_id__en"
#   file_id__fr=$(wp eval "echo pll_get_post('$file_id', 'fr');")
#   message "file_id__fr (fetch): $file_id__fr"
#   file_id__zh=$(wp eval "echo pll_get_post('$file_id', 'zh');")
#   message "file_id__zh (fetch): $file_id__zh"
# fi

# attach_cover "manual" $file_id $file_id__en $file_id__fr $file_id__zh

###
### 私たちについてのカバー画像を設定
###

FILE_NAME="about-cover.jpg"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  file_id=$(wp media import "$MEDIA_PATH/$FILE_NAME" --porcelain)
  message "file_id (new import): $file_id"
  file_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "file_id__en (new copy): $file_id__en"
  file_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "file_id__fr (new copy): $file_id__fr"
  file_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $file_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "file_id__zh (new copy): $file_id__zh"
else
  file_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "file_id (already import): $file_id"
  file_id__en=$(wp eval "echo pll_get_post('$file_id', 'en');")
  message "file_id__en (fetch): $file_id__en"
  file_id__fr=$(wp eval "echo pll_get_post('$file_id', 'fr');")
  message "file_id__fr (fetch): $file_id__fr"
  file_id__zh=$(wp eval "echo pll_get_post('$file_id', 'zh');")
  message "file_id__zh (fetch): $file_id__zh"
fi

attach_cover "about" $file_id $file_id__en $file_id__fr $file_id__zh
