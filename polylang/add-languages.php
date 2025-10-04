<?php
if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}
$pll = PLL();
$languages = $pll->model->languages;

/**
 * ヘルパー: 指定言語が存在しなければ追加
 */
$ensure_lang = function(array $args) use ($languages) {
    $slug = $args['slug'];
    if ( $languages->get($slug) ) {
        echo "SKIP: {$slug} は既に存在します\n";
        return true;
    }
    $r = $languages->add($args);
    if ( is_wp_error($r) && $r->has_errors() ) {
        foreach ($r->errors as $code=>$msgs){
            foreach($msgs as $m){
                fwrite(STDERR, "ERROR {$slug} {$code}: {$m}\n");
            }
        }
        return false;
    }
    echo "ADD : {$slug} を追加しました\n";
    return true;
};

/* 1) 日本語（デフォルトにする） */
$ok  = $ensure_lang([
  'name'       => '日本語',
  'slug'       => 'ja',
  'locale'     => 'ja',
  'rtl'        => false,
  'term_group' => 0,
  'flag'       => 'jp',
]);

/* 2) 英語 (US) */
$ok &= $ensure_lang([
  'name'       => 'English',
  'slug'       => 'en',
  'locale'     => 'en_US',
  'rtl'        => false,
  'term_group' => 1,
  'flag'       => 'us',
]);

/* 3) フランス語 */
$ok &= $ensure_lang([
  'name'       => 'Français',
  'slug'       => 'fr',
  'locale'     => 'fr_FR',
  'rtl'        => false,
  'term_group' => 2,
  'flag'       => 'fr',
]);

/* 4) 中国語（簡体） */
$ok &= $ensure_lang([
  'name'       => '简体中文',
  'slug'       => 'zh',
  'locale'     => 'zh_CN',
  'rtl'        => false,
  'term_group' => 3,
  'flag'       => 'cn',
]);

if ( ! $ok ) {
    WP_CLI::error('言語追加でエラーが発生しました。');
}

/* 5) デフォルト言語を ja に設定 */
$err = $languages->update_default('ja');
if ( $err instanceof WP_Error && $err->has_errors() ) {
    WP_CLI::error('既定言語の更新に失敗しました。');
}
echo "OK: デフォルト言語を ja に設定しました。\n";

/* 6) 確認出力 */
$slugs = $languages->get_list(['fields'=>'slug']);
echo "LIST: 現在の言語 -> " . implode(', ', $slugs) . "\n";
$def = $languages->get_default();
echo "DEF : 既定言語   -> " . ($def ? $def->slug : 'none') . "\n";
