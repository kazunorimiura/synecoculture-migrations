<?php
if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}

$opt = PLL()->options;

// 有効化フラグ（GUIの「Media」を有効にするのと同等）
$e1 = $opt->set('media_support', 1);

// オプション: アップロード時に全言語へ自動複製
$e2 = $opt->set('media', ['duplicate' => 0]);

foreach ([['media_support',$e1], ['media',$e2]] as [$k,$err]) {
    if ($err instanceof WP_Error && $err->has_errors()) {
        foreach ($err->errors as $code=>$msgs) {
            foreach ($msgs as $m) { fwrite(STDERR, "ERROR {$k} {$code}: {$m}\n"); }
        }
        WP_CLI::error('メディア設定の保存に失敗しました。');
    }
}

$dup = (int) (($opt->get('media')['duplicate'] ?? 0) ? 1 : 0);
echo "OK: media_support=1, duplicate={$dup} に設定しました。\n";
