#!/bin/bash

# ./migrations/page_migrations/about/migrations.sh
# メディアをインポートする場合:
# ./migrations/page_migrations/about/migrations.sh --import-media

set -a               # exportを自動で付与するモード
source ./migrations/.env
set +a

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh
source ./migrations/page_migrations/_attach_cover.sh

IMPORT_MEDIA=$1

MEDIA_PATH=/srv/www/synecoculture/migrations/page_migrations/about/media
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
    replace_languages_provided $post_id ja
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
    replace_languages_provided $post_id ja
    wp post update $post_id --post_excerpt="一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"

    wp post meta add $post_id _wpf_about__intro__body "一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id__en

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
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id__en
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "メンバー"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのリサーチャー、講師陣をご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id__en
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "組織概要"
    wp post meta add $post_id _wpf_about__child_page_links__body "事業内容や所在地などの組織概要をご案内します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id__en
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "沿革"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのこれまでの歩みをご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id__en
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/history/"
  fi

  # フランス語版
  if [ "$lang" == "fr" ]; then
    replace_languages_provided $post_id ja
    wp post update $post_id --post_excerpt="一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"

    wp post meta add $post_id _wpf_about__intro__body "一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id__fr

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
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id__fr
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "メンバー"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのリサーチャー、講師陣をご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id__fr
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "組織概要"
    wp post meta add $post_id _wpf_about__child_page_links__body "事業内容や所在地などの組織概要をご案内します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id__fr
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "沿革"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのこれまでの歩みをご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id__fr
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/history/"
  fi

  # 中国語版
  if [ "$lang" == "zh" ]; then
    replace_languages_provided $post_id ja
    wp post update $post_id --post_excerpt="一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"

    wp post meta add $post_id _wpf_about__intro__body "一般社団法人シネコカルチャーは、食料生産が環境回復の起点となる農法・Synecoculture™をはじめとした拡張生態系の実証研究や普及活動に取り組む団体です。ソニーCSLでの基礎研究を経て、2018年に社会実装の橋渡し役として設立されました。"
    wp post meta add $post_id _wpf_about__intro__image $jitti_setsumei_id__zh

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
    wp post meta add $post_id _wpf_about__child_page_links__image $funabashi_id__zh
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/message/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "メンバー"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのリサーチャー、講師陣をご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $members_id__zh
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/members/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "組織概要"
    wp post meta add $post_id _wpf_about__child_page_links__body "事業内容や所在地などの組織概要をご案内します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $corp_data_id__zh
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/company-profile/"

    wp post meta add $post_id _wpf_about__child_page_links__heading "沿革"
    wp post meta add $post_id _wpf_about__child_page_links__body "一般社団法人シネコカルチャーのこれまでの歩みをご紹介します。"
    wp post meta add $post_id _wpf_about__child_page_links__image $enkaku_id__zh
    wp post meta add $post_id _wpf_about__child_page_links__link_url "http://synecoculture.test/about/history/"
  fi
done


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
