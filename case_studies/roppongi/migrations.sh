#!/bin/bash

# ./migrations/case_studies/roppongi/migrations.sh

source ./migrations/utils/message.sh

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

    wp post meta add $post_id _wpf_case_study__basic__heading "Practitioner"
    wp post meta add $post_id _wpf_case_study__basic__body "Sony Computer Science Laboratories, Inc., Mori Building Co., Ltd. (field provider)"

    wp post meta add $post_id _wpf_case_study__basic__heading "Location"
    wp post meta add $post_id _wpf_case_study__basic__body "Roppongi Hills Rooftop, Minato-ku, Tokyo"

    wp post meta add $post_id _wpf_case_study__basic__heading "Climate Conditions"
    wp post meta add $post_id _wpf_case_study__basic__body "Humid subtropical climate"

    wp post meta add $post_id _wpf_case_study__basic__heading "Period"
    wp post meta add $post_id _wpf_case_study__basic__body "March 2019 - October 2021"

    wp post meta add $post_id _wpf_case_study__basic__heading "Field Area"
    wp post meta add $post_id _wpf_case_study__basic__body "Approximately 40 m² (soil section with 1m topsoil layer + 5 hexagonal planters)"

    wp post meta add $post_id _wpf_case_study__basic__heading "Initial Land Condition"
    wp post meta add $post_id _wpf_case_study__basic__body "Artificial soil constructed on rooftop (approximately 1m deep). No vegetation at the start of the experiment; bare ground."


    wp post meta add $post_id _wpf_case_study__detail__heading "Plants Introduced"
    wp post meta add $post_id _wpf_case_study__detail__body "187+ species of vegetables and herbs, 24 fruit tree species (110+ species initially introduced)"

    wp post meta add $post_id _wpf_case_study__detail__heading "Management Method"
    wp post meta add $post_id _wpf_case_study__detail__body "No tilling, no fertilizers or pesticides, maintained only through moderate harvesting and partial mowing. Planters had individually varied conditions, with planting, cutting, and harvesting done manually to maintain the ecosystem."

    wp post meta add $post_id _wpf_case_study__detail__heading "Input Materials/Costs"
    wp post meta add $post_id _wpf_case_study__detail__body "Seedlings and 5 planters"


    wp post meta add $post_id _wpf_case_study__results__heading "Harvest"
    wp post meta add $post_id _wpf_case_study__results__body "Diverse vegetables, herbs, and fruits"

    wp post meta add $post_id _wpf_case_study__results__heading "Changes Beyond Harvest"
    wp post meta add $post_id _wpf_case_study__results__body "A stable ecosystem with diverse coexisting plants was established on the urban rooftop. Changes in soil microorganisms and chemical properties were observed, confirming ecosystem function regeneration even in rooftop environments."

    wp post meta add $post_id _wpf_case_study__results__heading "Benefits"
    wp post meta add $post_id _wpf_case_study__results__body "Demonstrated that Synecoculture can be established even in small urban spaces. Also utilized as a learning and educational site for citizens and researchers."

    wp post meta add $post_id _wpf_case_study__results__heading "Challenges"
    wp post meta add $post_id _wpf_case_study__results__body "None in particular"


    wp post meta add $post_id _wpf_case_study__log__date "March 2019"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__en
    wp post meta add $post_id _wpf_case_study__log__body "Initial planting stage."

    wp post meta add $post_id _wpf_case_study__log__date "2020"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__en
    wp post meta add $post_id _wpf_case_study__log__body "The farm with diverse plants growing in dense mixture."
  fi

  if [ "$lang" == "fr" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__fr
    wp post term add $post_id area japan-tokyo

    wp post meta add $post_id _wpf_case_study__basic__heading "Praticien"
    wp post meta add $post_id _wpf_case_study__basic__body "Sony Computer Science Laboratories, Inc., Mori Building Co., Ltd. (fournisseur du terrain)"

    wp post meta add $post_id _wpf_case_study__basic__heading "Lieu"
    wp post meta add $post_id _wpf_case_study__basic__body "Toit de Roppongi Hills, Minato-ku, Tokyo"

    wp post meta add $post_id _wpf_case_study__basic__heading "Conditions climatiques"
    wp post meta add $post_id _wpf_case_study__basic__body "Climat subtropical humide"

    wp post meta add $post_id _wpf_case_study__basic__heading "Période"
    wp post meta add $post_id _wpf_case_study__basic__body "Mars 2019 - Octobre 2021"

    wp post meta add $post_id _wpf_case_study__basic__heading "Surface du terrain"
    wp post meta add $post_id _wpf_case_study__basic__body "Environ 40 m² (section de sol avec une couche de terre végétale de 1 m + 5 jardinières hexagonales)"

    wp post meta add $post_id _wpf_case_study__basic__heading "État initial du terrain"
    wp post meta add $post_id _wpf_case_study__basic__body "Sol artificiel aménagé sur le toit (profondeur d'environ 1 m). Aucune végétation au début de l'expérience ; sol nu."


    wp post meta add $post_id _wpf_case_study__detail__heading "Plantes introduites"
    wp post meta add $post_id _wpf_case_study__detail__body "Plus de 187 espèces de légumes et herbes aromatiques, 24 espèces d'arbres fruitiers (plus de 110 espèces introduites initialement)"

    wp post meta add $post_id _wpf_case_study__detail__heading "Méthode de gestion"
    wp post meta add $post_id _wpf_case_study__detail__body "Pas de labour, pas d'engrais ni de pesticides, maintenu uniquement par récolte modérée et fauchage partiel. Les jardinières avaient des conditions individuellement variées, avec plantation, coupe et récolte effectuées manuellement pour maintenir l'écosystème."

    wp post meta add $post_id _wpf_case_study__detail__heading "Matériaux investis/Coûts"
    wp post meta add $post_id _wpf_case_study__detail__body "Plants et 5 jardinières"


    wp post meta add $post_id _wpf_case_study__results__heading "Récoltes"
    wp post meta add $post_id _wpf_case_study__results__body "Divers légumes, herbes aromatiques et fruits"

    wp post meta add $post_id _wpf_case_study__results__heading "Changements au-delà de la récolte"
    wp post meta add $post_id _wpf_case_study__results__body "Un écosystème stable avec diverses plantes coexistantes a été établi sur le toit urbain. Des changements dans les micro-organismes du sol et les propriétés chimiques ont été observés, confirmant la régénération des fonctions écosystémiques même dans les environnements de toiture."

    wp post meta add $post_id _wpf_case_study__results__heading "Avantages"
    wp post meta add $post_id _wpf_case_study__results__body "A démontré que la Synecoculture peut être établie même dans de petits espaces urbains. Également utilisé comme site d'apprentissage et d'éducation pour les citoyens et les chercheurs."

    wp post meta add $post_id _wpf_case_study__results__heading "Défis"
    wp post meta add $post_id _wpf_case_study__results__body "Aucun en particulier"


    wp post meta add $post_id _wpf_case_study__log__date "Mars 2019"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "Stade de plantation initiale."

    wp post meta add $post_id _wpf_case_study__log__date "2020"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "La ferme avec diverses plantes poussant en mélange dense."
  fi

  if [ "$lang" == "zh" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__zh
    wp post term add $post_id area japan-tokyo

    wp post meta add $post_id _wpf_case_study__basic__heading "实践者"
    wp post meta add $post_id _wpf_case_study__basic__body "索尼计算机科学研究所株式会社、森大厦株式会社(场地提供方)"

    wp post meta add $post_id _wpf_case_study__basic__heading "地点"
    wp post meta add $post_id _wpf_case_study__basic__body "东京都港区·六本木新城屋顶"

    wp post meta add $post_id _wpf_case_study__basic__heading "气候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "温暖湿润气候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期间"
    wp post meta add $post_id _wpf_case_study__basic__body "2019年3月至2021年10月"

    wp post meta add $post_id _wpf_case_study__basic__heading "田地面积"
    wp post meta add $post_id _wpf_case_study__basic__body "约40平方米(具有1米客土层的土壤区域+5个六角形花盆)"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地初始状态"
    wp post meta add $post_id _wpf_case_study__basic__body "在屋顶建造的人工土壤(深度约1米)。实验开始时没有植被,处于裸地状态。"


    wp post meta add $post_id _wpf_case_study__detail__heading "种植的植物"
    wp post meta add $post_id _wpf_case_study__detail__body "蔬菜和香草类187种以上,果树24种(初期引入时为110种以上)"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "不耕作、不使用肥料和农药,仅通过适度收获和部分割草来维护。花盆采用不同条件,通过手工进行种植、修剪和收获,以维持生态系统。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入材料·成本"
    wp post meta add $post_id _wpf_case_study__detail__body "种苗和5个花盆"


    wp post meta add $post_id _wpf_case_study__results__heading "收获物"
    wp post meta add $post_id _wpf_case_study__results__body "多种蔬菜、香草和水果"

    wp post meta add $post_id _wpf_case_study__results__heading "收获以外的变化"
    wp post meta add $post_id _wpf_case_study__results__body "在都市屋顶建立了多种植物共存的稳定生态系统。观察到土壤微生物和化学性质的变化,确认即使在屋顶环境中也能实现生态系统功能的再生。"

    wp post meta add $post_id _wpf_case_study__results__heading "优点"
    wp post meta add $post_id _wpf_case_study__results__body "证明即使在城市的小空间也能实现Synecoculture。还可用作市民和研究人员的学习和教育场所。"

    wp post meta add $post_id _wpf_case_study__results__heading "困难之处"
    wp post meta add $post_id _wpf_case_study__results__body "特别没有"


    wp post meta add $post_id _wpf_case_study__log__date "2019年3月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "初期种植的样子。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "多种植物混合密生的农场样子。"
  fi
done
