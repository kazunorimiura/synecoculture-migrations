# =============================================================================
# ファイル名: wp-media-lib.sh
# 説明: WordPress多言語メディア処理ライブラリ
# =============================================================================

WP_UPLOADS_DIR="http://synecoculture.test/wp-content/uploads"
WP_NEW_UPLOADS_DATE_DIR="2025/10"

# WordPress多言語メディア処理関数
# 引数:
#   $1: FILENAME (必須) - 処理対象のファイル名
#   $2: MEDIA_PATH (オプション) - メディアファイルのパス
#   $3: --import-media (オプション) - インポートフラグ
# 戻り値:
#   標準出力に "言語:ID" 形式で出力
function get_multilingual_media_ids() {
    local FILENAME="$1"
    local MEDIA_PATH="$2"
    local IMPORT_MEDIA="$3"

    # 必須引数チェック
    if [ -z "$FILENAME" ]; then
        echo "エラー: FILENAMEは必須引数です" >&2
        return 1
    fi

    # グローバル変数をクリア
    unset img_id img_id__en img_id__fr img_id__zh

    if [ "$IMPORT_MEDIA" == "--import-media" ]; then
        # メディアパスが指定されていない場合はエラー
        if [ -z "$MEDIA_PATH" ]; then
            echo "エラー: --import-media使用時はMEDIA_PATHが必要です" >&2
            return 1
        fi

        # メディアをインポートして各言語の翻訳を作成
        img_id=$(wp media import "$MEDIA_PATH/${FILENAME}" --porcelain)
        if [ $? -ne 0 ] || [ -z "$img_id" ]; then
            echo "エラー: メディアのインポートに失敗しました" >&2
            return 1
        fi

        img_id__en=$(wp eval "echo PLL()->model->post->create_media_translation( $img_id, 'en' ); PLL()->model->clean_languages_cache();")
        img_id__fr=$(wp eval "echo PLL()->model->post->create_media_translation( $img_id, 'fr' ); PLL()->model->clean_languages_cache();")
        img_id__zh=$(wp eval "echo PLL()->model->post->create_media_translation( $img_id, 'zh' ); PLL()->model->clean_languages_cache();")
    else
        # 既存ファイルから取得
        img_id=$(wp eval "echo attachment_url_to_postid( '${WP_UPLOADS_DIR}/${WP_NEW_UPLOADS_DATE_DIR}/${FILENAME}' );")
        if [ -z "$img_id" ] || [ "$img_id" == "0" ]; then
            echo "エラー: 指定されたファイルのメディアIDが見つかりません" >&2
            return 1
        fi

        img_id__en=$(wp eval "echo pll_get_post('$img_id', 'en');")
        img_id__fr=$(wp eval "echo pll_get_post('$img_id', 'fr');")
        img_id__zh=$(wp eval "echo pll_get_post('$img_id', 'zh');")
    fi

    # 結果を標準出力に出力（連想配列形式）
    echo "default:$img_id"
    echo "en:$img_id__en"
    echo "fr:$img_id__fr"
    echo "zh:$img_id__zh"

    return 0
}

# 結果を連想配列として取得するヘルパー関数
# 引数:
#   $1: get_multilingual_media_ids関数の出力結果
# グローバル変数:
#   media_ids - 連想配列として結果を格納
function parse_media_ids() {
    local result="$1"
    declare -gA media_ids

    while IFS= read -r line; do
        if [[ $line =~ ^([^:]+):(.+)$ ]]; then
            media_ids["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
        fi
    done <<< "$result"
}

# ライブラリが正常に読み込まれたことを示すメッセージ（オプション）
echo "wp-media-lib.sh が読み込まれました" >&2
