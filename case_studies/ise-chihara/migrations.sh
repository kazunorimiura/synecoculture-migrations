#!/bin/bash

# ./migrations/case_studies/ise-chihara/migrations.sh

source ./migrations/utils/message.sh

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
    wp post meta update $post_id _thumbnail_id $thumbnail_id__en
    wp post term add $post_id area japan-mie

    wp post meta add $post_id _wpf_case_study__basic__heading "Practitioner"
    wp post meta add $post_id _wpf_case_study__basic__body "Sakura Shizenjuku, Co., Synecoculture Association"

    wp post meta add $post_id _wpf_case_study__basic__heading "Location"
    wp post meta add $post_id _wpf_case_study__basic__body "Ise City, Mie Prefecture"

    wp post meta add $post_id _wpf_case_study__basic__heading "Climate Conditions"
    wp post meta add $post_id _wpf_case_study__basic__body "Humid subtropical climate of Japan"

    wp post meta add $post_id _wpf_case_study__basic__heading "Period"
    wp post meta add $post_id _wpf_case_study__basic__body "From November 2020"

    wp post meta add $post_id _wpf_case_study__basic__heading "Initial Land Condition"
    wp post meta add $post_id _wpf_case_study__basic__body "Tea plantation that had been almost completely abandoned. Tall Spanish needles and other plants had grown and withered, and while tea plants were growing vigorously, they were in a condition where neglect would cause excessive above-ground growth, weakening the tea plants."


    wp post meta add $post_id _wpf_case_study__detail__heading "Plants Planted"
    wp post meta add $post_id _wpf_case_study__detail__body "Maintained existing tea plants while transplanting some. Fruit trees and vegetables to be introduced in the future."

    wp post meta add $post_id _wpf_case_study__detail__heading "Management Methods"
    wp post meta add $post_id _wpf_case_study__detail__body "Tea plant pruning several times per year (using fully automatic tracked tea harvester), mowing between tea plant rows (using push-type engine-powered trimmer), manual removal of excessively tall plants (cutting only above-ground parts without pulling roots, utilizing root systems for soil structure formation), transplanting some tea plants to rearrange rows."

    wp post meta add $post_id _wpf_case_study__detail__heading "Input Materials/Costs"
    wp post meta add $post_id _wpf_case_study__detail__body "Fully automatic tracked tea harvester, push-type engine-powered trimmer, maintained existing tea plants."


    wp post meta add $post_id _wpf_case_study__results__heading "Harvested Items"
    wp post meta add $post_id _wpf_case_study__results__body "Not yet harvested (preparation stage)"

    wp post meta add $post_id _wpf_case_study__results__heading "Changes Other Than Harvest"
    wp post meta add $post_id _wpf_case_study__results__body "Not yet observed (preparation stage)"

    wp post meta add $post_id _wpf_case_study__results__heading "Positive Outcomes"
    wp post meta add $post_id _wpf_case_study__results__body "Not yet evaluated (preparation stage)"

    wp post meta add $post_id _wpf_case_study__results__heading "Challenges"
    wp post meta add $post_id _wpf_case_study__results__body "Not yet evaluated (preparation stage)"


    wp post meta add $post_id _wpf_case_study__log__date "November 2020"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__en
    wp post meta add $post_id _wpf_case_study__log__body "Tea plantation before management."

    wp post meta add $post_id _wpf_case_study__log__date "December 2020"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__en
    wp post meta add $post_id _wpf_case_study__log__body "Tea plantation after pruning work. The light green young leaves on the surface were trimmed, resulting in an overall darker green appearance."
  fi

  if [ "$lang" == "fr" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__fr
    wp post term add $post_id area japan-mie

    wp post meta add $post_id _wpf_case_study__basic__heading "Praticien"
    wp post meta add $post_id _wpf_case_study__basic__body "K.K. Sakura Shizenjuku, Association Synecoculture"

    wp post meta add $post_id _wpf_case_study__basic__heading "Lieu"
    wp post meta add $post_id _wpf_case_study__basic__body "Ville d'Ise, préfecture de Mie"

    wp post meta add $post_id _wpf_case_study__basic__heading "Conditions climatiques"
    wp post meta add $post_id _wpf_case_study__basic__body "Climat subtropical humide du Japon"

    wp post meta add $post_id _wpf_case_study__basic__heading "Période"
    wp post meta add $post_id _wpf_case_study__basic__body "Depuis novembre 2020"

    wp post meta add $post_id _wpf_case_study__basic__heading "État initial du terrain"
    wp post meta add $post_id _wpf_case_study__basic__body "Plantation de thé presque entièrement abandonnée. Des bidents élevés et d'autres plantes avaient poussé et dépéri, et bien que les théiers se développaient vigoureusement, leur abandon aurait causé une croissance excessive de la partie aérienne, affaiblissant les plants de thé."


    wp post meta add $post_id _wpf_case_study__detail__heading "Plantes cultivées"
    wp post meta add $post_id _wpf_case_study__detail__body "Maintien des théiers existants avec transplantation partielle. Introduction prévue d'arbres fruitiers et de légumes."

    wp post meta add $post_id _wpf_case_study__detail__heading "Méthodes de gestion"
    wp post meta add $post_id _wpf_case_study__detail__body "Taille des théiers plusieurs fois par an (utilisant une machine à récolter le thé entièrement automatique à chenilles), fauchage entre les rangées de théiers (utilisant une tondeuse motorisée à poussée manuelle), élimination manuelle des plantes trop hautes (coupe uniquement de la partie aérienne sans arracher les racines, utilisation du système racinaire pour la formation de la structure du sol), transplantation de certains théiers pour réorganiser les rangées."

    wp post meta add $post_id _wpf_case_study__detail__heading "Matériaux investis/Coûts"
    wp post meta add $post_id _wpf_case_study__detail__body "Machine à récolter le thé entièrement automatique à chenilles, tondeuse motorisée à poussée manuelle, maintien des théiers existants."


    wp post meta add $post_id _wpf_case_study__results__heading "Récoltes obtenues"
    wp post meta add $post_id _wpf_case_study__results__body "Pas encore récolté (phase de préparation)"

    wp post meta add $post_id _wpf_case_study__results__heading "Changements autres que la récolte"
    wp post meta add $post_id _wpf_case_study__results__body "Pas encore observés (phase de préparation)"

    wp post meta add $post_id _wpf_case_study__results__heading "Points positifs"
    wp post meta add $post_id _wpf_case_study__results__body "Pas encore évalués (phase de préparation)"

    wp post meta add $post_id _wpf_case_study__results__heading "Difficultés rencontrées"
    wp post meta add $post_id _wpf_case_study__results__body "Pas encore évaluées (phase de préparation)"


    wp post meta add $post_id _wpf_case_study__log__date "Novembre 2020"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "Plantation de thé avant gestion."

    wp post meta add $post_id _wpf_case_study__log__date "Décembre 2020"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "Plantation de thé après les travaux de taille. Les jeunes feuilles vert clair à la surface ont été coupées, donnant un aspect général vert foncé."
  fi

  if [ "$lang" == "zh" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__zh
    wp post term add $post_id area japan-mie

    wp post meta add $post_id _wpf_case_study__basic__heading "实践者"
    wp post meta add $post_id _wpf_case_study__basic__body "株式会社樱自然塾、Synecoculture协会"

    wp post meta add $post_id _wpf_case_study__basic__heading "地点"
    wp post meta add $post_id _wpf_case_study__basic__body "三重县伊势市"

    wp post meta add $post_id _wpf_case_study__basic__heading "气候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "日本的温暖湿润气候"

    wp post meta add $post_id _wpf_case_study__basic__heading "期间"
    wp post meta add $post_id _wpf_case_study__basic__body "2020年11月起"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地初期状态"
    wp post meta add $post_id _wpf_case_study__basic__body "几乎完全废弃的茶园。长得很高的鬼针草等植物已经生长并枯萎,虽然茶树旺盛生长,但如果放置不管地上部分会长得过大,导致茶树变弱。"


    wp post meta add $post_id _wpf_case_study__detail__heading "种植的植物"
    wp post meta add $post_id _wpf_case_study__detail__body "保留现有茶树的同时,对部分进行移植。今后计划引入果树和蔬菜。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "每年数次修剪茶树(使用履带式全自动采茶机)、茶树行间除草(使用手推式发动机修剪机)、手工清除过高的草(不拔根仅割取地上部分,根部用于土壤结构形成)、移植部分茶树重新配置畦垄。"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入资材·成本"
    wp post meta add $post_id _wpf_case_study__detail__body "履带式全自动采茶机、手推式发动机修剪机、保留现有茶树。"


    wp post meta add $post_id _wpf_case_study__results__heading "收获物"
    wp post meta add $post_id _wpf_case_study__results__body "准备阶段暂未收获"

    wp post meta add $post_id _wpf_case_study__results__heading "收获以外的变化"
    wp post meta add $post_id _wpf_case_study__results__body "准备阶段暂未观测"

    wp post meta add $post_id _wpf_case_study__results__heading "优点"
    wp post meta add $post_id _wpf_case_study__results__body "准备阶段暂未评价"

    wp post meta add $post_id _wpf_case_study__results__heading "困难之处"
    wp post meta add $post_id _wpf_case_study__results__body "准备阶段暂未评价"


    wp post meta add $post_id _wpf_case_study__log__date "2020年11月"
    wp post meta add $post_id _wpf_top__learn__image $log_1_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "管理前的茶园样貌。"

    wp post meta add $post_id _wpf_case_study__log__date "2020年12月"
    wp post meta add $post_id _wpf_top__learn__image $log_2_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "修剪作业结束后的茶园。表面浅绿色的嫩叶被修剪,整体呈现深绿色。"
  fi
done
