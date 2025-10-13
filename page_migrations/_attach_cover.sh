#!/bin/bash

# カバー画像を設定する関数

source ./migrations/utils/message.sh

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
