#!/bin/bash

# ANSIエスケープシーケンス
GREEN='\033[32m'
RED='\033[0;31m'
YELLOW='\033[33m'
NC='\033[0m' # No Color

# 太字のエスケープシーケンス
BOLD=$(tput bold)
REGULAR=$(tput sgr0)

message() {
  local message=$1
  local level=$2

  # 実行ディレクトリ（ルート基準）のパスを取得
  local fullpath=$(realpath "$0")
  # 実行ディレクトリの部分をルートと見なして相対パスを取得
  local relative_path="${fullpath#$(pwd)/}"
  # 相対パスからファイル名を取得
  local dir_name=$(dirname "$relative_path")
  local filename=$(basename "$relative_path")

  # 行番号の取得
  local line_number
  line_number=$(caller 0 | awk '{print $1}')

  if [ -z "$level" ]; then
    # ファイル名と行番号を接頭辞に付けてechoする
    echo "[${dir_name}/${filename}:${line_number}] $message"
  elif [ "$level" == "bold" ]; then
    echo "[${dir_name}/${filename}:${line_number}] ${BOLD}${message}${REGULAR}"
  elif [ "$level" == "success" ]; then
    echo -e "[${dir_name}/${filename}:${line_number}] ${BOLD}${GREEN}Success:${NC}${REGULAR} ${message}"
  elif [ "$level" == "warning" ]; then
    echo -e "[${dir_name}/${filename}:${line_number}] ${BOLD}${YELLOW}Warning:${NC}${REGULAR} ${message}"
  elif [ "$level" == "error" ]; then
    echo -e "[${dir_name}/${filename}:${line_number}] ${BOLD}${RED}Error:${NC}${REGULAR} ${message}"
  fi
}
