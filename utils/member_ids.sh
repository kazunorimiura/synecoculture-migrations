#!/bin/bash

###
### メンバーIDを取得
###

masatoshi_funabashi_ids=$(wp post list --post_type=member --name="masatoshi-funabashi" --field=ID --format=ids)
masatoshi_funabashi=""
if [ -n "$masatoshi_funabashi_ids" ]; then
  for id in ${masatoshi_funabashi_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      masatoshi_funabashi=$id
      echo "日本語のfoo投稿を発見 (masatoshi_funabashi): ID=$masatoshi_funabashi"
      break
    fi
  done
fi

godai_suzuki_ids=$(wp post list --post_type=member --name="godai-suzuki" --field=ID --format=ids)
godai_suzuki=""
if [ -n "$godai_suzuki_ids" ]; then
  for id in ${godai_suzuki_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      godai_suzuki=$id
      echo "日本語のfoo投稿を発見 (godai_suzuki): ID=$godai_suzuki"
      break
    fi
  done
fi

tatsuya_kawaoka_ids=$(wp post list --post_type=member --name="tatsuya-kawaoka" --field=ID --format=ids)
tatsuya_kawaoka=""
if [ -n "$tatsuya_kawaoka_ids" ]; then
  for id in ${tatsuya_kawaoka_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      tatsuya_kawaoka=$id
      echo "日本語のfoo投稿を発見 (tatsuya_kawaoka): ID=$tatsuya_kawaoka"
      break
    fi
  done
fi

kousaku_ohta_ids=$(wp post list --post_type=member --name="kousaku-ohta" --field=ID --format=ids)
kousaku_ohta=""
if [ -n "$kousaku_ohta_ids" ]; then
  for id in ${kousaku_ohta_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      kousaku_ohta=$id
      echo "日本語のfoo投稿を発見 (kousaku_ohta): ID=$kousaku_ohta"
      break
    fi
  done
fi

ryota_sakayama_ids=$(wp post list --post_type=member --name="ryota-sakayama" --field=ID --format=ids)
ryota_sakayama=""
if [ -n "$ryota_sakayama_ids" ]; then
  for id in ${ryota_sakayama_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      ryota_sakayama=$id
      echo "日本語のfoo投稿を発見 (ryota_sakayama): ID=$ryota_sakayama"
      break
    fi
  done
fi

shinnosuke_yoshikawa_ids=$(wp post list --post_type=member --name="shinnosuke-yoshikawa" --field=ID --format=ids)
shinnosuke_yoshikawa=""
if [ -n "$shinnosuke_yoshikawa_ids" ]; then
  for id in ${shinnosuke_yoshikawa_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      shinnosuke_yoshikawa=$id
      echo "日本語のfoo投稿を発見 (shinnosuke_yoshikawa): ID=$shinnosuke_yoshikawa"
      break
    fi
  done
fi

yoko_honjo_ids=$(wp post list --post_type=member --name="yoko-honjo" --field=ID --format=ids)
yoko_honjo=""
if [ -n "$yoko_honjo_ids" ]; then
  for id in ${yoko_honjo_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      yoko_honjo=$id
      echo "日本語のfoo投稿を発見 (yoko_honjo): ID=$yoko_honjo"
      break
    fi
  done
fi

kei_fukuda_ids=$(wp post list --post_type=member --name="kei-fukuda" --field=ID --format=ids)
kei_fukuda=""
if [ -n "$kei_fukuda_ids" ]; then
  for id in ${kei_fukuda_ids//,/ }; do
    lang=$(wp eval "echo pll_get_post_language('$id', 'slug');")
    if [ "$lang" = "ja" ]; then
      kei_fukuda=$id
      echo "日本語のfoo投稿を発見 (kei_fukuda): ID=$kei_fukuda"
      break
    fi
  done
fi


export masatoshi_funabashi
export godai_suzuki
export tatsuya_kawaoka
export ryota_sakayama
export kousaku_ohta
export shinnosuke_yoshikawa
export yoko_honjo
export kei_fukuda
