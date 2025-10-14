#!/bin/bash

# ./migrations/page_migrations/company_profile/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

# homeスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="company-profile" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  replace_languages_provided $post_id ja

  wp post update $post_id --post_excerpt="一般社団法人シネコカルチャーの事業内容や目的、所在地などの組織概要をご紹介します。"

  wp post meta add $post_id _wpf_company_profile__heading "法人名"
  wp post meta add $post_id _wpf_company_profile__body "一般社団法人シネコカルチャー"

  wp post meta add $post_id _wpf_company_profile__heading "目的"
  wp post meta add $post_id _wpf_company_profile__body "この法人は、環境問題・食糧問題・健康問題の全球的な解決のために、協生農法 及び Synecoculture (以下 シネコカルチャー と称する、無耕起、無施肥、無農薬、種と苗以外一切持ち込まないという制約条件の中で、植物の特性を活かして生態系を構築・制御し、生態学的最適化状態の有用植物を生産する露地作物栽培法）を始めとした環境構築型の食糧生産法の研究と普及を行う。また同時にシネコカルチャー及び付帯関連分野・事業の研究と普及活動を行うことによって、研究成果の社会還元を目的とする。"

  wp post meta add $post_id _wpf_company_profile__heading "設立"
  wp post meta add $post_id _wpf_company_profile__body "2018年8月"

  wp post meta add $post_id _wpf_company_profile__heading "所在地"
  wp post meta add $post_id _wpf_company_profile__body "〒255-0003 神奈川県中郡大磯町大磯55"

  wp post meta add $post_id _wpf_company_profile__heading "代表理事"
  wp post meta add $post_id _wpf_company_profile__body "舩橋 真俊"

  wp post meta add $post_id _wpf_company_profile__heading "事業内容"
  wp post meta add $post_id _wpf_company_profile__body "<ul><li>シネコカルチャー（無耕起、無施肥、無農薬、種と苗以外一切持ち込まないという制約条件の中で、植物の特性を活かして生態系を構築・制御し、生態学的最適化状態の有用植物を生産する露地作物栽培法）を始めとした環境構築型の食糧生産法、及び派生分野の研究成果の社会還元</li><li>シネコカルチャーを始めとした環境構築型の食糧生産法の普及活動の支援</li><li>シネコカルチャーを始めとした環境構築型の食糧生産法の研究活動</li><li>シネコカルチャーを始めとした環境構築型の食糧生産法の実装を支援するソフトウエアの研究開発及びコンサルティング</li><li>不動産の賃貸、売買、仲介並びに管理業</li><li>エコツーリズム（環境保全型観光）の普及、啓発事業、調査及び研究</li><li>測量業</li><li>情報通信システムの企画、ポータルサイトの運営、研究開発、提供、技術指導およびコンサルタント業</li><li>飲食店の経営、各種食料品、飲料水の販売</li><li>食料品、酒類の輸出入並びに販売（物品販売）</li><li>その他この法人の目的を達成するために必要な事業</ul>"
done
