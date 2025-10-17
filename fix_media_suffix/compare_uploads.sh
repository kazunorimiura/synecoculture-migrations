#!/bin/bash

# WordPressメディアの差分検出スクリプト
# サフィックスが付いたファイルを特定します

# 使い方: ./migrations/fix_media_suffix/compare_uploads.sh <元のuploadsディレクトリ> <移植先のuploadsディレクトリ>
# ./migrations/fix_media_suffix/compare_uploads.sh /srv/www/synecoculture/public_html/wp-content/uploads_old /srv/www/synecoculture/public_html/wp-content/uploads


# 引数チェック
if [ $# -ne 2 ]; then
    echo "使い方: $0 <元のuploadsディレクトリ> <移植先のuploadsディレクトリ>"
    echo "例: $0 /path/to/old/uploads /path/to/new/uploads"
    exit 1
fi

OLD_DIR="$1"
NEW_DIR="$2"

# ディレクトリの存在確認
if [ ! -d "$OLD_DIR" ]; then
    echo "エラー: 元のディレクトリが存在しません: $OLD_DIR"
    exit 1
fi

if [ ! -d "$NEW_DIR" ]; then
    echo "エラー: 移植先のディレクトリが存在しません: $NEW_DIR"
    exit 1
fi

echo "=== WordPressメディア差分検出 ==="
echo "元のディレクトリ: $OLD_DIR"
echo "移植先のディレクトリ: $NEW_DIR"
echo ""

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 一時ファイルとレポートファイル
TEMP_SUFFIX_FILES="/tmp/wp_suffix_files_$.txt"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
TEMP_REPORT="${SCRIPT_DIR}/log/wp_report_${TIMESTAMP}.txt"
CSV_FILE="${SCRIPT_DIR}/wp_suffix_report.csv"

# レポートファイルの初期化
> "$TEMP_REPORT"

echo "サフィックスが付いたファイルを検索中..."
echo ""

# 新しいディレクトリでサフィックス付きファイルを検出
# find "$NEW_DIR" -type f | grep -E '\-[0-9]+\.(jpg|jpeg|png|gif|pdf|svg|webp|mp4|mov|avi|doc|docx|zip)$' > "$TEMP_SUFFIX_FILES"
find "$NEW_DIR" -type f | grep -E '\-[0-9]+\.[^.]+$' > "$TEMP_SUFFIX_FILES"

SUFFIX_COUNT=$(wc -l < "$TEMP_SUFFIX_FILES")

if [ "$SUFFIX_COUNT" -eq 0 ]; then
    echo "サフィックスが付いたファイルは見つかりませんでした。"
    rm -f "$TEMP_SUFFIX_FILES" "$TEMP_REPORT"
    exit 0
fi

echo "サフィックスが付いたファイル: ${SUFFIX_COUNT}件"
echo ""
echo "=== 詳細レポート ===" | tee -a "$TEMP_REPORT"
echo "" | tee -a "$TEMP_REPORT"

# 各サフィックス付きファイルについて分析
while IFS= read -r new_file; do
    # 相対パスを取得
    rel_path="${new_file#$NEW_DIR/}"

    # ファイル名からサフィックスを除去して元のファイル名を推測
    # 例: image-1.jpg → image.jpg
    base_name=$(basename "$new_file")
    dir_name=$(dirname "$rel_path")

    # サフィックスパターン: -数字.拡張子
    original_name=$(echo "$base_name" | sed -E 's/-[0-9]+(\.[^.]+)$/\1/')

    # 元のファイルのパスを構築
    if [ "$dir_name" = "." ]; then
        original_path="$OLD_DIR/$original_name"
    else
        original_path="$OLD_DIR/$dir_name/$original_name"
    fi

    echo "---" | tee -a "$TEMP_REPORT"
    echo "新しいファイル: $rel_path" | tee -a "$TEMP_REPORT"
    echo "推測される元のファイル: $dir_name/$original_name" | tee -a "$TEMP_REPORT"

    # 元のファイルが存在するかチェック
    if [ -f "$original_path" ]; then
        echo "ステータス: ✓ 元のファイルが存在します" | tee -a "$TEMP_REPORT"

        # ファイルサイズを比較
        old_size=$(stat -f%z "$original_path" 2>/dev/null || stat -c%s "$original_path" 2>/dev/null)
        new_size=$(stat -f%z "$new_file" 2>/dev/null || stat -c%s "$new_file" 2>/dev/null)

        if [ "$old_size" = "$new_size" ]; then
            echo "ファイルサイズ: 同一 (${old_size} bytes)" | tee -a "$TEMP_REPORT"
        else
            echo "ファイルサイズ: 異なる (元: ${old_size} bytes, 新: ${new_size} bytes)" | tee -a "$TEMP_REPORT"
        fi
    else
        echo "ステータス: ✗ 元のファイルが見つかりません" | tee -a "$TEMP_REPORT"
    fi

    echo "" | tee -a "$TEMP_REPORT"
done < "$TEMP_SUFFIX_FILES"

echo "=== サマリー ===" | tee -a "$TEMP_REPORT"
echo "サフィックス付きファイル総数: ${SUFFIX_COUNT}件" | tee -a "$TEMP_REPORT"
echo "" | tee -a "$TEMP_REPORT"
echo "詳細レポートは以下に保存されました:" | tee -a "$TEMP_REPORT"
echo "  テキストレポート: $TEMP_REPORT"
echo "  CSVレポート: $CSV_FILE"

# CSVファイルも生成
echo "新しいファイル,推測される元のファイル,元のファイル存在" > "$CSV_FILE"

while IFS= read -r new_file; do
    rel_path="${new_file#$NEW_DIR/}"
    base_name=$(basename "$new_file")
    dir_name=$(dirname "$rel_path")
    original_name=$(echo "$base_name" | sed -E 's/-[0-9]+(\.[^.]+)$/\1/')

    if [ "$dir_name" = "." ]; then
        original_path="$OLD_DIR/$original_name"
        original_rel="$original_name"
    else
        original_path="$OLD_DIR/$dir_name/$original_name"
        original_rel="$dir_name/$original_name"
    fi

    if [ -f "$original_path" ]; then
        exists="Yes"
    else
        exists="No"
    fi

    echo "\"$rel_path\",\"$original_rel\",\"$exists\"" >> "$CSV_FILE"
done < "$TEMP_SUFFIX_FILES"

# クリーンアップ
rm -f "$TEMP_SUFFIX_FILES"

echo ""
echo "完了!"
