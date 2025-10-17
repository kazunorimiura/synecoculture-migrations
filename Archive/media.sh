#!/bin/bash

# WordPressメディア再登録スクリプト
# uploadsディレクトリ内のファイルをwp media importで再登録します

# 設定
UPLOADS_DIR="/srv/www/synecoculture/public_html/wp-content/uploads"  # uploadsディレクトリのパス
LOG_FILE="/srv/www/synecoculture/migrations/media_import_$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="/srv/www/synecoculture/migrations/media_import_errors_$(date +%Y%m%d_%H%M%S).log"

# 色付きの出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# カウンター
SUCCESS_COUNT=0
ERROR_COUNT=0
SKIP_COUNT=0
TOTAL_COUNT=0

# 対象とする画像拡張子
IMAGE_EXTENSIONS=("jpg" "jpeg" "png" "gif" "webp" "svg" "bmp" "ico")

# ログ関数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE" "$ERROR_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

# WP-CLIがインストールされているか確認
check_wp_cli() {
    if ! command -v wp &> /dev/null; then
        log_error "WP-CLIがインストールされていません。"
        log_error "インストール方法: https://wp-cli.org/ja/"
        exit 1
    fi
    log_info "WP-CLI: $(wp --version)"
}

# uploadsディレクトリの存在確認
check_uploads_dir() {
    if [ ! -d "$UPLOADS_DIR" ]; then
        log_error "uploadsディレクトリが見つかりません: $UPLOADS_DIR"
        exit 1
    fi
    log_info "uploadsディレクトリ: $UPLOADS_DIR"
}

# 拡張子が対象かチェック
is_valid_extension() {
    local file="$1"
    local ext="${file##*.}"
    ext=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    for valid_ext in "${IMAGE_EXTENSIONS[@]}"; do
        if [ "$ext" = "$valid_ext" ]; then
            return 0
        fi
    done
    return 1
}

# メディアのインポート
import_media() {
    local file="$1"
    local relative_path="${file#$UPLOADS_DIR/}"

    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    # 拡張子チェック
    if ! is_valid_extension "$file"; then
        log_warning "スキップ (対象外の拡張子): $relative_path"
        SKIP_COUNT=$((SKIP_COUNT + 1))
        return
    fi

    # サムネイルやリサイズ版をスキップ（-150x150, -300x200 など）
    if [[ "$file" =~ -[0-9]+x[0-9]+\.(jpg|jpeg|png|gif|webp)$ ]]; then
        log_warning "スキップ (サムネイル): $relative_path"
        SKIP_COUNT=$((SKIP_COUNT + 1))
        return
    fi

    log_info "インポート中: $relative_path"

    # wp media importコマンドの実行
    # --skip-copy: ファイルを移動せずそのまま使用
    # --porcelain: 結果をID形式で返す
    if result=$(wp media import "$file" --skip-copy --porcelain 2>&1); then
        log_info "✓ 成功: $relative_path (ID: $result)"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        # 既に存在する場合のエラーは警告として扱う
        if echo "$result" | grep -q "already exists"; then
            log_warning "既に存在: $relative_path"
            SKIP_COUNT=$((SKIP_COUNT + 1))
        else
            log_error "✗ 失敗: $relative_path"
            log_error "  理由: $result"
            ERROR_COUNT=$((ERROR_COUNT + 1))
        fi
    fi
}

# メイン処理
main() {
    log_info "=========================================="
    log_info "WordPressメディア再登録スクリプト 開始"
    log_info "=========================================="
    log_info "開始時刻: $(date '+%Y-%m-%d %H:%M:%S')"

    # 事前チェック
    check_wp_cli
    check_uploads_dir

    log_info ""
    log_info "ファイルを検索中..."

    # uploadsディレクトリ内のすべてのファイルを処理
    while IFS= read -r -d '' file; do
        import_media "$file"
    done < <(find "$UPLOADS_DIR" -type f -print0)

    # 結果サマリー
    log_info ""
    log_info "=========================================="
    log_info "処理完了"
    log_info "=========================================="
    log_info "総ファイル数: $TOTAL_COUNT"
    log_info "成功: ${GREEN}$SUCCESS_COUNT${NC}"
    log_info "スキップ: ${YELLOW}$SKIP_COUNT${NC}"
    log_info "エラー: ${RED}$ERROR_COUNT${NC}"
    log_info "終了時刻: $(date '+%Y-%m-%d %H:%M:%S')"
    log_info ""
    log_info "ログファイル: $LOG_FILE"

    if [ $ERROR_COUNT -gt 0 ]; then
        log_info "エラーログ: $ERROR_LOG"
    fi
}

# スクリプト実行
main
