#!/bin/bash

# ./migrations/case_studies/burkina-faso/migrations.sh
# メディアをインポートする場合:
# ./migrations/case_studies/burkina-faso/migrations.sh --import-media

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/case_studies/burkina-faso/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

###
### コンテンツマイグレーション
###

WP_UPLOADS_DIR=http://synecoculture.test/wp-content/uploads

# アイキャッチ画像を定義
thumbnail_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2019/03/FermeDesFemmes.png' );")
message "thumbnail_id: $thumbnail_id"
thumbnail_id__en=$(wp eval "echo pll_get_post('$thumbnail_id', 'en');")
message "thumbnail_id__en: $thumbnail_id__en"
thumbnail_id__fr=$(wp eval "echo pll_get_post('$thumbnail_id', 'fr');")
message "thumbnail_id__fr: $thumbnail_id__fr"
thumbnail_id__zh=$(wp eval "echo pll_get_post('$thumbnail_id', 'zh');")
message "thumbnail_id__zh: $thumbnail_id__zh"

# 観察記録1の画像を定義
FILE_NAME="burkina-faso-1.jpg"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  burkina_faso_1_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
  message "burkina_faso_1_id (new import): $burkina_faso_1_id"
  burkina_faso_1_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $burkina_faso_1_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "burkina_faso_1_id__en (new copy): $burkina_faso_1_id__en"
  burkina_faso_1_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $burkina_faso_1_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "burkina_faso_1_id__fr (new copy): $burkina_faso_1_id__fr"
  burkina_faso_1_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $burkina_faso_1_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "burkina_faso_1_id__zh (new copy): $burkina_faso_1_id__zh"
else
  burkina_faso_1_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "burkina_faso_1_id (already import): $burkina_faso_1_id"
  burkina_faso_1_id__en=$(wp eval "echo pll_get_post('$burkina_faso_1_id', 'en');")
  message "burkina_faso_1_id__en (fetch): $burkina_faso_1_id__en"
  burkina_faso_1_id__fr=$(wp eval "echo pll_get_post('$burkina_faso_1_id', 'fr');")
  message "burkina_faso_1_id__fr (fetch): $burkina_faso_1_id__fr"
  burkina_faso_1_id__zh=$(wp eval "echo pll_get_post('$burkina_faso_1_id', 'zh');")
  message "burkina_faso_1_id__zh (fetch): $burkina_faso_1_id__zh"
fi

# 観察記録2の画像を定義
FILE_NAME="burkina-faso-2.jpg"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  burkina_faso_2_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
  message "burkina_faso_2_id (new import): $burkina_faso_2_id"
  burkina_faso_2_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $burkina_faso_2_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "burkina_faso_2_id__en (new copy): $burkina_faso_2_id__en"
  burkina_faso_2_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $burkina_faso_2_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "burkina_faso_2_id__fr (new copy): $burkina_faso_2_id__fr"
  burkina_faso_2_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $burkina_faso_2_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "burkina_faso_2_id__zh (new copy): $burkina_faso_2_id__zh"
else
  burkina_faso_2_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "burkina_faso_2_id (already import): $burkina_faso_2_id"
  burkina_faso_2_id__en=$(wp eval "echo pll_get_post('$burkina_faso_2_id', 'en');")
  message "burkina_faso_2_id__en (fetch): $burkina_faso_2_id__en"
  burkina_faso_2_id__fr=$(wp eval "echo pll_get_post('$burkina_faso_2_id', 'fr');")
  message "burkina_faso_2_id__fr (fetch): $burkina_faso_2_id__fr"
  burkina_faso_2_id__zh=$(wp eval "echo pll_get_post('$burkina_faso_2_id', 'zh');")
  message "burkina_faso_2_id__zh (fetch): $burkina_faso_2_id__zh"
fi

# 特定のスラッグの投稿を全言語分取得
post_ids=$(wp post list --post_type="case-study" --name="burkina-faso-mahadaga-synecoculture-farm" --field=ID)
for post_id in $post_ids; do
  message "$post_id" bold
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  if [ "$lang" == "ja" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id
    wp post term add $post_id area africa-burkina-faso
    replace_languages_provided $post_id ja

    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA、CARFS、André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "アフリカ・ブルキナファソ・タポア州マハダガ"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "半乾燥熱帯"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2015年3月〜2018年5月（商業生産期間：2015年6月〜2018年5月）"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "500㎡"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "従来の市場園芸に使用されていたが土壌劣化により放棄された裸地。自然再生も起こらない状態で、周辺地域は砂漠化の兆候を示す植生パターン。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "150種の食用植物を戦略的混植（40種の主食作物を含む）。一年生・多年生の先駆植物、低木、つる性植物、陽樹、陰樹など、成熟した植生遷移段階に対応する典型的な植物タイプを含む。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕起なし、合成・有機肥料不使用、農薬・植物衛生製品不使用、農業機械不使用、必要に応じた水やり、少量の草取り作業"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種子と苗のみ。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "37種の植物を収穫し、地元市場で販売。具体的には、モリンガ、オクラ、キャベツ、ブロッコリー、トウガラシ、タカノツメ、レモン、ニンジン、ローゼル、ゴーヤ、インゲンマメ、スイバ、トマト、ナス、タマネギ、ニンニク、キマメ、メロン、キュウリ、カボチャ、ズッキーニ、ヒビスクス・アセトセラ、ブッソウゲ、ムクゲ、ミクロコッカ、モリンガ・ステノペタラ、グアバ、パパイヤ、エアポテト、イエローヤム、キャッサバ、タロイモ、バナナ（プランテン）、バオバブ、レモングラス、スペアミント、サツマイモ。"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "周辺の裸地にまで緑が広がる「砂漠化の逆転現象」。土壌の多孔構造、保水性、透水性、有機物量、微生物活性が増加。複雑な食物連鎖が形成され、害虫は自然制御されるようになった。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "慣行農法や他の代替農法（稲作＋樹木、保存農業、パーマカルチャー、バイオ集約型園芸、伝統園芸）と比べて、収益性が258倍、生産量が12倍に達した。高い市場アクセス時は収益121倍、低アクセス時でも55倍の収益改善（平均88倍）。周辺農地にも生態系回復効果が波及。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "年ごとの収量変動が大きく、算術平均による安定的評価が難しい。治安悪化により市場アクセスが低下し、販売価格を引き下げざるを得なかった。"


    wp post meta add $post_id _wpf_case_study__log__date "2015年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id
    wp post meta add $post_id _wpf_case_study__log__body "土地の初期状態"

    wp post meta add $post_id _wpf_case_study__log__date "2016年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id
    wp post meta add $post_id _wpf_case_study__log__body "1年後の様子"
  fi

  if [ "$lang" == "en" ]; then
    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA、CARFS、André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "アフリカ・ブルキナファソ・タポア州マハダガ"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "半乾燥熱帯"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2015年3月〜2018年5月（商業生産期間：2015年6月〜2018年5月）"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "500㎡"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "従来の市場園芸に使用されていたが土壌劣化により放棄された裸地。自然再生も起こらない状態で、周辺地域は砂漠化の兆候を示す植生パターン。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "150種の食用植物を戦略的混植（40種の主食作物を含む）。一年生・多年生の先駆植物、低木、つる性植物、陽樹、陰樹など、成熟した植生遷移段階に対応する典型的な植物タイプを含む。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕起なし、合成・有機肥料不使用、農薬・植物衛生製品不使用、農業機械不使用、必要に応じた水やり、少量の草取り作業"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種子と苗のみ。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "37種の植物を収穫し、地元市場で販売。具体的には、モリンガ、オクラ、キャベツ、ブロッコリー、トウガラシ、タカノツメ、レモン、ニンジン、ローゼル、ゴーヤ、インゲンマメ、スイバ、トマト、ナス、タマネギ、ニンニク、キマメ、メロン、キュウリ、カボチャ、ズッキーニ、ヒビスクス・アセトセラ、ブッソウゲ、ムクゲ、ミクロコッカ、モリンガ・ステノペタラ、グアバ、パパイヤ、エアポテト、イエローヤム、キャッサバ、タロイモ、バナナ（プランテン）、バオバブ、レモングラス、スペアミント、サツマイモ。"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "周辺の裸地にまで緑が広がる「砂漠化の逆転現象」。土壌の多孔構造、保水性、透水性、有機物量、微生物活性が増加。複雑な食物連鎖が形成され、害虫は自然制御されるようになった。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "慣行農法や他の代替農法（稲作＋樹木、保存農業、パーマカルチャー、バイオ集約型園芸、伝統園芸）と比べて、収益性が258倍、生産量が12倍に達した。高い市場アクセス時は収益121倍、低アクセス時でも55倍の収益改善（平均88倍）。周辺農地にも生態系回復効果が波及。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "年ごとの収量変動が大きく、算術平均による安定的評価が難しい。治安悪化により市場アクセスが低下し、販売価格を引き下げざるを得なかった。"


    wp post meta add $post_id _wpf_case_study__log__date "2015年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id__en
    wp post meta add $post_id _wpf_case_study__log__body "土地の初期状態"

    wp post meta add $post_id _wpf_case_study__log__date "2016年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id__en
    wp post meta add $post_id _wpf_case_study__log__body "1年後の様子"
  fi

  if [ "$lang" == "fr" ]; then
    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA、CARFS、André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "アフリカ・ブルキナファソ・タポア州マハダガ"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "半乾燥熱帯"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2015年3月〜2018年5月（商業生産期間：2015年6月〜2018年5月）"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "500㎡"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "従来の市場園芸に使用されていたが土壌劣化により放棄された裸地。自然再生も起こらない状態で、周辺地域は砂漠化の兆候を示す植生パターン。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "150種の食用植物を戦略的混植（40種の主食作物を含む）。一年生・多年生の先駆植物、低木、つる性植物、陽樹、陰樹など、成熟した植生遷移段階に対応する典型的な植物タイプを含む。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕起なし、合成・有機肥料不使用、農薬・植物衛生製品不使用、農業機械不使用、必要に応じた水やり、少量の草取り作業"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種子と苗のみ。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "37種の植物を収穫し、地元市場で販売。具体的には、モリンガ、オクラ、キャベツ、ブロッコリー、トウガラシ、タカノツメ、レモン、ニンジン、ローゼル、ゴーヤ、インゲンマメ、スイバ、トマト、ナス、タマネギ、ニンニク、キマメ、メロン、キュウリ、カボチャ、ズッキーニ、ヒビスクス・アセトセラ、ブッソウゲ、ムクゲ、ミクロコッカ、モリンガ・ステノペタラ、グアバ、パパイヤ、エアポテト、イエローヤム、キャッサバ、タロイモ、バナナ（プランテン）、バオバブ、レモングラス、スペアミント、サツマイモ。"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "周辺の裸地にまで緑が広がる「砂漠化の逆転現象」。土壌の多孔構造、保水性、透水性、有機物量、微生物活性が増加。複雑な食物連鎖が形成され、害虫は自然制御されるようになった。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "慣行農法や他の代替農法（稲作＋樹木、保存農業、パーマカルチャー、バイオ集約型園芸、伝統園芸）と比べて、収益性が258倍、生産量が12倍に達した。高い市場アクセス時は収益121倍、低アクセス時でも55倍の収益改善（平均88倍）。周辺農地にも生態系回復効果が波及。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "年ごとの収量変動が大きく、算術平均による安定的評価が難しい。治安悪化により市場アクセスが低下し、販売価格を引き下げざるを得なかった。"


    wp post meta add $post_id _wpf_case_study__log__date "2015年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "土地の初期状態"

    wp post meta add $post_id _wpf_case_study__log__date "2016年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "1年後の様子"
  fi

  if [ "$lang" == "zh" ]; then
    wp post meta add $post_id _wpf_case_study__basic__heading "実践者名"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA、CARFS、André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "場所"
    wp post meta add $post_id _wpf_case_study__basic__body "アフリカ・ブルキナファソ・タポア州マハダガ"

    wp post meta add $post_id _wpf_case_study__basic__heading "気候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "半乾燥熱帯"

    wp post meta add $post_id _wpf_case_study__basic__heading "期間"
    wp post meta add $post_id _wpf_case_study__basic__body "2015年3月〜2018年5月（商業生産期間：2015年6月〜2018年5月）"

    wp post meta add $post_id _wpf_case_study__basic__heading "圃場面積"
    wp post meta add $post_id _wpf_case_study__basic__body "500㎡"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地の初期状態"
    wp post meta add $post_id _wpf_case_study__basic__body "従来の市場園芸に使用されていたが土壌劣化により放棄された裸地。自然再生も起こらない状態で、周辺地域は砂漠化の兆候を示す植生パターン。"


    wp post meta add $post_id _wpf_case_study__detail__heading "植えた植物"
    wp post meta add $post_id _wpf_case_study__detail__body "150種の食用植物を戦略的混植（40種の主食作物を含む）。一年生・多年生の先駆植物、低木、つる性植物、陽樹、陰樹など、成熟した植生遷移段階に対応する典型的な植物タイプを含む。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "耕起なし、合成・有機肥料不使用、農薬・植物衛生製品不使用、農業機械不使用、必要に応じた水やり、少量の草取り作業"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入資材・コスト"
    wp post meta add $post_id _wpf_case_study__detail__body "種子と苗のみ。"


    wp post meta add $post_id _wpf_case_study__results__heading "収穫できたもの"
    wp post meta add $post_id _wpf_case_study__results__body "37種の植物を収穫し、地元市場で販売。具体的には、モリンガ、オクラ、キャベツ、ブロッコリー、トウガラシ、タカノツメ、レモン、ニンジン、ローゼル、ゴーヤ、インゲンマメ、スイバ、トマト、ナス、タマネギ、ニンニク、キマメ、メロン、キュウリ、カボチャ、ズッキーニ、ヒビスクス・アセトセラ、ブッソウゲ、ムクゲ、ミクロコッカ、モリンガ・ステノペタラ、グアバ、パパイヤ、エアポテト、イエローヤム、キャッサバ、タロイモ、バナナ（プランテン）、バオバブ、レモングラス、スペアミント、サツマイモ。"

    wp post meta add $post_id _wpf_case_study__results__heading "収穫以外の変化"
    wp post meta add $post_id _wpf_case_study__results__body "周辺の裸地にまで緑が広がる「砂漠化の逆転現象」。土壌の多孔構造、保水性、透水性、有機物量、微生物活性が増加。複雑な食物連鎖が形成され、害虫は自然制御されるようになった。"

    wp post meta add $post_id _wpf_case_study__results__heading "よかったこと"
    wp post meta add $post_id _wpf_case_study__results__body "慣行農法や他の代替農法（稲作＋樹木、保存農業、パーマカルチャー、バイオ集約型園芸、伝統園芸）と比べて、収益性が258倍、生産量が12倍に達した。高い市場アクセス時は収益121倍、低アクセス時でも55倍の収益改善（平均88倍）。周辺農地にも生態系回復効果が波及。"

    wp post meta add $post_id _wpf_case_study__results__heading "困ったこと"
    wp post meta add $post_id _wpf_case_study__results__body "年ごとの収量変動が大きく、算術平均による安定的評価が難しい。治安悪化により市場アクセスが低下し、販売価格を引き下げざるを得なかった。"


    wp post meta add $post_id _wpf_case_study__log__date "2015年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "土地の初期状態"

    wp post meta add $post_id _wpf_case_study__log__date "2016年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "1年後の様子"
  fi
done
