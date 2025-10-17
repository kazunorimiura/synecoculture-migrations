#!/bin/bash

# ./migrations/utils/add_terms.sh <SOURCE_FILE_PATH> <TAXONOMY_NAME>

# CSV ファイルのパス
source_file=$1
taxonomy=$2

source ./migrations/utils/message.sh

# IFS（内部フィールドセパレーター）を改行に設定
IFS=$'\n'

counter=0

# CSV ファイルを読み込み
for line in $(tail -n +2 "$source_file"); do
  ((counter++))

  # カンマで分割
  IFS=',' read -r taxonomy term_name_ja term_slug_ja parent_slug_ja term_name_en term_slug_en parent_slug_en term_name_fr term_slug_fr parent_slug_fr term_name_zh term_slug_zh parent_slug_zh depth <<< "$line"

  message "$taxonomy, $parent_slug_ja" bold

  if [ "$parent_slug_ja" != "" ]; then
    parent_term_id_ja=$(wp term get $taxonomy $parent_slug_ja --by=slug --field=term_id --format=csv)
  fi

  message "PARENT TERM ID: $parent_term_id_ja"

  translations=$(wp eval "
  \$taxonomy = '$taxonomy';

  \$term_name_ja = '$term_name_ja';
  \$term_slug_ja = '$term_slug_ja';
  \$parent_term_id_ja = '$parent_term_id_ja';

  \$term_name_en = '$term_name_en';
  \$term_slug_en = '$term_slug_en';
  \$parent_term_id_en = pll_get_term( \$parent_term_id_ja, 'en' );

  \$term_name_fr = '$term_name_fr';
  \$term_slug_fr = '$term_slug_fr';
  \$parent_term_id_fr = pll_get_term( \$parent_term_id_ja, 'fr' );

  \$term_name_zh = '$term_name_zh';
  \$term_slug_zh = '$term_slug_zh';
  \$parent_term_id_zh = pll_get_term( \$parent_term_id_ja, 'zh' );

  \$counter = (int) '$counter';
  \$depth = (int) '$depth';

  // 日本語のタームを作成
  \$ja = wp_insert_term(
    \$term_name_ja,
    \$taxonomy,
    array(
      'slug'   => \$term_slug_ja . '___ja', // ダブルアンダースコア + 言語コードはスラッグ共有マジック
      'parent' => \$parent_term_id_ja ? \$parent_term_id_ja : 0,
    )
  );
  pll_set_term_language(\$ja['term_id'], 'ja');
  \$translations = pll_get_term_translations(\$ja['term_id']);
  \$translations['ja'] = \$ja['term_id'];

  // 英語のタームを作成
  \$en = wp_insert_term(
    \$term_name_en,
    \$taxonomy,
    array(
      'slug'   => \$term_slug_en . '___en',
      'parent' => \$parent_term_id_en ? \$parent_term_id_en : 0,
    )
  );
  pll_set_term_language(\$en['term_id'], 'en');
  \$translations['en'] = \$en['term_id'];

  // フランス語のタームを作成
  \$fr = wp_insert_term(
    \$term_name_fr,
    \$taxonomy,
    array(
      'slug'   => \$term_slug_fr . '___fr',
      'parent' => \$parent_term_id_fr ? \$parent_term_id_fr : 0,
    )
  );
  pll_set_term_language(\$fr['term_id'], 'fr');
  \$translations['fr'] = \$fr['term_id'];

  // 簡体中文のタームを作成
  \$zh = wp_insert_term(
    \$term_name_zh,
    \$taxonomy,
    array(
      'slug'   => \$term_slug_zh . '___zh',
      'parent' => \$parent_term_id_zh ? \$parent_term_id_zh : 0,
    )
  );
  pll_set_term_language(\$zh['term_id'], 'zh');
  \$translations['zh'] = \$zh['term_id'];

  pll_save_term_translations(\$translations);
  update_term_meta( \$ja['term_id'], '_wpf_term_order', \$depth * \$counter );
  echo json_encode(\$translations);
  ")
  message "TRANSLATIONS: $translations"

  # クリーンアップ
  parent_term_id_ja=""
done
