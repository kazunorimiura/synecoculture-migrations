#!/bin/bash

# ./migrations/page_migrations/history/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

# homeスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="history" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 事前にカスタムフィールドをクリーンアップ
  wp post meta delete $post_id --all

  replace_languages_provided $post_id ja

  wp post update $post_id --post_excerpt="一般社団法人シネコカルチャーのこれまでの歩みをご紹介します。"

  wp post meta add $post_id _wpf_history__heading "2008"
  wp post meta add $post_id _wpf_history__body "（株）桜自然塾 大塚隆による原形の実験"

  wp post meta add $post_id _wpf_history__heading "2010"
  wp post meta add $post_id _wpf_history__body "Sony CSL 舩橋真俊による科学的定式化と検証"

  wp post meta add $post_id _wpf_history__heading "2014"
  wp post meta add $post_id _wpf_history__body "Sony CSL を通じて、UNESCO UniTwin 複雑系ディジタルキャンパスに加入"

  wp post meta add $post_id _wpf_history__heading "2017"
  wp post meta add $post_id _wpf_history__body "アフリカ・ブルキナファソにシネコカルチャー研究教育センターの設立"

  wp post meta add $post_id _wpf_history__heading "2018"
  wp post meta add $post_id _wpf_history__body "一般社団法人シネコカルチャーの設立"

  wp post meta add $post_id _wpf_history__heading "2019"
  wp post meta add $post_id _wpf_history__body "CEDEAO諸国の農業支援プログラムにマリのシネコカルチャープロジェクトが採択"

  wp post meta add $post_id _wpf_history__heading "2019"
  wp post meta add $post_id _wpf_history__body "六本木ヒルズでシネコカルチャーに関する実証実験スタート (Sony CSL/森ビル）"

  wp post meta add $post_id _wpf_history__heading "2020"
  wp post meta add $post_id _wpf_history__body "アフリカ・トーゴ共和国のCOVID-19対策支援国家プロジェクトにシネコカルチャーを導入"

  wp post meta add $post_id _wpf_history__heading "2020"
  wp post meta add $post_id _wpf_history__body "公益財団法人 福武財団 の活動の一環として、岡山県の犬島および香川県の直島諸島においてシネコカルチャーの取り組みを開始"

  wp post meta add $post_id _wpf_history__heading "2021"
  wp post meta add $post_id _wpf_history__body "資本主義原理の中でSynecoculture™のスケールに取り組むための事業体として株式会社SynecOを設立"
done
