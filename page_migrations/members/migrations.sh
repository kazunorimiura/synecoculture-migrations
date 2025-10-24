#!/bin/bash

# ./migrations/page_migrations/members/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/replace_languages_provided.sh

# membersスラッグの固定ページを全言語分取得
post_ids=$(wp post list --post_type=page --name="members" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  message "lang: $lang"

  # 日本語版
  if [ "$lang" == "ja" ]; then
    replace_languages_provided $post_id ja
  fi

  wp post meta update $post_id _wpf_subtitle "生物学・複雑系・情報科学・農学・デザイン・キュレーション・市民科学など、多様なバックグラウンドを持つ研究者やナビゲーターが集まり、それぞれが専門性を発揮しつつも、研究領域や国・地域、研究か事業かなどのあらゆる境界を超えて活動しています。"
done
