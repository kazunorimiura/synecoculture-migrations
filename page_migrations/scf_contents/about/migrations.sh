#!/bin/bash

# ./migrations/page_migrations/scf_contents/about/migrations.sh
# メディアをインポートする場合:
# ./migrations/page_migrations/scf_contents/about/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/page_migrations/scf_contents/about/media
WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"  # 年月ディレクトリパスは実行する年月によって適宜修正

### 画像の定義 ###

# 実地説明画像を定義
jitti_setsumei_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2019/01/実地の説明.png' );")
message "jitti_setsumei_id: $jitti_setsumei_id"
jitti_setsumei_id__en=$(wp eval "echo pll_get_post('$jitti_setsumei_id', 'en');")
jitti_setsumei_id__fr=$(wp eval "echo pll_get_post('$jitti_setsumei_id', 'fr');")
jitti_setsumei_id__zh=$(wp eval "echo pll_get_post('$jitti_setsumei_id', 'zh');")

# 舩橋さん画像を定義
funabashi_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2025/10/masatoshi-funabashi.jpg' );")
message "funabashi_id: $funabashi_id"
funabashi_id__en=$(wp eval "echo pll_get_post('$funabashi_id', 'en');")
funabashi_id__fr=$(wp eval "echo pll_get_post('$funabashi_id', 'fr');")
funabashi_id__zh=$(wp eval "echo pll_get_post('$funabashi_id', 'zh');")

# メンバーサムネイル画像を定義
FILE_NAME="members-thumbnail.jpg"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  members_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
  message "members_id (new import): $members_id"
  members_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $members_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "members_id__en (new copy): $members_id__en"
  members_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $members_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "members_id__fr (new copy): $members_id__fr"
  members_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $members_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "members_id__zh (new copy): $members_id__zh"
else
  members_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "members_id (already import): $members_id"
  members_id__en=$(wp eval "echo pll_get_post('$members_id', 'en');")
  message "members_id__en (fetch): $members_id__en"
  members_id__fr=$(wp eval "echo pll_get_post('$members_id', 'fr');")
  message "members_id__fr (fetch): $members_id__fr"
  members_id__zh=$(wp eval "echo pll_get_post('$members_id', 'zh');")
  message "members_id__zh (fetch): $members_id__zh"
fi

# 組織概要サムネイル画像を定義
FILE_NAME="corp-data.png"
if [ "$IMPORT_MEDIA" == "--import-media" ]; then
  corp_data_id=$(wp media import "$MEDIA_PATH/${FILE_NAME}" --porcelain)
  message "corp_data_id (new import): $corp_data_id"
  corp_data_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $corp_data_id, 'en' ); PLL()->model->clean_languages_cache();")
  message "corp_data_id__en (new copy): $corp_data_id__en"
  corp_data_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $corp_data_id, 'fr' ); PLL()->model->clean_languages_cache();")
  message "corp_data_id__fr (new copy): $corp_data_id__fr"
  corp_data_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $corp_data_id, 'zh' ); PLL()->model->clean_languages_cache();")
  message "corp_data_id__zh (new copy): $corp_data_id__zh"
else
  corp_data_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILE_NAME}' );")
  message "corp_data_id (already import): $corp_data_id"
  corp_data_id__en=$(wp eval "echo pll_get_post('$corp_data_id', 'en');")
  message "corp_data_id__en (fetch): $corp_data_id__en"
  corp_data_id__fr=$(wp eval "echo pll_get_post('$corp_data_id', 'fr');")
  message "corp_data_id__fr (fetch): $corp_data_id__fr"
  corp_data_id__zh=$(wp eval "echo pll_get_post('$corp_data_id', 'zh');")
  message "corp_data_id__zh (fetch): $corp_data_id__zh"
fi

# 沿革画像を定義
enkaku_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/2019/03/Picture1.png' );")
message "enkaku_id: $enkaku_id"
enkaku_id__en=$(wp eval "echo pll_get_post('$enkaku_id', 'en');")
enkaku_id__fr=$(wp eval "echo pll_get_post('$enkaku_id', 'fr');")
enkaku_id__zh=$(wp eval "echo pll_get_post('$enkaku_id', 'zh');")


### メイン処理 ###

# aboutスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="about" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  # 日本語版
  if [ "$lang" == "ja" ]; then
    wp post update $post_id --post_excerpt="一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"

    wp post meta add $post_id _wpf_about__intro__body "一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id

    wp post meta add $post_id _wpf_about__our_values__heading "科学的探究"
    wp post meta add $post_id _wpf_about__our_values__body "多分野のリサーチャー、ナビゲーターが協働・越境し、拡張生態系の理論と実証を深める。"

    wp post meta add $post_id _wpf_about__our_values__heading "知の公共化"
    wp post meta add $post_id _wpf_about__our_values__body "マニュアルやデータベースをオープンソースで共有し、誰でも拡張生態系を実践できる知識基盤を提供する。"

    wp post meta add $post_id _wpf_about__our_values__heading "教育と普及"
    wp post meta add $post_id _wpf_about__our_values__body "家庭菜園から国際プロジェクトまで幅広い現場で教育プログラムを展開し、社会実装を加速する。"

    wp post meta add $post_id _wpf_about__our_values__heading "社会連携"
    wp post meta add $post_id _wpf_about__our_values__body "外部企業や大学、地域などと積極的に連携し、研究成果を持続可能なビジネスや政策に結び付ける。"

    wp post meta add $post_id _wpf_about__child_page_links__heading "ご挨拶"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャー代表理事・舩橋 真俊からのご挨拶です。"
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "メンバー"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのリサーチャー、講師陣をご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "組織概要"
    wp post meta add $post_id _wpf_about__child_page_links__body "事業内容や所在地などの組織概要をご案内します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "沿革"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのこれまでの歩みをご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/history/"
  fi

  # 英語版
  if [ "$lang" == "en" ]; then
    wp post update $post_id --post_excerpt="The Synecoculture Association is an organization dedicated to demonstrating and promoting Augmented Ecosystems, including Synecoculture™, a farming method that makes food production a catalyst for environmental restoration. Established in 2018 as a bridge to social implementation, it builds upon foundational research conducted at Sony CSL."

    wp post meta add $post_id _wpf_about__intro__body "The Synecoculture Association is an organization dedicated to demonstrating and promoting Augmented Ecosystems, including Synecoculture™, a farming method that makes food production a catalyst for environmental restoration. Established in 2018 as a bridge to social implementation, it builds upon foundational research conducted at Sony CSL."
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id

    wp post meta add $post_id _wpf_about__our_values__heading "Scientific Inquiry"
    wp post meta add $post_id _wpf_about__our_values__body "Multidisciplinary researchers and navigators collaborate and transcend boundaries to deepen the theory and practice of Augmented Ecosystems."

    wp post meta add $post_id _wpf_about__our_values__heading "Democratization of Knowledge"
    wp post meta add $post_id _wpf_about__our_values__body "We share manuals and databases as open source, providing a knowledge foundation that enables anyone to practice Augmented Ecosystems."

    wp post meta add $post_id _wpf_about__our_values__heading "Education and Dissemination"
    wp post meta add $post_id _wpf_about__our_values__body "We develop educational programs across diverse settings—from home gardens to international projects—to accelerate social implementation."

    wp post meta add $post_id _wpf_about__our_values__heading "Social Collaboration"
    wp post meta add $post_id _wpf_about__our_values__body "We actively partner with external companies, universities, and communities to translate research outcomes into sustainable businesses and policies."

    wp post meta add $post_id _wpf_about__child_page_links__heading "Message"
    wp post meta add $post_id _wpf_about__child_page_links__body "Greetings from Masatoshi Funabashi, Representative Director of Synecoculture Association."
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/en/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "Members"
    wp post meta add $post_id _wpf_about__child_page_links__body "Meet our researchers and navigators at Synecoculture Association."
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/en/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "Company Profile"
    wp post meta add $post_id _wpf_about__child_page_links__body "Learn about our organizational overview, including business activities and location."
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/en/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "History"
    wp post meta add $post_id _wpf_about__child_page_links__body "Discover the history and journey of Synecoculture Association."
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/en/about/history/"
  fi

  # フランス語版
  if [ "$lang" == "fr" ]; then
    wp post update $post_id --post_excerpt="L'association Synecoculture est une organisation qui se consacre à la recherche démonstrative et à la promotion des Écosystèmes Augmentés, notamment la méthode agricole Synecoculture™, où la production alimentaire devient le point de départ de la restauration environnementale. Créée en 2018 comme intermédiaire vers la mise en œuvre sociale, elle s'appuie sur des recherches fondamentales menées au Sony CSL."

    wp post meta add $post_id _wpf_about__intro__body "L'association Synecoculture est une organisation qui se consacre à la recherche démonstrative et à la promotion des Écosystèmes Augmentés, notamment la méthode agricole Synecoculture™, où la production alimentaire devient le point de départ de la restauration environnementale. Créée en 2018 comme intermédiaire vers la mise en œuvre sociale, elle s'appuie sur des recherches fondamentales menées au Sony CSL."
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id

    wp post meta add $post_id _wpf_about__our_values__heading "Recherche Scientifique"
    wp post meta add $post_id _wpf_about__our_values__body "Des chercheurs et navigateurs multidisciplinaires collaborent et transcendent les frontières pour approfondir la théorie et la pratique des Écosystèmes Augmentés."

    wp post meta add $post_id _wpf_about__our_values__heading "Démocratisation du Savoir"
    wp post meta add $post_id _wpf_about__our_values__body "Nous partageons des manuels et des bases de données en open source, fournissant une base de connaissances permettant à chacun de pratiquer les Écosystèmes Augmentés."

    wp post meta add $post_id _wpf_about__our_values__heading "Éducation et Diffusion"
    wp post meta add $post_id _wpf_about__our_values__body "Nous développons des programmes éducatifs dans divers contextes—des jardins familiaux aux projets internationaux—pour accélérer la mise en œuvre sociale."

    wp post meta add $post_id _wpf_about__our_values__heading "Collaboration Sociale"
    wp post meta add $post_id _wpf_about__our_values__body "Nous collaborons activement avec des entreprises externes, des universités et des communautés locales pour transformer les résultats de recherche en activités économiques et politiques durables."

    wp post meta add $post_id _wpf_about__child_page_links__heading "Message"
    wp post meta add $post_id _wpf_about__child_page_links__body "Message de Masatoshi Funabashi, Directeur Représentant de l'Association Synecoculture."
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/fr/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "Membres"
    wp post meta add $post_id _wpf_about__child_page_links__body "Découvrez nos chercheurs et navigateurs de l'Association Synecoculture."
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/fr/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "Profil de l'entreprise"
    wp post meta add $post_id _wpf_about__child_page_links__body "Consultez notre présentation générale, incluant nos activités et notre localisation."
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/fr/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "Historique"
    wp post meta add $post_id _wpf_about__child_page_links__body "Explorez l'histoire et le parcours de l'Association Synecoculture."
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/fr/about/history/"
  fi

  # 中国語版
  if [ "$lang" == "zh" ]; then
    wp post update $post_id --post_excerpt="Synecoculture协会是一个致力于扩展生态系统实证研究与推广活动的组织,其中包括将粮食生产作为环境恢复起点的农业方法Synecoculture™。该协会于2018年成立,作为社会实施的桥梁,建立在索尼CSL基础研究的基础上。"

    wp post meta add $post_id _wpf_about__intro__body "Synecoculture协会是一个致力于扩展生态系统实证研究与推广活动的组织,其中包括将粮食生产作为环境恢复起点的农业方法Synecoculture™。该协会于2018年成立,作为社会实施的桥梁,建立在索尼CSL基础研究的基础上。"
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id

    wp post meta add $post_id _wpf_about__our_values__heading "科学探索"
    wp post meta add $post_id _wpf_about__our_values__body "多学科研究人员与领航者协作跨界，深化扩展生态系统的理论与实证研究。"

    wp post meta add $post_id _wpf_about__our_values__heading "知识公共化"
    wp post meta add $post_id _wpf_about__our_values__body "我们以开源方式共享手册和数据库，提供人人都能实践扩展生态系统的知识基础。"

    wp post meta add $post_id _wpf_about__our_values__heading "教育与普及"
    wp post meta add $post_id _wpf_about__our_values__body "我们在从家庭菜园到国际项目的广泛场景中开展教育项目，加速社会实施。"

    wp post meta add $post_id _wpf_about__our_values__heading "社会合作"
    wp post meta add $post_id _wpf_about__our_values__body "我们积极与外部企业、大学及地区合作，将研究成果转化为可持续的商业模式和政策。"

    wp post meta add $post_id _wpf_about__child_page_links__heading "致辞"
    wp post meta add $post_id _wpf_about__child_page_links__body "Synecoculture协会代表理事·舩橋真俊的致辞。"
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/zh/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "成员"
    wp post meta add $post_id _wpf_about__child_page_links__body "介绍Synecoculture协会的研究员和向导。"
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/zh/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "组织概况"
    wp post meta add $post_id _wpf_about__child_page_links__body "介绍包括业务内容和所在地在内的组织概况。"
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/zh/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "历史"
    wp post meta add $post_id _wpf_about__child_page_links__body "介绍Synecoculture协会至今的发展历程。"
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/zh/about/history/"
  fi
done
