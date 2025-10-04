#!/bin/bash

###
### タイトルマッピングファイルのCSVをもとに、コンテンツファイル（.txt）を作成する
### なお、txtファイルの内容は「※準備中」で作成される
###

# ./migrations/utils/create_content_files.sh <CSV_FILE> <OUTPUT_DIR>
# ./migrations/utils/create_content_files.sh ./migrations/members/content_files/title_mapping.csv ./migrations/members/content_files
# ./migrations/utils/create_content_files.sh ./migrations/page_migrations/content_files/title_mapping.csv ./migrations/page_migrations/content_files "home,news,privacy-policy"
# ./migrations/utils/create_content_files.sh ./migrations/projects/content_files/title_mapping.csv ./migrations/projects/content_files
# ./migrations/utils/create_content_files.sh ./migrations/case_studies/content_files/title_mapping.csv ./migrations/case_studies/content_files


# 使用方法を表示する関数
show_usage() {
    echo "使用方法: $0 [CSVファイル] [出力ディレクトリ]"
    echo ""
    echo "引数:"
    echo "  CSVファイル      : 処理対象のCSVファイル（デフォルト: data.csv）"
    echo "  出力ディレクトリ  : txtファイルの出力先（デフォルト: 現在のディレクトリ）"
    echo ""
    echo "例:"
    echo "  $0                           # data.csvを読み込み、現在のディレクトリに出力"
    echo "  $0 mydata.csv                # mydata.csvを読み込み、現在のディレクトリに出力"
    echo "  $0 data.csv ./output         # data.csvを読み込み、outputディレクトリに出力"
    echo "  $0 mydata.csv /path/to/dir   # mydata.csvを読み込み、指定ディレクトリに出力"
}

# ヘルプオプションのチェック
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# CSVファイル名（コマンドライン引数またはデフォルト）
CSV_FILE="${1:-data.csv}"

# 出力ディレクトリ（コマンドライン引数または現在のディレクトリ）
OUTPUT_DIR="${2:-.}"

# スキップするpost_slugのリスト（第三引数）
SKIP_SLUGS="$3"

# CSVファイルが存在するかチェック
if [[ ! -f "$CSV_FILE" ]]; then
    echo "エラー: CSVファイル '$CSV_FILE' が見つかりません。"
    show_usage
    exit 1
fi

# 出力ディレクトリを作成（存在しない場合）
if [[ ! -d "$OUTPUT_DIR" ]]; then
    echo "出力ディレクトリ '$OUTPUT_DIR' を作成します..."
    mkdir -p "$OUTPUT_DIR"
    if [[ $? -ne 0 ]]; then
        echo "エラー: 出力ディレクトリ '$OUTPUT_DIR' を作成できませんでした。"
        exit 1
    fi
fi

# スキップするpost_slugを連想配列に格納
declare -A skip_array
if [[ -n "$SKIP_SLUGS" ]]; then
    IFS=',' read -ra SKIP_LIST <<< "$SKIP_SLUGS"
    for slug in "${SKIP_LIST[@]}"; do
        # 前後の空白を削除
        slug=$(echo "$slug" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        skip_array["$slug"]=1
    done
    echo "スキップするpost_slug: ${SKIP_LIST[*]}"
fi

# 言語ごとの「※準備中」の翻訳を定義
declare -A translations
translations["ja"]="※準備中"
translations["en"]="※Under preparation"
translations["fr"]="※En préparation"
translations["zh"]="※准备中"

echo "ファイル生成を開始します..."
echo "CSVファイル: $CSV_FILE"
echo "出力ディレクトリ: $OUTPUT_DIR"
echo ""

# CSVファイルを読み込み（ヘッダー行をスキップ）
{
    read # ヘッダー行をスキップ
    while IFS=',' read -r post_slug lang_slug title parent_slug; do
        # 空行をスキップ
        if [[ -z "$post_slug" || -z "$lang_slug" ]]; then
            continue
        fi

        # スキップリストにpost_slugが含まれているかチェック
        if [[ -n "${skip_array[$post_slug]}" ]]; then
            echo "スキップしました: $post_slug (言語: $lang_slug)"
            continue
        fi

        # ファイル名を生成（出力ディレクトリを含む）
        filename="$OUTPUT_DIR/${post_slug}__${lang_slug}.txt"

        # 該当言語の翻訳を取得（デフォルトは日本語）
        translated_text="${translations[$lang_slug]:-${translations["ja"]}}"

        # ファイル内容を生成
        cat > "$filename" << EOF
<!-- wp:paragraph -->
<p>$translated_text</p>
<!-- /wp:paragraph -->
EOF

        echo "作成しました: $filename (言語: $lang_slug, 翻訳: $translated_text)"

    done
} < "$CSV_FILE"

echo ""
echo "すべてのファイルの生成が完了しました。"
echo "出力先: $OUTPUT_DIR"
if [[ -n "$SKIP_SLUGS" ]]; then
    echo "スキップされたpost_slug: $SKIP_SLUGS"
fi
