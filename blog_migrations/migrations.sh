#!/bin/bash

# ./migrations/blog_migrations/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/copy_post.sh
source ./migrations/utils/replace_languages_provided.sh
source ./migrations/blog_migrations/_set_tr_post.sh

category_media=$(wp eval "echo get_term_by('slug', 'media-coverage', 'category')->term_id;")
category_donate=$(wp eval "echo get_term_by('slug', 'donation-usage-report', 'category')->term_id;")
category_sponsorship=$(wp eval "echo get_term_by('slug', 'sponsorship-opportunities', 'category')->term_id;")

post_type="blog"
post_ids=$(wp post list --post_type="$post_type" --field=ID)
for post_id in $post_ids; do
  post_title=$(wp post get $post_id --field=post_title)
  message "$post_id, $post_title" bold

  ###
  ### xmlインポート時点では日本語の記事がほとんどだが、中には英語のみ提供の投稿もあるため、適宜ふさわしい言語版に振り分ける
  ###

  # 一旦、この投稿の提供言語を日本語のみにする
  replace_languages_provided $post_id ja

  ###
  ### ニュースに移植し、カテゴリを設定
  ###

  if [ "$post_title" == "【インタビュー記事掲載】未来の食を考えるウェブメディア「What To Eat ?」" ]; then
    wp post update $post_id --post_type="post" --post_category=$category_media
  fi

  if [ "$post_title" == "ラジオ出演のお知らせ" ]; then
    wp post update $post_id --post_type="post" --post_category=$category_media
  fi

  if [ "$post_title" == "寄付金使用報告：2020年" ]; then
    wp post update $post_id --post_type="post" --post_category=$category_donate
  fi

  if [ "$post_title" == "寄附金使用報告：2021年" ]; then
    wp post update $post_id --post_type="post" --post_category=$category_donate
  fi

  if [ "$post_title" == "シネコカルチャー研究航海 プロダクトスポンサー募集のお知らせ" ]; then
    wp post update $post_id --post_type="post" --post_category=$category_sponsorship
  fi

  ###
  ### 投稿を英語版へコピー
  ###

  tr_post_id=$(copy_post $post_id en)
  if [ "$tr_post_id" -ne 0 ]; then
    message "tr_post_id (en): $tr_post_id" success
  else
    message "Failed to create en post" error
  fi

  ###
  ### 英語版コンテンツのマイグレーション
  ###

  # "ソニーの「社会課題と技術」特集に対談掲載"の英訳と思われる投稿を英語版に紐づける
  set_tr_post $post_id $tr_post_id 2707 "interview-featured-in-sonys-social-issues-and-technologies-special-edition" en blog

  # "協生農法・拡張生態系に関わる人々の越境と社会普及のためのフレームワークについて"の英訳と思われる投稿を英語版に紐づける
  set_tr_post $post_id $tr_post_id 3364 "a-framework-for-collaboration-across-borders-and-sharing-with-society" en blog

  # "表土とウイルス"の英訳と思われる投稿を英語版に紐づける
  set_tr_post $post_id $tr_post_id 2640 "topsoil-and-viruses" en blog

  # "Presentation at 7th International Conference on Biodiversity Conservation and Ecosystem Management in Melbourne, Australia"は英語版のみの提供とする
  if [ "$post_title" == "Presentation at 7th International Conference on Biodiversity Conservation and Ecosystem Management in Melbourne, Australia" ]; then
    replace_languages_provided $post_id en
  fi

  # "Visit to Africa Centre for Holistic Management (1)"は英語版のみの提供とする
  if [ "$post_title" == "Visit to Africa Centre for Holistic Management (1)" ]; then
    replace_languages_provided $post_id en
  fi

  # "Visit to Africa Centre for Holistic Management (2)"は英語版のみの提供とする
  if [ "$post_title" == "Visit to Africa Centre for Holistic Management (2)" ]; then
    replace_languages_provided $post_id en
  fi

  # "Visit to Africa Centre for Holistic Management (3)"は英語版のみの提供とする
  if [ "$post_title" == "Visit to Africa Centre for Holistic Management (3)" ]; then
    replace_languages_provided $post_id en
  fi

  # "Visit to Africa Centre for Holistic Management (4)"は英語版のみの提供とする
  if [ "$post_title" == "Visit to Africa Centre for Holistic Management (4)" ]; then
    replace_languages_provided $post_id en
  fi

  ###
  ### 投稿をフランス語版へコピー
  ###

  tr_post_id=$(copy_post $post_id fr)
  if [ "$tr_post_id" -ne 0 ]; then
    message "tr_post_id (fr): $tr_post_id" success
  else
    message "Failed to create fr post" error
  fi

  # "表土とウイルス"のフランス語訳と思われる投稿をフランス語版に紐づける
  set_tr_post $post_id $tr_post_id 2640 "terre-arable-et-virus" fr blog

  ###
  ### 投稿を中国語版へコピー
  ###

  tr_post_id=$(copy_post $post_id zh)
  if [ "$tr_post_id" -ne 0 ]; then
    message "tr_post_id (zh): $tr_post_id" success
  else
    message "Failed to create zh post" error
  fi

  # "表土とウイルス"の中国語訳と思われる投稿を中国語版に紐づける
  set_tr_post $post_id $tr_post_id 2640 "post-2695" zh blog

  # "論文「人間による生態系の拡張：食料生産と科学の2045年目標」邦訳"の中国語訳と思われる投稿を中国語版に紐づける
  set_tr_post $post_id $tr_post_id 781 "post-817" zh blog
done
