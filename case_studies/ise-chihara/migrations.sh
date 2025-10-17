#!/bin/bash

# ./migrations/case_studies/ise-chihara/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/case_studies/ise-chihara/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

###
### コンテンツマイグレーション
###

WP_UPLOADS_DIR=http://synecoculture.test/wp-content/uploads

# アイキャッチ画像を定義
thumbnail_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/12/IMG_1186.jpeg' );")
message "thumbnail_id: $thumbnail_id"
thumbnail_id__en=$(wp eval "echo pll_get_post('$thumbnail_id', 'en');")
thumbnail_id__fr=$(wp eval "echo pll_get_post('$thumbnail_id', 'fr');")
thumbnail_id__zh=$(wp eval "echo pll_get_post('$thumbnail_id', 'zh');")

# 観察記録1の画像を定義
log_1_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/12/PB270018-scaled.jpeg' );")
message "log_1_id: $log_1_id"
log_1_id__en=$(wp eval "echo pll_get_post('$log_1_id', 'en');")
log_1_id__fr=$(wp eval "echo pll_get_post('$log_1_id', 'fr');")
log_1_id__zh=$(wp eval "echo pll_get_post('$log_1_id', 'zh');")

# 観察記録2の画像を定義
log_2_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2020/12/IMG_1186.jpeg' );")
message "log_2_id: $log_2_id"
log_2_id__en=$(wp eval "echo pll_get_post('$log_2_id', 'en');")
log_2_id__fr=$(wp eval "echo pll_get_post('$log_2_id', 'fr');")
log_2_id__zh=$(wp eval "echo pll_get_post('$log_2_id', 'zh');")

# 特定のスラッグの投稿を全言語分取得
post_ids=$(wp post list --post_type="case-study" --name="ise-chihara-synecoculture-tea-garden" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  if [ "$lang" == "ja" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id
    wp post term add $post_id area japan-mie
    replace_languages_provided $post_id ja

    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社桜自然塾、一般社団法人シネコカルチャー"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "三重県伊勢市"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "日本の温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2020年11月〜"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "ほぼ耕作放棄されていた茶園。背丈の大きいセンダングサなどが生えて立ち枯れており、茶の木も旺盛に成長していたが、放置すると地上部が大きくなりすぎて茶の木が弱る状態。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "既存のチャノキを維持しつつ、一部を移植。今後果樹・野菜を導入予定。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "年数回のチャノキの刈り込み（キャタピラ付き全自動茶刈り機使用）、チャノキの列と列の間の草刈り（手押しエンジン付き刈り込み機使用）、背が高すぎる草の手作業除去（根は抜かず地上部のみ刈り取り、根部は土壌構造形成に活用）、一部のチャノキを移植して畝の再配置。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "キャタピラ付き全自動茶刈り機、手押しエンジン付き刈り込み機、チャノキは既存のものを維持。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未収穫"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未観測"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"


    wp post meta add $post_id _wpf_case_study__log__date "2020年11月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id
    wp post meta add $post_id _wpf_case_study__log__body "管理前の茶園の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年12月"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id
    wp post meta add $post_id _wpf_case_study__log__body "刈り込み作業が終わった後の茶園。表面の薄い緑の若葉が刈り取られて、全体的に濃い緑色になった。"
  fi

  if [ "$lang" == "en" ]; then
    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社桜自然塾、一般社団法人シネコカルチャー"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "三重県伊勢市"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "日本の温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2020年11月〜"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "ほぼ耕作放棄されていた茶園。背丈の大きいセンダングサなどが生えて立ち枯れており、茶の木も旺盛に成長していたが、放置すると地上部が大きくなりすぎて茶の木が弱る状態。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "既存のチャノキを維持しつつ、一部を移植。今後果樹・野菜を導入予定。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "年数回のチャノキの刈り込み（キャタピラ付き全自動茶刈り機使用）、チャノキの列と列の間の草刈り（手押しエンジン付き刈り込み機使用）、背が高すぎる草の手作業除去（根は抜かず地上部のみ刈り取り、根部は土壌構造形成に活用）、一部のチャノキを移植して畝の再配置。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "キャタピラ付き全自動茶刈り機、手押しエンジン付き刈り込み機、チャノキは既存のものを維持。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未収穫"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未観測"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"


    wp post meta add $post_id _wpf_case_study__log__date "2020年11月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__en
    wp post meta add $post_id _wpf_case_study__log__body "管理前の茶園の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年12月"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__en
    wp post meta add $post_id _wpf_case_study__log__body "刈り込み作業が終わった後の茶園。表面の薄い緑の若葉が刈り取られて、全体的に濃い緑色になった。"
  fi

  if [ "$lang" == "fr" ]; then
    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社桜自然塾、一般社団法人シネコカルチャー"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "三重県伊勢市"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "日本の温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2020年11月〜"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "ほぼ耕作放棄されていた茶園。背丈の大きいセンダングサなどが生えて立ち枯れており、茶の木も旺盛に成長していたが、放置すると地上部が大きくなりすぎて茶の木が弱る状態。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "既存のチャノキを維持しつつ、一部を移植。今後果樹・野菜を導入予定。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "年数回のチャノキの刈り込み（キャタピラ付き全自動茶刈り機使用）、チャノキの列と列の間の草刈り（手押しエンジン付き刈り込み機使用）、背が高すぎる草の手作業除去（根は抜かず地上部のみ刈り取り、根部は土壌構造形成に活用）、一部のチャノキを移植して畝の再配置。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "キャタピラ付き全自動茶刈り機、手押しエンジン付き刈り込み機、チャノキは既存のものを維持。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未収穫"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未観測"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"


    wp post meta add $post_id _wpf_case_study__log__date "2020年11月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "管理前の茶園の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年12月"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "刈り込み作業が終わった後の茶園。表面の薄い緑の若葉が刈り取られて、全体的に濃い緑色になった。"
  fi

  if [ "$lang" == "zh" ]; then
    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社桜自然塾、一般社団法人シネコカルチャー"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "三重県伊勢市"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "日本の温暖湿潤気候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2020年11月〜"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "ほぼ耕作放棄されていた茶園。背丈の大きいセンダングサなどが生えて立ち枯れており、茶の木も旺盛に成長していたが、放置すると地上部が大きくなりすぎて茶の木が弱る状態。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "既存のチャノキを維持しつつ、一部を移植。今後果樹・野菜を導入予定。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "年数回のチャノキの刈り込み（キャタピラ付き全自動茶刈り機使用）、チャノキの列と列の間の草刈り（手押しエンジン付き刈り込み機使用）、背が高すぎる草の手作業除去（根は抜かず地上部のみ刈り取り、根部は土壌構造形成に活用）、一部のチャノキを移植して畝の再配置。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "キャタピラ付き全自動茶刈り機、手押しエンジン付き刈り込み機、チャノキは既存のものを維持。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未収穫"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未観測"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "準備段階のため未評価"


    wp post meta add $post_id _wpf_case_study__log__date "2020年11月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "管理前の茶園の様子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年12月"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "刈り込み作業が終わった後の茶園。表面の薄い緑の若葉が刈り取られて、全体的に濃い緑色になった。"
  fi
done
