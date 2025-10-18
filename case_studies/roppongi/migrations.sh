#!/bin/bash

# ./migrations/case_studies/roppongi/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/case_studies/roppongi/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

###
### コンテンツマイグレーション
###

WP_UPLOADS_DIR=http://synecoculture.test/wp-content/uploads

# アイキャッチ画像を定義
thumbnail_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/08/DSC01529-scaled.jpeg' );")
message "thumbnail_id: $thumbnail_id"
thumbnail_id__en=$(wp eval "echo pll_get_post('$thumbnail_id', 'en');")
thumbnail_id__fr=$(wp eval "echo pll_get_post('$thumbnail_id', 'fr');")
thumbnail_id__zh=$(wp eval "echo pll_get_post('$thumbnail_id', 'zh');")

# 観察記録1の画像を定義
FILE_NAME="roppongi-1.jpg"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  log_1_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
  message "log_1_id (new import): $log_1_id"
  log_1_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $log_1_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "log_1_id__en (new copy): $log_1_id__en"
  log_1_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $log_1_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "log_1_id__fr (new copy): $log_1_id__fr"
  log_1_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $log_1_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "log_1_id__zh (new copy): $log_1_id__zh"
else
  log_1_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "log_1_id (already import): $log_1_id"
  log_1_id__en=$(wp eval "echo pll_get_post('$log_1_id', 'en');")
  message "log_1_id__en (fetch): $log_1_id__en"
  log_1_id__fr=$(wp eval "echo pll_get_post('$log_1_id', 'fr');")
  message "log_1_id__fr (fetch): $log_1_id__fr"
  log_1_id__zh=$(wp eval "echo pll_get_post('$log_1_id', 'zh');")
  message "log_1_id__zh (fetch): $log_1_id__zh"
fi

# 観察記録2の画像を定義
log_2_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2022/12/2020Roppongi.jpg' );")
message "log_2_id: $log_2_id"
log_2_id__en=$(wp eval "echo pll_get_post('$log_2_id', 'en');")
log_2_id__fr=$(wp eval "echo pll_get_post('$log_2_id', 'fr');")
log_2_id__zh=$(wp eval "echo pll_get_post('$log_2_id', 'zh');")


# 特定のスラッグの投稿を全言語分取得
post_ids=$(wp post list --post_type="case-study" --name="roppongi-hills-rooftop-synecoculture-farm" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  if [ "$lang" == "ja" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id
    wp post term add $post_id area japan-tokyo
    replace_languages_provided $post_id ja

    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社ソニーコンピュータサイエンス研究所、森ビル株式会社（圃場提供）"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "東京都港区・六本木ヒルズ屋上"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2019年3月〜2021年10月"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "約40㎡（1mの客土層をもつ土壌区画＋六角形プランター5基）"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "屋上に造成された人工土壌（深さ約1m）。実験開始時には植生がなく、裸地状態だった。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "野菜・ハーブ類187種以上、果樹24種（初期導入時は110種以上）"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕さない、肥料・農薬を使わない、適度な収穫と部分的な草刈りのみで維持。プランターは個別に条件を変え、手作業で植え付け・刈り取り・収穫を行い、生態系を維持。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種苗とプランター5基"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "多様な野菜・ハーブ・果樹"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "多様な植物が共存する安定した生態系が都市屋上に成立。土壌微生物や化学的性質の変化が観察され、屋上環境でも生態系機能の再生が確認された。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "都市部の小さなスペースでもシネコカルチャーが成立することを実証。市民や研究者の学習・教育の場にも活用できた。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "特になし"


    wp post meta add $post_id _wpf_case_study__log__date "2019年3月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id
    wp post meta add $post_id _wpf_case_study__log__body "初期植栽の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id
    wp post meta add $post_id _wpf_case_study__log__body "多様な植物が混成・密生した農園の様子。"
  fi

  if [ "$lang" == "en" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__en
    wp post term add $post_id area japan-tokyo
    replace_languages_provided $post_id ja

    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社ソニーコンピュータサイエンス研究所、森ビル株式会社（圃場提供）"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "東京都港区・六本木ヒルズ屋上"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2019年3月〜2021年10月"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "約40㎡（1mの客土層をもつ土壌区画＋六角形プランター5基）"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "屋上に造成された人工土壌（深さ約1m）。実験開始時には植生がなく、裸地状態だった。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "野菜・ハーブ類187種以上、果樹24種（初期導入時は110種以上）"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕さない、肥料・農薬を使わない、適度な収穫と部分的な草刈りのみで維持。プランターは個別に条件を変え、手作業で植え付け・刈り取り・収穫を行い、生態系を維持。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種苗とプランター5基"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "多様な野菜・ハーブ・果樹"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "多様な植物が共存する安定した生態系が都市屋上に成立。土壌微生物や化学的性質の変化が観察され、屋上環境でも生態系機能の再生が確認された。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "都市部の小さなスペースでもシネコカルチャーが成立することを実証。市民や研究者の学習・教育の場にも活用できた。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "特になし"


    wp post meta add $post_id _wpf_case_study__log__date "2019年3月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__en
    wp post meta add $post_id _wpf_case_study__log__body "初期植栽の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__en
    wp post meta add $post_id _wpf_case_study__log__body "多様な植物が混成・密生した農園の様子。"
  fi

  if [ "$lang" == "fr" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__fr
    wp post term add $post_id area japan-tokyo
    replace_languages_provided $post_id ja

    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社ソニーコンピュータサイエンス研究所、森ビル株式会社（圃場提供）"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "東京都港区・六本木ヒルズ屋上"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2019年3月〜2021年10月"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "約40㎡（1mの客土層をもつ土壌区画＋六角形プランター5基）"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "屋上に造成された人工土壌（深さ約1m）。実験開始時には植生がなく、裸地状態だった。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "野菜・ハーブ類187種以上、果樹24種（初期導入時は110種以上）"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕さない、肥料・農薬を使わない、適度な収穫と部分的な草刈りのみで維持。プランターは個別に条件を変え、手作業で植え付け・刈り取り・収穫を行い、生態系を維持。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種苗とプランター5基"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "多様な野菜・ハーブ・果樹"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "多様な植物が共存する安定した生態系が都市屋上に成立。土壌微生物や化学的性質の変化が観察され、屋上環境でも生態系機能の再生が確認された。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "都市部の小さなスペースでもシネコカルチャーが成立することを実証。市民や研究者の学習・教育の場にも活用できた。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "特になし"


    wp post meta add $post_id _wpf_case_study__log__date "2019年3月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "初期植栽の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "多様な植物が混成・密生した農園の様子。"
  fi

  if [ "$lang" == "zh" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__zh
    wp post term add $post_id area japan-tokyo
    replace_languages_provided $post_id ja

    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社ソニーコンピュータサイエンス研究所、森ビル株式会社（圃場提供）"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "東京都港区・六本木ヒルズ屋上"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2019年3月〜2021年10月"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "約40㎡（1mの客土層をもつ土壌区画＋六角形プランター5基）"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "屋上に造成された人工土壌（深さ約1m）。実験開始時には植生がなく、裸地状態だった。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "野菜・ハーブ類187種以上、果樹24種（初期導入時は110種以上）"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕さない、肥料・農薬を使わない、適度な収穫と部分的な草刈りのみで維持。プランターは個別に条件を変え、手作業で植え付け・刈り取り・収穫を行い、生態系を維持。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種苗とプランター5基"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "多様な野菜・ハーブ・果樹"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "多様な植物が共存する安定した生態系が都市屋上に成立。土壌微生物や化学的性質の変化が観察され、屋上環境でも生態系機能の再生が確認された。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "都市部の小さなスペースでもシネコカルチャーが成立することを実証。市民や研究者の学習・教育の場にも活用できた。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "特になし"


    wp post meta add $post_id _wpf_case_study__log__date "2019年3月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "初期植栽の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "多様な植物が混成・密生した農園の様子。"
  fi
done
