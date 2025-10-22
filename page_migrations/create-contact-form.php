<?php
/**
 * MW WP Form問い合わせフォーム新規作成スクリプト
 * wp eval-fileコマンドで実行可能
 *
 * 使用方法:
 * wp eval-file ./migrations/page_migrations/create-contact-form.php
 */

// MW WP Formプラグインが有効かチェック
if (!class_exists('MW_WP_Form')) {
    WP_CLI::error('MW WP Formプラグインが有効化されていません。');
    return;
}

/**
 * 日本語版（デフォルト言語）の問い合わせフォームおよび固定ページを作成
 */

WP_CLI::log("\n=== 日本語版（デフォルト言語）の問い合わせフォームおよび固定ページを作成 ===");

// フォーム設定データ
$form_title = 'お問い合わせフォーム';

// フォームコンテンツ
$form_content = '<div class="prose">
    [mwform_akismet_error]
    [mwform_error keys="recaptcha-v3"]
[mwform_radio name="gfgdsgf" id="gfdsgf" vertically="true"]
    <p class="mwform-item">
        <label for="inquiry-type" class="form-label">お問い合わせ種別</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:リサーチャーへの講演依頼,workshop:ナビゲーターへのワークショップ依頼,interview:取材・出演・執筆等、広報に関するお問い合わせ,collabo:共同研究・開発に関するご相談,farm-tour:農園見学のお申し込み,careers:採用に関するお問い合わせ,others:上記以外のお問い合わせ" vertically="true" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p class="mwform-item">
            <label for="last-name" class="form-label">姓</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p class="mwform-item">
            <label for="first-name" class="form-label">名</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p class="mwform-item">
        <label for="company" class="form-label">企業・団体名<span class="label-mark">任意</span></label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p class="mwform-item">
        <label for="email" class="form-label">メールアドレス</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p class="mwform-item">
        <label for="tel" class="form-label">電話番号</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p class="mwform-item">
        <label for="message" class="form-label">お問い合わせ内容</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <div class="embedded-privacy-policy">
        <p class="embedded-privacy-policy__heading">個人情報保護方針</p>
        [wpf_embedded_privacy_policy root_level="4"]
    </div>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">取得した個人情報は<a href="/privacy-policy/" target="_blank" rel="noopener">個人情報保護方針</a>に従って取り扱いを行います。</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="個人情報保護方針に同意する" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]内容を確認[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]戻る[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]送信する[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">このフォームはreCAPTCHAによって保護されており、Googleの<a href="https://policies.google.com/privacy" target="_blank" rel="noopener">プライバシーポリシー</a>と<a href="https://policies.google.com/terms" target="_blank" rel="noopener">利用規約</a>が適用されます。</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>お問い合わせありがとうございます。ご入力いただいたメールアドレスに自動返信メールをお送りしました。自動返信メールが届かない場合、迷惑メールフォルダに格納されているか、ご入力のメールアドレスに誤りがある可能性がございます。自動返信メールが見当たらない場合、恐れ入りますが、メールアドレスをご確認の上、再度お問い合わせいただきますよう宜しくお願いいたします。</p>';

// 自動返信メール本文
$automatic_reply_content = '{last-name} {first-name} 様

この度は、' . get_bloginfo('name') . 'へお問い合わせいただきありがとうございます。以下の内容でお問い合わせを承りました。

お問い合わせ種別: {inquiry-type}
姓: {last-name}
名: {first-name}
企業・団体名: {company}
メールアドレス: {email}
電話番号: {tel}
お問い合わせ内容: {message}
個人情報保護方針への同意: {privacy-consent}

--
このメールは ' . get_bloginfo('url') . ' のお問い合わせフォームよりお問い合わせいただいた方に自動返信しています。お心当たりのない場合は、お手数ですが、このメールを破棄してくださいますよう宜しくお願いいたします。';

// 管理者宛メール本文
$admin_mail_content = '以下の内容でお問い合わせがありました。

お問い合わせ種別: {inquiry-type}
姓: {last-name}
名: {first-name}
企業・団体名: {company}
メールアドレス: {email}
電話番号: {tel}
お問い合わせ内容: {message}
個人情報保護方針への同意: {privacy-consent}

--
このメールは ' . get_bloginfo('url') . ' から管理者宛に自動送信されました。';

// フォームの作成
$form_id = wp_insert_post(
	array(
		'post_title'   => $form_title,
		'post_content' => $form_content,
		'post_status'  => 'publish',
		'post_type'    => 'mw-wp-form',
		'post_author'  => 1,
		'meta_input'   => array(
			'mw-wp-form' => array(
				'querystring' => false,
				'usedb' => '0',

				// 自動返信メール設定
				'automatic_reply_email' => 'email',
				'mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせありがとうございます',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => get_bloginfo('name'),
				'mail_reply_to' => get_option('admin_email'),
				'mail_content' => $automatic_reply_content,
				'mail_to' => get_option('admin_email'),
				'mail_cc' => '',
				'mail_bcc' => '',
				'mail_return_path' => get_option('admin_email'),

				// 管理者宛メール設定
				'admin_mail_reply_to' => get_option('admin_email'),
				'admin_mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせがありました',
				'admin_mail_from' => get_option('admin_email'),
				'admin_mail_sender' => get_bloginfo('name'),
				'admin_mail_content' => $admin_mail_content,

				// Akismet設定 ※reCAPTCHAを使うので使用しない
				'akismet_author' => '',
				'akismet_author_email' => '',
				'akismet_author_url' => '',

				// 画面設定
				'complete_message' => $complete_message,
				'input_url' => '/contact/',
				'confirmation_url' => '/contact/confirm/',
				'complete_url' => '/contact/thankyou/',
				'validation_error_url' => '/contact/error/',

				// バリデーション設定 ※テーマで設定済みなので使用しない
				'validation' => array(),

				// その他設定
				'style' => '',
				'scroll' => '0'
			)
		)
	)
);

// デバッグ
if (!is_wp_error($form_id)) {
    WP_CLI::success("フォームを作成しました（ID: " . $form_id . "、タイトル: " . $form_title);
	WP_CLI::log("\n=== 保存された設定の確認 ===");
	$saved_settings = get_post_meta($form_id, 'mw-wp-form', true);
	if ($saved_settings) {
		WP_CLI::log("✓ mw-wp-form メタキーに設定が正常に保存されました");
		WP_CLI::log("- 管理者宛メール送信先: " . $saved_settings['mail_to']);
		WP_CLI::log("- 管理者宛メール件名: " . $saved_settings['mail_subject']);
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['automatic_reply_email']);
		WP_CLI::log("- 自動返信メール件名: " . $saved_settings['admin_mail_subject']);
		WP_CLI::log("- データベース保存: " . ($saved_settings['usedb'] === '1' ? '有効' : '無効'));
	} else {
		WP_CLI::error("設定の保存に失敗しました");
	}

	WP_CLI::log("\n=== フォーム表示方法 ===");
	WP_CLI::log("[mwform_formkey key=\"" . $form_id . "\"]");

	WP_CLI::log("\n=== phpMyAdminで設定を確認する ===");
	WP_CLI::log("SELECT meta_value FROM wp_postmeta WHERE post_id = $form_id AND meta_key = 'mw-wp-form';");
} else {
	WP_CLI::error('フォームの作成に失敗しました: ' . $form_id->get_error_message());
    return;
}

// お問い合わせページの作成
$contact_page_id = wp_insert_post(
	array(
		'post_title'   => 'お問い合わせ',
		'post_name'    => 'contact',
		'post_content' => '<!-- wp:paragraph --><p>以下のフォームに必要事項をご入力の上、送信してください。内容によっては返信に時間がかかる場合や、回答を差し控えさせていただく場合もございます。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $form_id . '"]<!-- /wp:shortcode -->',
		'post_status'  => 'publish',
		'post_type'    => 'page',
		'post_author'  => 1
	)
);

// デバッグ
if (!is_wp_error($contact_page_id)) {
	WP_CLI::success("お問い合わせページを作成しました（ID: " . $contact_page_id . "、URL:" . get_permalink($contact_page_id));
} else {
	WP_CLI::error('お問い合わせページの作成に失敗しました: ' . $contact_page_id->get_error_message());
	return;
}

// 内容確認ページの作成
$comfirm_page_id = wp_insert_post(
	array(
		'post_title'   => '内容を確認',
		'post_name'    => 'confirm',
		'post_parent'    => $contact_page_id,
		'post_content' => '<!-- wp:paragraph --><p>以下の内容で送信します。よろしければ送信ボタンを押して、お問い合わせを完了させてください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $form_id . '"]<!-- /wp:shortcode -->',
		'post_status'  => 'publish',
		'post_type'    => 'page',
		'post_author'  => 1
	)
);

// デバッグ
if (!is_wp_error($comfirm_page_id)) {
	WP_CLI::success("内容確認ページを作成しました（ID: " . $comfirm_page_id . "、URL:" . get_permalink($comfirm_page_id));
} else {
	WP_CLI::error('内容確認ページの作成に失敗しました: ' . $comfirm_page_id->get_error_message());
	return;
}

// サンクスページの作成
$thanks_page_id = wp_insert_post(
	array(
		'post_title'   => 'お問い合わせありがとうございます',
		'post_name'    => 'thankyou',
		'post_parent'    => $contact_page_id,
		'post_content' => '<!-- wp:shortcode -->[mwform_formkey key="' . $form_id . '"]<!-- /wp:shortcode -->',
		'post_status'  => 'publish',
		'post_type'    => 'page',
		'post_author'  => 1
	)
);

// デバッグ
if (!is_wp_error($thanks_page_id)) {
	WP_CLI::success("サンクスページを作成しました（ID: " . $thanks_page_id . "、URL:" . get_permalink($thanks_page_id));
} else {
	WP_CLI::error('サンクスページの作成に失敗しました: ' . $thanks_page_id->get_error_message());
	return;
}

// エラーページの作成
$error_page_id = wp_insert_post(
	array(
		'post_title'   => '内容を確認（エラー）',
		'post_name'    => 'error',
		'post_parent'    => $contact_page_id,
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">以下のエラーをご確認ください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $form_id . '"]<!-- /wp:shortcode -->',
		'post_status'  => 'publish',
		'post_type'    => 'page',
		'post_author'  => 1
	)
);

// デバッグ
if (!is_wp_error($error_page_id)) {
	WP_CLI::success("エラーページを作成しました（ID: " . $error_page_id . "、URL:" . get_permalink($error_page_id));
} else {
	WP_CLI::error('エラーページの作成に失敗しました: ' . $error_page_id->get_error_message());
	return;
}

/**
 * 英語版の問い合わせフォームおよび固定ページを作成
 */

WP_CLI::log("\n=== 英語版の問い合わせフォームおよび固定ページを作成 ===");

// フォーム設定データ
$form_title = 'Contact Form';

// フォームコンテンツ
$form_content = '<div class="prose">
    [mwform_akismet_error]
    [mwform_error keys="recaptcha-v3"]
[mwform_radio name="gfgdsgf" id="gfdsgf" vertically="true"]
    <p class="mwform-item">
        <label for="inquiry-type" class="form-label">お問い合わせ種別</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:リサーチャーへの講演依頼,workshop:ナビゲーターへのワークショップ依頼,interview:取材・出演・執筆等、広報に関するお問い合わせ,collabo:共同研究・開発に関するご相談,farm-tour:農園見学のお申し込み,careers:採用に関するお問い合わせ,others:上記以外のお問い合わせ" vertically="true" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p class="mwform-item">
            <label for="last-name" class="form-label">姓</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p class="mwform-item">
            <label for="first-name" class="form-label">名</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p class="mwform-item">
        <label for="company" class="form-label">企業・団体名<span class="label-mark">任意</span></label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p class="mwform-item">
        <label for="email" class="form-label">メールアドレス</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p class="mwform-item">
        <label for="tel" class="form-label">電話番号</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p class="mwform-item">
        <label for="message" class="form-label">お問い合わせ内容</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <div class="embedded-privacy-policy">
        <p class="embedded-privacy-policy__heading">個人情報保護方針</p>
        [wpf_embedded_privacy_policy root_level="4"]
    </div>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">取得した個人情報は<a href="/privacy-policy/" target="_blank" rel="noopener">個人情報保護方針</a>に従って取り扱いを行います。</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="個人情報保護方針に同意する" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]内容を確認[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]戻る[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]送信する[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">このフォームはreCAPTCHAによって保護されており、Googleの<a href="https://policies.google.com/privacy" target="_blank" rel="noopener">プライバシーポリシー</a>と<a href="https://policies.google.com/terms" target="_blank" rel="noopener">利用規約</a>が適用されます。</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>お問い合わせありがとうございます。ご入力いただいたメールアドレスに自動返信メールをお送りしました。自動返信メールが届かない場合、迷惑メールフォルダに格納されているか、ご入力のメールアドレスに誤りがある可能性がございます。自動返信メールが見当たらない場合、恐れ入りますが、メールアドレスをご確認の上、再度お問い合わせいただきますよう宜しくお願いいたします。</p>';

// 自動返信メール
$automatic_reply_content = '{last-name} {first-name} 様

この度は、' . get_bloginfo('name') . 'へお問い合わせいただきありがとうございます。以下の内容でお問い合わせを承りました。

お問い合わせ種別: {inquiry-type}
姓: {last-name}
名: {first-name}
企業・団体名: {company}
メールアドレス: {email}
電話番号: {tel}
お問い合わせ内容: {message}
個人情報保護方針への同意: {privacy-consent}

--
このメールは ' . get_bloginfo('url') . ' のお問い合わせフォームよりお問い合わせいただいた方に自動返信しています。お心当たりのない場合は、お手数ですが、このメールを破棄してくださいますよう宜しくお願いいたします。';

// フォームの作成
$tr_form_id = wp_insert_post(
	array(
		'post_title'   => $form_title,
		'post_content' => $form_content,
		'post_status'  => 'publish',
		'post_type'    => 'mw-wp-form',
		'post_author'  => 1,
		'meta_input'   => array(
			'mw-wp-form' => array(
				'querystring' => false,
				'usedb' => '0',

				// 自動返信メール設定
				'automatic_reply_email' => 'email',
				'mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせありがとうございます',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => get_bloginfo('name'),
				'mail_reply_to' => get_option('admin_email'),
				'mail_content' => $automatic_reply_content,
				'mail_to' => get_option('admin_email'),
				'mail_cc' => '',
				'mail_bcc' => '',
				'mail_return_path' => get_option('admin_email'),

				// 管理者宛メール設定
				'admin_mail_reply_to' => get_option('admin_email'),
				'admin_mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせがありました',
				'admin_mail_from' => get_option('admin_email'),
				'admin_mail_sender' => get_bloginfo('name'),
				'admin_mail_content' => $admin_mail_content,

				// Akismet設定 ※reCAPTCHAを使うので使用しない
				'akismet_author' => '',
				'akismet_author_email' => '',
				'akismet_author_url' => '',

				// 画面設定
				'complete_message' => $complete_message,
				'input_url' => '/en/contact/',
				'confirmation_url' => '/en/contact/confirm/',
				'complete_url' => '/en/contact/thankyou/',
				'validation_error_url' => '/en/contact/error/',

				// バリデーション設定 ※テーマで設定済みなので使用しない
				'validation' => array(),

				// その他設定
				'style' => '',
				'scroll' => '0'
			)
		)
	)
);

// デバッグ
if (!is_wp_error($tr_form_id)) {
    WP_CLI::success("フォームを作成しました（ID: " . $tr_form_id . "、タイトル: " . $form_title);
	WP_CLI::log("\n=== 保存された設定の確認 ===");
	$saved_settings = get_post_meta($tr_form_id, 'mw-wp-form', true);
	if ($saved_settings) {
		WP_CLI::log("✓ mw-wp-form メタキーに設定が正常に保存されました");
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['mail_to']);
		WP_CLI::log("- 自動返信メール件名: " . $saved_settings['mail_subject']);
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['automatic_reply_email']);
		WP_CLI::log("- 管理者宛メール件名: " . $saved_settings['admin_mail_subject']);
		WP_CLI::log("- データベース保存: " . ($saved_settings['usedb'] === '1' ? '有効' : '無効'));
	} else {
		WP_CLI::error("設定の保存に失敗しました");
	}

	WP_CLI::log("\n=== フォーム表示方法 ===");
	WP_CLI::log("[mwform_formkey key=\"" . $tr_form_id . "\"]");

	WP_CLI::log("\n=== phpMyAdminで設定を確認する ===");
	WP_CLI::log("SELECT meta_value FROM wp_postmeta WHERE post_id = $tr_form_id AND meta_key = 'mw-wp-form';");
} else {
	WP_CLI::error('フォームの作成に失敗しました: ' . $tr_form_id->get_error_message());
    return;
}

// 問い合わせページをコピー
$tr_contact_page_id = PLL()->sync_post_model->copy( $contact_page_id, 'en', 'copy', false );

// 問い合わせページを翻訳
$tr_contact_page_id = wp_update_post(
	array(
		'ID'           => $tr_contact_page_id,
		'post_title'   => 'お問い合わせ',
		'post_content' => '<!-- wp:paragraph --><p>以下のフォームに必要事項をご入力の上、送信してください。内容によっては返信に時間がかかる場合や、回答を差し控えさせていただく場合もございます。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_contact_page_id)) {
	WP_CLI::success("お問い合わせページを翻訳しました（ID: " . $tr_contact_page_id . "、URL:" . get_permalink($tr_contact_page_id));
} else {
	WP_CLI::error('お問い合わせページの翻訳に失敗しました: ' . $tr_contact_page_id->get_error_message());
	return;
}

// 内容確認ページをコピー
$tr_comfirm_page_id = PLL()->sync_post_model->copy( $comfirm_page_id, 'en', 'copy', false );

// 内容確認ページを翻訳
$tr_comfirm_page_id = wp_update_post(
	array(
		'ID'           => $tr_comfirm_page_id,
		'post_title'   => '内容を確認',
		'post_content' => '<!-- wp:paragraph --><p>以下の内容で送信します。よろしければ送信ボタンを押して、お問い合わせを完了させてください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_comfirm_page_id)) {
	WP_CLI::success("内容確認ページを翻訳しました（ID: " . $tr_comfirm_page_id . "、URL:" . get_permalink($tr_comfirm_page_id));
} else {
	WP_CLI::error('内容確認ページの翻訳に失敗しました: ' . $tr_comfirm_page_id->get_error_message());
	return;
}

// サンクスページをコピー
$tr_thanks_page_id = PLL()->sync_post_model->copy( $thanks_page_id, 'en', 'copy', false );

// サンクスページを翻訳
$tr_thanks_page_id = wp_update_post(
	array(
		'ID'           => $tr_thanks_page_id,
		'post_title'   => 'お問い合わせありがとうございます',
		'post_content' => '<!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_thanks_page_id)) {
	WP_CLI::success("サンクスページを翻訳しました（ID: " . $tr_thanks_page_id . "、URL:" . get_permalink($tr_thanks_page_id));
} else {
	WP_CLI::error('サンクスページの翻訳に失敗しました: ' . $tr_thanks_page_id->get_error_message());
	return;
}

// エラーページをコピー
$tr_error_page_id = PLL()->sync_post_model->copy( $error_page_id, 'en', 'copy', false );

// エラーページを翻訳
$tr_error_page_id = wp_update_post(
	array(
		'ID'           => $tr_error_page_id,
		'post_title'   => '内容を確認（エラー）',
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">以下のエラーをご確認ください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_error_page_id)) {
	WP_CLI::success("エラーページを翻訳しました（ID: " . $tr_error_page_id . "、URL:" . get_permalink($tr_error_page_id));
} else {
	WP_CLI::error('エラーページの翻訳に失敗しました: ' . $tr_error_page_id->get_error_message());
	return;
}

/**
 * フランス語版の問い合わせフォームおよび固定ページを作成
 */

WP_CLI::log("\n=== フランス語版の問い合わせフォームおよび固定ページを作成 ===");

// フォーム設定データ
$form_title = 'Formulaire de contact';

// フォームコンテンツ
$form_content = '<div class="prose">
    [mwform_akismet_error]
    [mwform_error keys="recaptcha-v3"]
[mwform_radio name="gfgdsgf" id="gfdsgf" vertically="true"]
    <p class="mwform-item">
        <label for="inquiry-type" class="form-label">お問い合わせ種別</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:リサーチャーへの講演依頼,workshop:ナビゲーターへのワークショップ依頼,interview:取材・出演・執筆等、広報に関するお問い合わせ,collabo:共同研究・開発に関するご相談,farm-tour:農園見学のお申し込み,careers:採用に関するお問い合わせ,others:上記以外のお問い合わせ" vertically="true" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p class="mwform-item">
            <label for="last-name" class="form-label">姓</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p class="mwform-item">
            <label for="first-name" class="form-label">名</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p class="mwform-item">
        <label for="company" class="form-label">企業・団体名<span class="label-mark">任意</span></label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p class="mwform-item">
        <label for="email" class="form-label">メールアドレス</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p class="mwform-item">
        <label for="tel" class="form-label">電話番号</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p class="mwform-item">
        <label for="message" class="form-label">お問い合わせ内容</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <div class="embedded-privacy-policy">
        <p class="embedded-privacy-policy__heading">個人情報保護方針</p>
        [wpf_embedded_privacy_policy root_level="4"]
    </div>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">取得した個人情報は<a href="/privacy-policy/" target="_blank" rel="noopener">個人情報保護方針</a>に従って取り扱いを行います。</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="個人情報保護方針に同意する" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]内容を確認[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]戻る[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]送信する[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">このフォームはreCAPTCHAによって保護されており、Googleの<a href="https://policies.google.com/privacy" target="_blank" rel="noopener">プライバシーポリシー</a>と<a href="https://policies.google.com/terms" target="_blank" rel="noopener">利用規約</a>が適用されます。</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>お問い合わせありがとうございます。ご入力いただいたメールアドレスに自動返信メールをお送りしました。自動返信メールが届かない場合、迷惑メールフォルダに格納されているか、ご入力のメールアドレスに誤りがある可能性がございます。自動返信メールが見当たらない場合、恐れ入りますが、メールアドレスをご確認の上、再度お問い合わせいただきますよう宜しくお願いいたします。</p>';

// 自動返信メール
$automatic_reply_content = '{last-name} {first-name} 様

この度は、' . get_bloginfo('name') . 'へお問い合わせいただきありがとうございます。以下の内容でお問い合わせを承りました。

お問い合わせ種別: {inquiry-type}
姓: {last-name}
名: {first-name}
企業・団体名: {company}
メールアドレス: {email}
電話番号: {tel}
お問い合わせ内容: {message}
個人情報保護方針への同意: {privacy-consent}

--
このメールは ' . get_bloginfo('url') . ' のお問い合わせフォームよりお問い合わせいただいた方に自動返信しています。お心当たりのない場合は、お手数ですが、このメールを破棄してくださいますよう宜しくお願いいたします。';

// フォームの作成
$tr_form_id = wp_insert_post(
	array(
		'post_title'   => $form_title,
		'post_content' => $form_content,
		'post_status'  => 'publish',
		'post_type'    => 'mw-wp-form',
		'post_author'  => 1,
		'meta_input'   => array(
			'mw-wp-form' => array(
				'querystring' => false,
				'usedb' => '0',

				// 自動返信メール設定
				'automatic_reply_email' => 'email',
				'mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせありがとうございます',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => get_bloginfo('name'),
				'mail_reply_to' => get_option('admin_email'),
				'mail_content' => $automatic_reply_content,
				'mail_to' => get_option('admin_email'),
				'mail_cc' => '',
				'mail_bcc' => '',
				'mail_return_path' => get_option('admin_email'),

				// 管理者宛メール設定
				'admin_mail_reply_to' => get_option('admin_email'),
				'admin_mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせがありました',
				'admin_mail_from' => get_option('admin_email'),
				'admin_mail_sender' => get_bloginfo('name'),
				'admin_mail_content' => $admin_mail_content,

				// Akismet設定 ※reCAPTCHAを使うので使用しない
				'akismet_author' => '',
				'akismet_author_email' => '',
				'akismet_author_url' => '',

				// 画面設定
				'complete_message' => $complete_message,
				'input_url' => '/fr/contact/',
				'confirmation_url' => '/fr/contact/confirm/',
				'complete_url' => '/fr/contact/thankyou/',
				'validation_error_url' => '/fr/contact/error/',

				// バリデーション設定 ※テーマで設定済みなので使用しない
				'validation' => array(),

				// その他設定
				'style' => '',
				'scroll' => '0'
			)
		)
	)
);

// デバッグ
if (!is_wp_error($tr_form_id)) {
    WP_CLI::success("フォームを作成しました（ID: " . $tr_form_id . "、タイトル: " . $form_title);
	WP_CLI::log("\n=== 保存された設定の確認 ===");
	$saved_settings = get_post_meta($tr_form_id, 'mw-wp-form', true);
	if ($saved_settings) {
		WP_CLI::log("✓ mw-wp-form メタキーに設定が正常に保存されました");
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['mail_to']);
		WP_CLI::log("- 自動返信メール件名: " . $saved_settings['mail_subject']);
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['automatic_reply_email']);
		WP_CLI::log("- 管理者宛メール件名: " . $saved_settings['admin_mail_subject']);
		WP_CLI::log("- データベース保存: " . ($saved_settings['usedb'] === '1' ? '有効' : '無効'));
	} else {
		WP_CLI::error("設定の保存に失敗しました");
	}

	WP_CLI::log("\n=== フォーム表示方法 ===");
	WP_CLI::log("[mwform_formkey key=\"" . $tr_form_id . "\"]");

	WP_CLI::log("\n=== phpMyAdminで設定を確認する ===");
	WP_CLI::log("SELECT meta_value FROM wp_postmeta WHERE post_id = $tr_form_id AND meta_key = 'mw-wp-form';");
} else {
	WP_CLI::error('フォームの作成に失敗しました: ' . $tr_form_id->get_error_message());
    return;
}

// 問い合わせページをコピー
$tr_contact_page_id = PLL()->sync_post_model->copy( $contact_page_id, 'fr', 'copy', false );

// 問い合わせページを翻訳
$tr_contact_page_id = wp_update_post(
	array(
		'ID'           => $tr_contact_page_id,
		'post_title'   => 'お問い合わせ',
		'post_content' => '<!-- wp:paragraph --><p>以下のフォームに必要事項をご入力の上、送信してください。内容によっては返信に時間がかかる場合や、回答を差し控えさせていただく場合もございます。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_contact_page_id)) {
	WP_CLI::success("お問い合わせページを翻訳しました（ID: " . $tr_contact_page_id . "、URL:" . get_permalink($tr_contact_page_id));
} else {
	WP_CLI::error('お問い合わせページの翻訳に失敗しました: ' . $tr_contact_page_id->get_error_message());
	return;
}

// 内容確認ページをコピー
$tr_comfirm_page_id = PLL()->sync_post_model->copy( $comfirm_page_id, 'fr', 'copy', false );

// 内容確認ページを翻訳
$tr_comfirm_page_id = wp_update_post(
	array(
		'ID'           => $tr_comfirm_page_id,
		'post_title'   => '内容を確認',
		'post_content' => '<!-- wp:paragraph --><p>以下の内容で送信します。よろしければ送信ボタンを押して、お問い合わせを完了させてください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_comfirm_page_id)) {
	WP_CLI::success("内容確認ページを翻訳しました（ID: " . $tr_comfirm_page_id . "、URL:" . get_permalink($tr_comfirm_page_id));
} else {
	WP_CLI::error('内容確認ページの翻訳に失敗しました: ' . $tr_comfirm_page_id->get_error_message());
	return;
}

// サンクスページをコピー
$tr_thanks_page_id = PLL()->sync_post_model->copy( $thanks_page_id, 'fr', 'copy', false );

// サンクスページを翻訳
$tr_thanks_page_id = wp_update_post(
	array(
		'ID'           => $tr_thanks_page_id,
		'post_title'   => 'お問い合わせありがとうございます',
		'post_content' => '<!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_thanks_page_id)) {
	WP_CLI::success("サンクスページを翻訳しました（ID: " . $tr_thanks_page_id . "、URL:" . get_permalink($tr_thanks_page_id));
} else {
	WP_CLI::error('サンクスページの翻訳に失敗しました: ' . $tr_thanks_page_id->get_error_message());
	return;
}

// エラーページをコピー
$tr_error_page_id = PLL()->sync_post_model->copy( $error_page_id, 'fr', 'copy', false );

// エラーページを翻訳
$tr_error_page_id = wp_update_post(
	array(
		'ID'           => $tr_error_page_id,
		'post_title'   => '内容を確認（エラー）',
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">以下のエラーをご確認ください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_error_page_id)) {
	WP_CLI::success("エラーページを翻訳しました（ID: " . $tr_error_page_id . "、URL:" . get_permalink($tr_error_page_id));
} else {
	WP_CLI::error('エラーページの翻訳に失敗しました: ' . $tr_error_page_id->get_error_message());
	return;
}

/**
 * 簡体中文版の問い合わせフォームおよび固定ページを作成
 */

WP_CLI::log("\n=== 簡体中文版の問い合わせフォームおよび固定ページを作成 ===");

// フォーム設定データ
$form_title = '联系表单';

// フォームコンテンツ
$form_content = '<div class="prose">
    [mwform_akismet_error]
    [mwform_error keys="recaptcha-v3"]
[mwform_radio name="gfgdsgf" id="gfdsgf" vertically="true"]
    <p class="mwform-item">
        <label for="inquiry-type" class="form-label">お問い合わせ種別</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:リサーチャーへの講演依頼,workshop:ナビゲーターへのワークショップ依頼,interview:取材・出演・執筆等、広報に関するお問い合わせ,collabo:共同研究・開発に関するご相談,farm-tour:農園見学のお申し込み,careers:採用に関するお問い合わせ,others:上記以外のお問い合わせ" vertically="true" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p class="mwform-item">
            <label for="last-name" class="form-label">姓</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p class="mwform-item">
            <label for="first-name" class="form-label">名</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p class="mwform-item">
        <label for="company" class="form-label">企業・団体名<span class="label-mark">任意</span></label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p class="mwform-item">
        <label for="email" class="form-label">メールアドレス</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p class="mwform-item">
        <label for="tel" class="form-label">電話番号</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p class="mwform-item">
        <label for="message" class="form-label">お問い合わせ内容</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <div class="embedded-privacy-policy">
        <p class="embedded-privacy-policy__heading">個人情報保護方針</p>
        [wpf_embedded_privacy_policy root_level="4"]
    </div>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">取得した個人情報は<a href="/privacy-policy/" target="_blank" rel="noopener">個人情報保護方針</a>に従って取り扱いを行います。</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="個人情報保護方針に同意する" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]内容を確認[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]戻る[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]送信する[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">このフォームはreCAPTCHAによって保護されており、Googleの<a href="https://policies.google.com/privacy" target="_blank" rel="noopener">プライバシーポリシー</a>と<a href="https://policies.google.com/terms" target="_blank" rel="noopener">利用規約</a>が適用されます。</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>お問い合わせありがとうございます。ご入力いただいたメールアドレスに自動返信メールをお送りしました。自動返信メールが届かない場合、迷惑メールフォルダに格納されているか、ご入力のメールアドレスに誤りがある可能性がございます。自動返信メールが見当たらない場合、恐れ入りますが、メールアドレスをご確認の上、再度お問い合わせいただきますよう宜しくお願いいたします。</p>';

// 自動返信メール
$automatic_reply_content = '{last-name} {first-name} 様

この度は、' . get_bloginfo('name') . 'へお問い合わせいただきありがとうございます。以下の内容でお問い合わせを承りました。

お問い合わせ種別: {inquiry-type}
姓: {last-name}
名: {first-name}
企業・団体名: {company}
メールアドレス: {email}
電話番号: {tel}
お問い合わせ内容: {message}
個人情報保護方針への同意: {privacy-consent}

--
このメールは ' . get_bloginfo('url') . ' のお問い合わせフォームよりお問い合わせいただいた方に自動返信しています。お心当たりのない場合は、お手数ですが、このメールを破棄してくださいますよう宜しくお願いいたします。';

// フォームの作成
$tr_form_id = wp_insert_post(
	array(
		'post_title'   => $form_title,
		'post_content' => $form_content,
		'post_status'  => 'publish',
		'post_type'    => 'mw-wp-form',
		'post_author'  => 1,
		'meta_input'   => array(
			'mw-wp-form' => array(
				'querystring' => false,
				'usedb' => '0',

				// 自動返信メール設定
				'automatic_reply_email' => 'email',
				'mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせありがとうございます',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => get_bloginfo('name'),
				'mail_reply_to' => get_option('admin_email'),
				'mail_content' => $automatic_reply_content,
				'mail_to' => get_option('admin_email'),
				'mail_cc' => '',
				'mail_bcc' => '',
				'mail_return_path' => get_option('admin_email'),

				// 管理者宛メール設定
				'admin_mail_reply_to' => get_option('admin_email'),
				'admin_mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせがありました',
				'admin_mail_from' => get_option('admin_email'),
				'admin_mail_sender' => get_bloginfo('name'),
				'admin_mail_content' => $admin_mail_content,

				// Akismet設定 ※reCAPTCHAを使うので使用しない
				'akismet_author' => '',
				'akismet_author_email' => '',
				'akismet_author_url' => '',

				// 画面設定
				'complete_message' => $complete_message,
				'input_url' => '/zh/contact/',
				'confirmation_url' => '/zh/contact/confirm/',
				'complete_url' => '/zh/contact/thankyou/',
				'validation_error_url' => '/zh/contact/error/',

				// バリデーション設定 ※テーマで設定済みなので使用しない
				'validation' => array(),

				// その他設定
				'style' => '',
				'scroll' => '0'
			)
		)
	)
);

// デバッグ
if (!is_wp_error($tr_form_id)) {
    WP_CLI::success("フォームを作成しました（ID: " . $tr_form_id . "、タイトル: " . $form_title);
	WP_CLI::log("\n=== 保存された設定の確認 ===");
	$saved_settings = get_post_meta($tr_form_id, 'mw-wp-form', true);
	if ($saved_settings) {
		WP_CLI::log("✓ mw-wp-form メタキーに設定が正常に保存されました");
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['mail_to']);
		WP_CLI::log("- 自動返信メール件名: " . $saved_settings['mail_subject']);
		WP_CLI::log("- 自動返信メール送信先: " . $saved_settings['automatic_reply_email']);
		WP_CLI::log("- 管理者宛メール件名: " . $saved_settings['admin_mail_subject']);
		WP_CLI::log("- データベース保存: " . ($saved_settings['usedb'] === '1' ? '有効' : '無効'));
	} else {
		WP_CLI::error("設定の保存に失敗しました");
	}

	WP_CLI::log("\n=== フォーム表示方法 ===");
	WP_CLI::log("[mwform_formkey key=\"" . $tr_form_id . "\"]");

	WP_CLI::log("\n=== phpMyAdminで設定を確認する ===");
	WP_CLI::log("SELECT meta_value FROM wp_postmeta WHERE post_id = $tr_form_id AND meta_key = 'mw-wp-form';");
} else {
	WP_CLI::error('フォームの作成に失敗しました: ' . $tr_form_id->get_error_message());
    return;
}

// 問い合わせページをコピー
$tr_contact_page_id = PLL()->sync_post_model->copy( $contact_page_id, 'zh', 'copy', false );

// 問い合わせページを翻訳
$tr_contact_page_id = wp_update_post(
	array(
		'ID'           => $tr_contact_page_id,
		'post_title'   => 'お問い合わせ',
		'post_content' => '<!-- wp:paragraph --><p>以下のフォームに必要事項をご入力の上、送信してください。内容によっては返信に時間がかかる場合や、回答を差し控えさせていただく場合もございます。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_contact_page_id)) {
	WP_CLI::success("お問い合わせページを翻訳しました（ID: " . $tr_contact_page_id . "、URL:" . get_permalink($tr_contact_page_id));
} else {
	WP_CLI::error('お問い合わせページの翻訳に失敗しました: ' . $tr_contact_page_id->get_error_message());
	return;
}

// 内容確認ページをコピー
$tr_comfirm_page_id = PLL()->sync_post_model->copy( $comfirm_page_id, 'zh', 'copy', false );

// 内容確認ページを翻訳
$tr_comfirm_page_id = wp_update_post(
	array(
		'ID'           => $tr_comfirm_page_id,
		'post_title'   => '内容を確認',
		'post_content' => '<!-- wp:paragraph --><p>以下の内容で送信します。よろしければ送信ボタンを押して、お問い合わせを完了させてください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_comfirm_page_id)) {
	WP_CLI::success("内容確認ページを翻訳しました（ID: " . $tr_comfirm_page_id . "、URL:" . get_permalink($tr_comfirm_page_id));
} else {
	WP_CLI::error('内容確認ページの翻訳に失敗しました: ' . $tr_comfirm_page_id->get_error_message());
	return;
}

// サンクスページをコピー
$tr_thanks_page_id = PLL()->sync_post_model->copy( $thanks_page_id, 'zh', 'copy', false );

// サンクスページを翻訳
$tr_thanks_page_id = wp_update_post(
	array(
		'ID'           => $tr_thanks_page_id,
		'post_title'   => 'お問い合わせありがとうございます',
		'post_content' => '<!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_thanks_page_id)) {
	WP_CLI::success("サンクスページを翻訳しました（ID: " . $tr_thanks_page_id . "、URL:" . get_permalink($tr_thanks_page_id));
} else {
	WP_CLI::error('サンクスページの翻訳に失敗しました: ' . $tr_thanks_page_id->get_error_message());
	return;
}

// エラーページをコピー
$tr_error_page_id = PLL()->sync_post_model->copy( $error_page_id, 'zh', 'copy', false );

// エラーページを翻訳
$tr_error_page_id = wp_update_post(
	array(
		'ID'           => $tr_error_page_id,
		'post_title'   => '内容を確認（エラー）',
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">以下のエラーをご確認ください。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
	)
);

// デバッグ
if (!is_wp_error($tr_error_page_id)) {
	WP_CLI::success("エラーページを翻訳しました（ID: " . $tr_error_page_id . "、URL:" . get_permalink($tr_error_page_id));
} else {
	WP_CLI::error('エラーページの翻訳に失敗しました: ' . $tr_error_page_id->get_error_message());
	return;
}

?>
