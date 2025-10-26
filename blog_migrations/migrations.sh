#!/bin/bash

# ./migrations/blog_migrations/migrations.sh

source ./migrations/utils/message.sh
source ./migrations/utils/copy_post.sh
source ./migrations/utils/add_languages_provided.sh
source ./migrations/utils/replace_languages_provided.sh
source ./migrations/utils/debug_languages_provided.sh

category_media=$(wp eval "echo get_term_by('slug', 'media-coverage', 'category')->term_id;")
category_donate=$(wp eval "echo get_term_by('slug', 'donation-usage-report', 'category')->term_id;")
category_sponsorship=$(wp eval "echo get_term_by('slug', 'sponsorship-opportunities', 'category')->term_id;")

post_type="blog"
post_ids=$(wp post list --post_type="$post_type" --field=ID)
for post_id in $post_ids; do
  lang=$(wp eval "echo pll_get_post_language('$post_id', 'slug');")
  post_title=$(wp post get $post_id --field=post_title)
  message "$lang, $post_id, $post_title" bold

  # NOTE: xmlインポート時点では日本語の記事がほとんどだが、中には英語のみ提供の投稿もあるため、適宜ふさわしい言語版に振り分ける

  ###
  ### 初期状態を確認
  ###

  debug_languages_provided $post_id "初期状態"

  ###
  ### ニュースに移植し、カテゴリを設定するもの
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
  ### サブ言語版へコピー
  ###

  # 投稿を英語版へコピー
  tr_post_id=$(copy_post $post_id en)
  debug_languages_provided $post_id "copy_post (en) 実行後"

  if [ "$tr_post_id" -ne 0 ]; then
    message "tr_post_id (en): $tr_post_id" success
  else
    message "Failed to create en post" error
  fi

  # 投稿をフランス語版へコピー
  tr_post_id=$(copy_post $post_id fr)
  debug_languages_provided $post_id "copy_post (fr) 実行後"

  if [ "$tr_post_id" -ne 0 ]; then
    message "tr_post_id (fr): $tr_post_id" success
  else
    message "Failed to create fr post" error
  fi

  # 投稿を中国語版へコピー
  tr_post_id=$(copy_post $post_id zh)
  debug_languages_provided $post_id "copy_post (zh) 実行後"

  if [ "$tr_post_id" -ne 0 ]; then
    message "tr_post_id (zh): $tr_post_id" success
  else
    message "Failed to create zh post" error
  fi

  ###
  ### 提供言語を設定
  ###

  if [ "$post_title" == "Presentation at 7th International Conference on Biodiversity Conservation and Ecosystem Management in Melbourne, Australia" ]; then
    replace_languages_provided $post_id en
  elif [ "$post_title" == "Visit to Africa Centre for Holistic Management (1)" ]; then
    replace_languages_provided $post_id en
  elif [ "$post_title" == "Visit to Africa Centre for Holistic Management (2)" ]; then
    replace_languages_provided $post_id en
  elif [ "$post_title" == "Visit to Africa Centre for Holistic Management (3)" ]; then
    replace_languages_provided $post_id en
  elif [ "$post_title" == "Visit to Africa Centre for Holistic Management (4)" ]; then
    replace_languages_provided $post_id en
  else
    replace_languages_provided $post_id ja
  fi

  debug_languages_provided $post_id "最初の replace_languages_provided 実行後"

  ###
  ### 英語版コンテンツのマイグレーション
  ###

  # "ソニーの「社会課題と技術」特集に対談掲載"の英訳と思われる投稿を英語版に紐づける
  target_post_id=2707
  target_slug="interview-featured-in-sonys-social-issues-and-technologies-special-edition"
  target_lang="en"
  if [ $post_id == $target_post_id ]; then
    _post_ids=$(wp post list --post_type="$post_type" --name="$target_slug" --format=ids)
    for _post_id in $_post_ids; do
      # 翻訳版のコンテンツを取得
      tr_post_title=$(wp post get $_post_id --field=post_title)
      tr_post_content=$(wp post get $_post_id --field=post_content)

      # 現在のループの投稿IDの翻訳版を取得
      tr_post_id=$(wp eval "echo pll_get_post('$post_id', '$target_lang');")
      echo "tr_post_id: $tr_post_id"

      if [ -n "$tr_post_id" ]; then
        # 現在のループの投稿IDの翻訳版投稿を更新
        wp post update $tr_post_id --post_type="$post_type" --post_title="$tr_post_title" --post_content="$tr_post_content"

        # 提供言語にこの言語を追加
        add_languages_provided $post_id $target_lang

        break
      fi
    done

    # 翻訳版の投稿を削除
    wp post delete $(wp post list --post_type="$post_type" --name="$target_slug" --format=ids) --force

    debug_languages_provided $post_id "set_tr_post ($target_post_id, $target_lang) 実行後"
  fi

  # "協生農法・拡張生態系に関わる人々の越境と社会普及のためのフレームワークについて"の英訳と思われる投稿を英語版に紐づける
  target_post_id=3364
  target_slug="a-framework-for-collaboration-across-borders-and-sharing-with-society"
  target_lang="en"
  if [ $post_id == $target_post_id ]; then
    _post_ids=$(wp post list --post_type="$post_type" --name="$target_slug" --format=ids)
    for _post_id in $_post_ids; do
      # 翻訳版のコンテンツを取得
      tr_post_title=$(wp post get $_post_id --field=post_title)
      tr_post_content=$(wp post get $_post_id --field=post_content)

      # 現在のループの投稿IDの翻訳版を取得
      tr_post_id=$(wp eval "echo pll_get_post('$post_id', '$target_lang');")
      echo "tr_post_id: $tr_post_id"

      if [ -n "$tr_post_id" ]; then
        # 現在のループの投稿IDの翻訳版投稿を更新
        wp post update $tr_post_id --post_type="$post_type" --post_title="$tr_post_title" --post_content="$tr_post_content"

        # 提供言語にこの言語を追加
        add_languages_provided $post_id $target_lang

        break
      fi
    done

    # 翻訳版の投稿を削除
    wp post delete $(wp post list --post_type="$post_type" --name="$target_slug" --format=ids) --force

    debug_languages_provided $post_id "set_tr_post ($target_post_id, $target_lang) 実行後"
  fi

  # "表土とウイルス"の英訳と思われる投稿を英語版に紐づける
  target_post_id=2640
  target_slug="topsoil-and-viruses"
  target_lang="en"
  if [ $post_id == $target_post_id ]; then
    _post_ids=$(wp post list --post_type="$post_type" --name="$target_slug" --format=ids)
    for _post_id in $_post_ids; do
      # 翻訳版のコンテンツを取得
      tr_post_title=$(wp post get $_post_id --field=post_title)
      tr_post_content=$(wp post get $_post_id --field=post_content)

      # 現在のループの投稿IDの翻訳版を取得
      tr_post_id=$(wp eval "echo pll_get_post('$post_id', '$target_lang');")
      echo "tr_post_id: $tr_post_id"

      if [ -n "$tr_post_id" ]; then
        # 現在のループの投稿IDの翻訳版投稿を更新
        wp post update $tr_post_id --post_type="$post_type" --post_title="$tr_post_title" --post_content="$tr_post_content"

        # 提供言語にこの言語を追加
        add_languages_provided $post_id $target_lang

        break
      fi
    done

    # 翻訳版の投稿を削除
    wp post delete $(wp post list --post_type="$post_type" --name="$target_slug" --format=ids) --force

    debug_languages_provided $post_id "set_tr_post ($target_post_id, $target_lang) 実行後"
  fi

  ###
  ### フランス語版コンテンツのマイグレーション
  ###

  # "表土とウイルス"のフランス語訳と思われる投稿をフランス語版に紐づける
  target_post_id=2640
  target_slug="terre-arable-et-virus"
  target_lang="fr"
  if [ $post_id == $target_post_id ]; then
    _post_ids=$(wp post list --post_type="$post_type" --name="$target_slug" --format=ids)
    for _post_id in $_post_ids; do
      # 翻訳版のコンテンツを取得
      tr_post_title=$(wp post get $_post_id --field=post_title)
      tr_post_content=$(wp post get $_post_id --field=post_content)

      # 現在のループの投稿IDの翻訳版を取得
      tr_post_id=$(wp eval "echo pll_get_post('$post_id', '$target_lang');")
      echo "tr_post_id: $tr_post_id"

      if [ -n "$tr_post_id" ]; then
        # 現在のループの投稿IDの翻訳版投稿を更新
        wp post update $tr_post_id --post_type="$post_type" --post_title="$tr_post_title" --post_content="$tr_post_content"

        # 提供言語にこの言語を追加
        add_languages_provided $post_id $target_lang

        break
      fi
    done

    # 翻訳版の投稿を削除
    wp post delete $(wp post list --post_type="$post_type" --name="$target_slug" --format=ids) --force

    debug_languages_provided $post_id "set_tr_post ($target_post_id, $target_lang) 実行後"
  fi

  ###
  ### 中国語版コンテンツのマイグレーション
  ###

  # "表土とウイルス"の中国語訳と思われる投稿を中国語版に紐づける
  target_post_id=2640
  target_slug="post-2695"
  target_lang="zh"
  if [ $post_id == $target_post_id ]; then
    _post_ids=$(wp post list --post_type="$post_type" --name="$target_slug" --format=ids)
    for _post_id in $_post_ids; do
      # 翻訳版のコンテンツを取得
      tr_post_title=$(wp post get $_post_id --field=post_title)
      tr_post_content=$(wp post get $_post_id --field=post_content)

      # 現在のループの投稿IDの翻訳版を取得
      tr_post_id=$(wp eval "echo pll_get_post('$post_id', '$target_lang');")
      echo "tr_post_id: $tr_post_id"

      if [ -n "$tr_post_id" ]; then
        # 現在のループの投稿IDの翻訳版投稿を更新
        wp post update $tr_post_id --post_type="$post_type" --post_title="$tr_post_title" --post_content="$tr_post_content"

        # 提供言語にこの言語を追加
        add_languages_provided $post_id $target_lang

        break
      fi
    done

    # 翻訳版の投稿を削除
    wp post delete $(wp post list --post_type="$post_type" --name="$target_slug" --format=ids) --force

    debug_languages_provided $post_id "set_tr_post ($target_post_id, $target_lang) 実行後"
  fi

  # "論文「人間による生態系の拡張：食料生産と科学の2045年目標」邦訳"の中国語訳と思われる投稿を中国語版に紐づける
  target_post_id=781
  target_slug="post-817"
  target_lang="zh"
  if [ $post_id == $target_post_id ]; then
    _post_ids=$(wp post list --post_type="$post_type" --name="$target_slug" --format=ids)
    for _post_id in $_post_ids; do
      # 翻訳版のコンテンツを取得
      tr_post_title=$(wp post get $_post_id --field=post_title)
      tr_post_content=$(wp post get $_post_id --field=post_content)

      # 現在のループの投稿IDの翻訳版を取得
      tr_post_id=$(wp eval "echo pll_get_post('$post_id', '$target_lang');")
      echo "tr_post_id: $tr_post_id"

      if [ -n "$tr_post_id" ]; then
        # 現在のループの投稿IDの翻訳版投稿を更新
        wp post update $tr_post_id --post_type="$post_type" --post_title="$tr_post_title" --post_content="$tr_post_content"

        # 提供言語にこの言語を追加
        add_languages_provided $post_id $target_lang

        break
      fi
    done

    # 翻訳版の投稿を削除
    wp post delete $(wp post list --post_type="$post_type" --name="$target_slug" --format=ids) --force

    debug_languages_provided $post_id "set_tr_post ($target_post_id, $target_lang) 実行後"
  fi

  # wp eval "
  #   \$languages_provided = get_post_meta($post_id, '_wpf_languages_provided');
  #   delete_post_meta($tr_post_id, '_wpf_languages_provided');
  #   \$result = add_post_meta($tr_post_id, '_wpf_languages_provided', \$languages_provided[0], true);
  #   echo \$result ? 'success' : 'failed';
  # "

  ###
  ### 最終状態を確認
  ###
  debug_languages_provided $post_id "最終状態"

  echo ""
  echo "=========================================="
  echo "投稿 $post_id の処理完了"
  echo "=========================================="
  echo ""
done
