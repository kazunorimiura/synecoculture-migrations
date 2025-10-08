<?php
/**
 * Polylangの文字列翻訳を設定する
 * wp eval-fileコマンドで実行可能
 *
 * 使用方法:
 * wp eval-file ./migrations/polylang/update-string-translation.php
 */

// 事前条件: Polylang(Pro) が有効化済み
if ( ! function_exists('PLL') ) {
    WP_CLI::error('Polylang が読み込まれていません。プラグインを有効化してください。');
}

// 各言語に対して翻訳を設定
foreach ( PLL()->model->get_languages_list() as $language ) {
    $mo = new PLL_MO();
    $mo->import_from_db( $language );

    // 翻訳の追加
    if ( $language->slug === 'en' ) {
        $mo->add_entry( $mo->make_entry( '一般社団法人シネコカルチャー', 'Synecoculture Association' ) );
        $mo->add_entry( $mo->make_entry( '協生農法は株式会社桜自然塾の商標または登録商標です。', 'Kyosei Noho is a trademark or registered trademark of Sakura Shizenjuku Co., Ltd.' ) );
        $mo->add_entry( $mo->make_entry( 'Synecocultureはソニーグループ株式会社の商標です。', 'Synecoculture is a trademark of Sony Group Corporation.' ) );
        $mo->add_entry( $mo->make_entry( 'Y年n月j日', 'F j, Y' ) );
    } elseif ( $language->slug === 'fr' ) {
        $mo->add_entry( $mo->make_entry( '一般社団法人シネコカルチャー', 'Synecoculture Association' ) );
        $mo->add_entry( $mo->make_entry( '協生農法は株式会社桜自然塾の商標または登録商標です。', 'Kyosei Noho est une marque commerciale ou une marque déposée de Sakura Shizenjuku Co., Ltd.' ) );
        $mo->add_entry( $mo->make_entry( 'Synecocultureはソニーグループ株式会社の商標です。', 'Synecoculture est une marque commerciale de Sony Group Corporation.' ) );
        $mo->add_entry( $mo->make_entry( 'Y年n月j日', 'j F Y' ) );
    } elseif ( $language->slug === 'zh' ) {
        $mo->add_entry( $mo->make_entry( '一般社団法人シネコカルチャー', 'Synecoculture协会' ) );
        $mo->add_entry( $mo->make_entry( '協生農法は株式会社桜自然塾の商標または登録商標です。', '协生农法是樱自然塾株式会社的商标或注册商标。' ) );
        $mo->add_entry( $mo->make_entry( 'Synecocultureはソニーグループ株式会社の商標です。', 'Synecoculture是索尼集团公司的商标。' ) );
        $mo->add_entry( $mo->make_entry( 'Y年n月j日', 'Y年n月j日' ) );
    }

    // データベースに保存
    $mo->export_to_db( $language );
}
