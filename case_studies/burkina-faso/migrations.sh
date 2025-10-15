#!/bin/bash

# ./migrations/case_studies/burkina-faso/migrations.sh
# メディアをインポートする場合:
# ./migrations/case_studies/burkina-faso/migrations.sh --import-media

source ./migrations/utils/message.sh

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
    wp post meta update $post_id _thumbnail_id $thumbnail_id__en
    wp post term add $post_id area africa-burkina-faso

    wp post meta add $post_id _wpf_case_study__basic__heading "Practitioner"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA, CARFS, André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "Location"
    wp post meta add $post_id _wpf_case_study__basic__body "Mahadaga, Tapoa Province, Burkina Faso, Africa"

    wp post meta add $post_id _wpf_case_study__basic__heading "Climate Conditions"
    wp post meta add $post_id _wpf_case_study__basic__body "Semi-arid tropical"

    wp post meta add $post_id _wpf_case_study__basic__heading "Duration"
    wp post meta add $post_id _wpf_case_study__basic__body "March 2015 - May 2018 (Commercial production period: June 2015 - May 2018)"

    wp post meta add $post_id _wpf_case_study__basic__heading "Field Area"
    wp post meta add $post_id _wpf_case_study__basic__body "500 m²"

    wp post meta add $post_id _wpf_case_study__basic__heading "Initial Land Condition"
    wp post meta add $post_id _wpf_case_study__basic__body "Bare land previously used for conventional market gardening but abandoned due to soil degradation. No natural regeneration occurred, and the surrounding area showed vegetation patterns indicative of desertification."


    wp post meta add $post_id _wpf_case_study__detail__heading "Plants Cultivated"
    wp post meta add $post_id _wpf_case_study__detail__body "Strategic polyculture of 150 edible plant species (including 40 staple crops). Includes typical plant types corresponding to mature vegetation succession stages: annual and perennial pioneer plants, shrubs, vines, sun-loving and shade-tolerant trees."

    wp post meta add $post_id _wpf_case_study__detail__heading "Management Method"
    wp post meta add $post_id _wpf_case_study__detail__body "No tillage, no synthetic or organic fertilizers, no pesticides or plant health products, no agricultural machinery, irrigation as needed, minimal weeding"

    wp post meta add $post_id _wpf_case_study__detail__heading "Inputs & Costs"
    wp post meta add $post_id _wpf_case_study__detail__body "Seeds and seedlings only."


    wp post meta add $post_id _wpf_case_study__results__heading "Harvest"
    wp post meta add $post_id _wpf_case_study__results__body "37 plant species were harvested and sold at local markets. Specifically: Moringa, Okra, Cabbage, Broccoli, Bell Pepper, Chili Pepper, Lemon, Carrot, Roselle, Bitter Gourd, Green Bean, Sorrel, Tomato, Eggplant, Onion, Garlic, Pigeon Pea, Melon, Cucumber, Pumpkin, Zucchini, Hibiscus acetosella, Hibiscus rosa-sinensis, Hibiscus syriacus, Micrococcus, Moringa stenopetala, Guava, Papaya, Air Potato, Yellow Yam, Cassava, Taro, Plantain Banana, Baobab, Lemongrass, Spearmint, Sweet Potato."

    wp post meta add $post_id _wpf_case_study__results__heading "Other Changes"
    wp post meta add $post_id _wpf_case_study__results__body "\"Desertification reversal phenomenon\" with greenery spreading to surrounding bare land. Increased soil porosity, water retention, permeability, organic matter content, and microbial activity. Complex food chains formed, leading to natural pest control."

    wp post meta add $post_id _wpf_case_study__results__heading "Benefits"
    wp post meta add $post_id _wpf_case_study__results__body "Compared to conventional farming and other alternative methods (rice cultivation + trees, conservation agriculture, permaculture, bio-intensive horticulture, traditional horticulture), profitability reached 258 times and production 12 times higher. With high market access, revenue improved 121 times; with low access, 55 times (average 88 times). Ecosystem restoration effects spread to surrounding farmland."

    wp post meta add $post_id _wpf_case_study__results__heading "Challenges"
    wp post meta add $post_id _wpf_case_study__results__body "Large year-to-year yield fluctuations made stable evaluation using arithmetic mean difficult. Deteriorating security reduced market access, forcing price reductions."


    wp post meta add $post_id _wpf_case_study__log__date "March 2015"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id__en
    wp post meta add $post_id _wpf_case_study__log__body "Initial land condition"

    wp post meta add $post_id _wpf_case_study__log__date "March 2016"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id__en
    wp post meta add $post_id _wpf_case_study__log__body "One year later"
  fi

  if [ "$lang" == "fr" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__fr
    wp post term add $post_id area africa-burkina-faso

    wp post meta add $post_id _wpf_case_study__basic__heading "Praticien"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA, CARFS, André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "Lieu"
    wp post meta add $post_id _wpf_case_study__basic__body "Mahadaga, Province de la Tapoa, Burkina Faso, Afrique"

    wp post meta add $post_id _wpf_case_study__basic__heading "Conditions climatiques"
    wp post meta add $post_id _wpf_case_study__basic__body "Tropical semi-aride"

    wp post meta add $post_id _wpf_case_study__basic__heading "Période"
    wp post meta add $post_id _wpf_case_study__basic__body "Mars 2015 - Mai 2018 (Période de production commerciale : Juin 2015 - Mai 2018)"

    wp post meta add $post_id _wpf_case_study__basic__heading "Surface du champ"
    wp post meta add $post_id _wpf_case_study__basic__body "500 m²"

    wp post meta add $post_id _wpf_case_study__basic__heading "État initial du terrain"
    wp post meta add $post_id _wpf_case_study__basic__body "Terrain nu précédemment utilisé pour le maraîchage conventionnel mais abandonné en raison de la dégradation du sol. Aucune régénération naturelle ne s'est produite, et la zone environnante présentait des schémas de végétation indiquant une désertification."


    wp post meta add $post_id _wpf_case_study__detail__heading "Plantes cultivées"
    wp post meta add $post_id _wpf_case_study__detail__body "Polyculture stratégique de 150 espèces de plantes comestibles (dont 40 cultures vivrières principales). Comprend des types de plantes typiques correspondant aux stades matures de succession végétale : plantes pionnières annuelles et vivaces, arbustes, plantes grimpantes, arbres héliophiles et sciaphiles."

    wp post meta add $post_id _wpf_case_study__detail__heading "Méthode de gestion"
    wp post meta add $post_id _wpf_case_study__detail__body "Aucun labour, aucun engrais synthétique ou organique, aucun pesticide ou produit phytosanitaire, aucune machinerie agricole, irrigation selon les besoins, désherbage minimal"

    wp post meta add $post_id _wpf_case_study__detail__heading "Intrants et coûts"
    wp post meta add $post_id _wpf_case_study__detail__body "Graines et plants uniquement."


    wp post meta add $post_id _wpf_case_study__results__heading "Récoltes"
    wp post meta add $post_id _wpf_case_study__results__body "37 espèces de plantes ont été récoltées et vendues sur les marchés locaux. Spécifiquement : Moringa, Gombo, Chou, Brocoli, Poivron, Piment, Citron, Carotte, Oseille de Guinée, Margose, Haricot vert, Oseille, Tomate, Aubergine, Oignon, Ail, Pois d'Angole, Melon, Concombre, Courge, Courgette, Hibiscus acetosella, Hibiscus rosa-sinensis, Hibiscus syriacus, Micrococcus, Moringa stenopetala, Goyave, Papaye, Igname aérienne, Igname jaune, Manioc, Taro, Banane plantain, Baobab, Citronnelle, Menthe verte, Patate douce."

    wp post meta add $post_id _wpf_case_study__results__heading "Autres changements"
    wp post meta add $post_id _wpf_case_study__results__body "« Phénomène d'inversion de la désertification » avec verdissement s'étendant aux terrains nus environnants. Augmentation de la porosité du sol, de la rétention d'eau, de la perméabilité, de la teneur en matière organique et de l'activité microbienne. Formation de chaînes alimentaires complexes conduisant à un contrôle naturel des ravageurs."

    wp post meta add $post_id _wpf_case_study__results__heading "Points positifs"
    wp post meta add $post_id _wpf_case_study__results__body "Par rapport à l'agriculture conventionnelle et aux autres méthodes alternatives (riziculture + arbres, agriculture de conservation, permaculture, horticulture bio-intensive, horticulture traditionnelle), la rentabilité a atteint 258 fois et la production 12 fois supérieure. Avec un accès élevé au marché, les revenus ont été améliorés de 121 fois ; avec un faible accès, de 55 fois (moyenne de 88 fois). Les effets de restauration de l'écosystème se sont étendus aux terres agricoles environnantes."

    wp post meta add $post_id _wpf_case_study__results__heading "Difficultés"
    wp post meta add $post_id _wpf_case_study__results__body "De grandes fluctuations de rendement d'une année à l'autre ont rendu difficile l'évaluation stable à l'aide de la moyenne arithmétique. La détérioration de la sécurité a réduit l'accès au marché, obligeant à réduire les prix."


    wp post meta add $post_id _wpf_case_study__log__date "Mars 2015"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "État initial du terrain"

    wp post meta add $post_id _wpf_case_study__log__date "Mars 2016"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id__fr
    wp post meta add $post_id _wpf_case_study__log__body "Un an plus tard"
  fi

  if [ "$lang" == "zh" ]; then
    wp post meta update $post_id _thumbnail_id $thumbnail_id__zh
    wp post term add $post_id area africa-burkina-faso

    wp post meta add $post_id _wpf_case_study__basic__heading "实践者"
    wp post meta add $post_id _wpf_case_study__basic__body "AFIDRA、CARFS、André Tindano"

    wp post meta add $post_id _wpf_case_study__basic__heading "地点"
    wp post meta add $post_id _wpf_case_study__basic__body "非洲布基纳法索塔波阿省马哈达加"

    wp post meta add $post_id _wpf_case_study__basic__heading "气候条件"
    wp post meta add $post_id _wpf_case_study__basic__body "半干旱热带"

    wp post meta add $post_id _wpf_case_study__basic__heading "期间"
    wp post meta add $post_id _wpf_case_study__basic__body "2015年3月至2018年5月(商业生产期间:2015年6月至2018年5月)"

    wp post meta add $post_id _wpf_case_study__basic__heading "田地面积"
    wp post meta add $post_id _wpf_case_study__basic__body "500平方米"

    wp post meta add $post_id _wpf_case_study__basic__heading "土地初始状态"
    wp post meta add $post_id _wpf_case_study__basic__body "曾用于传统市场园艺但因土壤退化而被废弃的裸地。没有发生自然再生,周边地区呈现荒漠化迹象的植被模式。"


    wp post meta add $post_id _wpf_case_study__detail__heading "种植植物"
    wp post meta add $post_id _wpf_case_study__detail__body "150种食用植物的战略性混作(包括40种主粮作物)。包含对应成熟植被演替阶段的典型植物类型:一年生和多年生先锋植物、灌木、藤本植物、阳生树木和耐阴树木。"

    wp post meta add $post_id _wpf_case_study__detail__heading "管理方法"
    wp post meta add $post_id _wpf_case_study__detail__body "不耕作、不使用合成或有机肥料、不使用农药或植物保护产品、不使用农业机械、按需灌溉、少量除草作业"

    wp post meta add $post_id _wpf_case_study__detail__heading "投入资材与成本"
    wp post meta add $post_id _wpf_case_study__detail__body "仅种子和苗木。"


    wp post meta add $post_id _wpf_case_study__results__heading "收获物"
    wp post meta add $post_id _wpf_case_study__results__body "收获了37种植物并在当地市场销售。具体包括:辣木、秋葵、卷心菜、西兰花、甜椒、辣椒、柠檬、胡萝卜、玫瑰茄、苦瓜、四季豆、酸模、番茄、茄子、洋葱、大蒜、木豆、甜瓜、黄瓜、南瓜、西葫芦、红蓼、朱槿、木槿、小球藻、辣木(窄瓣种)、番石榴、木瓜、黄独、黄薯、木薯、芋头、大蕉、猴面包树、柠檬草、留兰香、甘薯。"

    wp post meta add $post_id _wpf_case_study__results__heading "其他变化"
    wp post meta add $post_id _wpf_case_study__results__body ""荒漠化逆转现象",绿色植被扩展到周边裸地。土壤孔隙结构、保水性、透水性、有机质含量和微生物活性增加。形成了复杂的食物链,害虫得到自然控制。"

    wp post meta add $post_id _wpf_case_study__results__heading "优点"
    wp post meta add $post_id _wpf_case_study__results__body "与常规农业和其他替代方法(水稻种植+树木、保护性农业、永续农业、生物集约型园艺、传统园艺)相比,盈利能力达到258倍,产量达到12倍。在市场准入度高时收益提高121倍,准入度低时也有55倍(平均88倍)。生态系统恢复效应扩展到周边农田。"

    wp post meta add $post_id _wpf_case_study__results__heading "遇到的困难"
    wp post meta add $post_id _wpf_case_study__results__body "年度产量波动较大,难以用算术平均值进行稳定评估。治安恶化导致市场准入度降低,不得不降低销售价格。"


    wp post meta add $post_id _wpf_case_study__log__date "2015年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_1_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "土地初始状态"

    wp post meta add $post_id _wpf_case_study__log__date "2016年3月"
    wp post meta add $post_id _wpf_top__learn__image $burkina_faso_2_id__zh
    wp post meta add $post_id _wpf_case_study__log__body "一年后的情况"
  fi
done
