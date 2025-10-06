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

    <p>
        <label for="inquiry-type" class="form-label">お問い合わせ種別</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:リサーチャーへの講演依頼,workshop:ナビゲーターへのワークショップ依頼,interview:取材・出演・執筆等、広報に関するお問い合わせ,collabo:共同研究・開発に関するご相談,farm-tour:農園見学のお申し込み,careers:採用に関するお問い合わせ,others:上記以外のお問い合わせ" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p>
            <label for="last-name" class="form-label">姓</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p>
            <label for="first-name" class="form-label">名</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p>
        <label for="company" class="form-label">企業・団体名</label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p>
        <label for="email" class="form-label">メールアドレス</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p>
        <label for="tel" class="form-label">電話番号</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p>
        <label for="message" class="form-label">お問い合わせ内容</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

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

				// 管理者宛メール設定
				'mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせがありました',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => get_bloginfo('name'),
				'mail_reply_to' => get_option('admin_email'),
				'mail_content' => $automatic_reply_content,
				'mail_to' => get_option('admin_email'),
				'mail_cc' => '',
				'mail_bcc' => '',
				'mail_return_path' => get_option('admin_email'),

				// 自動返信メール設定
				'automatic_reply_email' => 'email',
				'admin_mail_reply_to' => get_option('admin_email'),
				'admin_mail_subject' => '[' . get_bloginfo('name') . '] お問い合わせありがとうございます',
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

    <p>
        <label for="inquiry-type" class="form-label">Inquiry Type</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:Lecture request to researcher,workshop:Workshop request to navigator,interview:Inquiries about interviews, appearances, writing, and PR,collabo:Consultation on joint research and development,farm-tour:Farm tour application,careers:Recruitment inquiries,others:Other inquiries" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p>
            <label for="last-name" class="form-label">Last Name</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p>
            <label for="first-name" class="form-label">First Name</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p>
        <label for="company" class="form-label">Company/Organization Name</label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p>
        <label for="email" class="form-label">Email Address</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p>
        <label for="tel" class="form-label">Phone Number</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p>
        <label for="message" class="form-label">Inquiry Content</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">The personal information collected will be handled in accordance with our <a href="/en/privacy-policy/" target="_blank" rel="noopener">Privacy Policy</a>.</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="I agree to the Privacy Policy" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]Confirm Content[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]Back[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]Send[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">This form is protected by reCAPTCHA and Google\'s <a href="https://policies.google.com/privacy" target="_blank" rel="noopener">Privacy Policy</a> and <a href="https://policies.google.com/terms" target="_blank" rel="noopener">Terms of Service</a> apply.</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>Thank you for your inquiry. We have sent an automatic reply email to the email address you provided. If you do not receive the automatic reply email, it may have been placed in your spam folder or there may be an error in the email address you entered. If you cannot find the automatic reply email, we kindly ask that you verify your email address and submit your inquiry again.</p>';

// 自動返信メール
$automatic_reply_content = 'Dear {first-name} {last-name},

Thank you for contacting ' . pll_translate_string( get_bloginfo('name'), 'en' ) . '. We have received your inquiry with the following details:

Inquiry Type: {inquiry-type}
Last Name: {last-name}
First Name: {first-name}
Company/Organization: {company}
Email Address: {email}
Phone Number: {tel}
Message: {message}
Privacy Policy Consent: {privacy-consent}

--
This is an automated reply sent to those who have submitted an inquiry through the contact form at ' . get_bloginfo('url') . '. If you did not submit this inquiry, please disregard this email.';

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
				'mail_subject' => '[' . pll_translate_string( get_bloginfo('name'), 'en' ) . '] Thank you for your inquiry',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => pll_translate_string( get_bloginfo('name'), 'en' ),
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
		'post_title'   => 'Contact',
		'post_content' => '<!-- wp:paragraph --><p>Please fill out the form below with the required information and submit it. Please note that depending on the nature of your inquiry, it may take some time for us to respond, or we may not be able to provide a response.</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
		'post_title'   => 'Confirm your inquiry',
		'post_content' => '<!-- wp:paragraph --><p>We will send your inquiry with the following content. If everything looks correct, please click the submit button to complete your inquiry.</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
		'post_title'   => 'Thank you for your inquiry',
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
		'post_title'   => 'Confirm your inquiry (Error)',
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">Please check the following error.</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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

    <p>
        <label for="inquiry-type" class="form-label">Type de demande</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:Demande de conférence au chercheur,workshop:Demande d\'atelier au navigateur,interview:Demandes d\'entretiens, d\'apparitions, de rédaction et de relations publiques,collabo:Consultation sur la recherche et le développement conjoints,farm-tour:Demande de visite de ferme,careers:Demandes de recrutement,others:Autres demandes" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p>
            <label for="last-name" class="form-label">Nom de famille</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p>
            <label for="first-name" class="form-label">Prénom</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p>
        <label for="company" class="form-label">Nom de l\'entreprise/organisation</label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p>
        <label for="email" class="form-label">Adresse e-mail</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p>
        <label for="tel" class="form-label">Numéro de téléphone</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p>
        <label for="message" class="form-label">Contenu de la demande</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">Les informations personnelles collectées seront traitées conformément à notre <a href="/privacy-policy/" target="_blank" rel="noopener">Politique de confidentialité</a>.</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="J\'accepte la Politique de confidentialité" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]Confirmer le contenu[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]Retour[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]Envoyer[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">Ce formulaire est protégé par reCAPTCHA et la <a href="https://policies.google.com/privacy" target="_blank" rel="noopener">Politique de confidentialité</a> et les <a href="https://policies.google.com/terms" target="_blank" rel="noopener">Conditions d\'utilisation</a> de Google s\'appliquent.</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>Merci pour votre demande. Nous avons envoyé un e-mail de réponse automatique à l\'adresse e-mail que vous avez fournie. Si vous ne recevez pas l\'e-mail de réponse automatique, il se peut qu\'il ait été placé dans votre dossier de courrier indésirable ou qu\'il y ait une erreur dans l\'adresse e-mail que vous avez saisie. Si vous ne trouvez pas l\'e-mail de réponse automatique, nous vous demandons de bien vouloir vérifier votre adresse e-mail et soumettre à nouveau votre demande.</p>';

// 自動返信メール
$automatic_reply_content = 'Cher/Chère {first-name} {last-name},

Nous vous remercions d\'avoir contacté ' . pll_translate_string( get_bloginfo('name'), 'fr' ) . '. Nous avons bien reçu votre demande avec les informations suivantes :

Type de demande : {inquiry-type}
Nom de famille : {last-name}
Prénom : {first-name}
Entreprise/Organisation : {company}
Adresse e-mail : {email}
Numéro de téléphone : {tel}
Message : {message}
Consentement à la politique de confidentialité : {privacy-consent}

--
Ceci est une réponse automatique envoyée aux personnes qui ont soumis une demande via le formulaire de contact sur ' . get_bloginfo('url') . '. Si vous n\'avez pas soumis cette demande, veuillez ignorer cet e-mail.';

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
				'mail_subject' => '[' . pll_translate_string( get_bloginfo('name'), 'fr' ) . '] Merci pour votre demande',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => pll_translate_string( get_bloginfo('name'), 'fr' ),
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
		'post_title'   => 'Contact',
		'post_content' => '<!-- wp:paragraph --><p>Veuillez remplir le formulaire ci-dessous avec les informations requises et l\'envoyer. Veuillez noter que selon la nature de votre demande, il peut nous falloir du temps pour répondre, ou nous pourrions ne pas être en mesure de fournir une réponse.</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
		'post_title'   => 'Confirmez votre demande',
		'post_content' => '<!-- wp:paragraph --><p>Nous enverrons votre demande avec le contenu suivant. Si tout vous convient, veuillez cliquer sur le bouton d\'envoi pour finaliser votre demande.</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
		'post_title'   => 'Merci pour votre demande',
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
		'post_title'   => 'Confirmez votre demande (Erreur)',
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">Veuillez vérifier l\'erreur suivante.</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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

    <p>
        <label for="inquiry-type" class="form-label">咨询类型</label>
        [mwform_radio name="inquiry-type" id="inquiry-type" children="lecture:研究员讲座申请,workshop:导航员工作坊申请,interview:采访、出演、写作等公关相关咨询,collabo:共同研究与开发咨询,farm-tour:农场参观申请,careers:招聘咨询,others:其他咨询" class="required" show_error="false"]
		[mwform_error keys="inquiry-type"]
    </p>

    <div class="grid" style="--grid-column-width: calc(50% - var(--space-s0)); --grid-gap: var(--space-s0)">
        <p>
            <label for="last-name" class="form-label">姓</label>
            [mwform_text name="last-name" id="last-name" size="60" show_error="false"]
			[mwform_error keys="last-name"]
        </p>
        <p>
            <label for="first-name" class="form-label">名</label>
            [mwform_text name="first-name" id="first-name" size="60" show_error="false"]
			[mwform_error keys="first-name"]
        </p>
    </div>

    <p>
        <label for="company" class="form-label">企业/团体名称</label>
        [mwform_text name="company" id="company" size="60" show_error="false"]
		[mwform_error keys="company"]
    </p>

    <p>
        <label for="email" class="form-label">电子邮箱</label>
        [mwform_email name="email" id="email" size="60" show_error="false"]
		[mwform_error keys="email"]
    </p>

    <p>
        <label for="tel" class="form-label">电话号码</label>
        [mwform_text name="tel" id="tel" size="60" show_error="false"]
		[mwform_error keys="tel"]
    </p>

    <p>
        <label for="message" class="form-label">咨询内容</label>
        [mwform_textarea name="message" id="message" cols="60" rows="8" show_error="false"]
		[mwform_error keys="message"]
    </p>

    <p class="text-center" style="--flow-space: var(--space-s3)">
        <span class="d-block mbe-s-3 font-text--sm">收集的个人信息将根据我们的<a href="/privacy-policy/" target="_blank" rel="noopener">隐私政策</a>进行处理。</span>
        [mwform_checkbox name="privacy-consent" id="privacy-consent" children="同意隐私政策" separator="," show_error="false"]
		[mwform_error keys="privacy-consent"]
    </p>

    <p>
        <span class="d-flex gap-s-3 jc-center ai-center mb-s4 text-center">
            [mwform_bconfirm class="button:primary:wide" value="confirm"]确认内容[/mwform_bconfirm]
            [mwform_bback class="button:tertiary:wide" value="back"]返回[/mwform_bback]
            [mwform_bsubmit name="submit" class="button:primary:wide" value="send"]发送[/mwform_bsubmit]
        </span>
    </p>

    <p class="font-text--xs text-center">此表单受reCAPTCHA保护，适用Google的<a href="https://policies.google.com/privacy" target="_blank" rel="noopener">隐私政策</a>和<a href="https://policies.google.com/terms" target="_blank" rel="noopener">服务条款</a>。</p>

    [mwform_hidden name="recaptcha-v3"]
</div>';

// 完了メッセージ
$complete_message = '<p>感谢您的咨询。我们已向您提供的电子邮件地址发送了自动回复邮件。如果您没有收到自动回复邮件，可能是邮件被放入了垃圾邮件文件夹，或者您输入的电子邮件地址有误。如果您找不到自动回复邮件，请您确认电子邮件地址后重新提交咨询。</p>';

// 自動返信メール
$automatic_reply_content = '尊敬的 {first-name} {last-name} 先生/女士：

感谢您联系 ' . pll_translate_string( get_bloginfo('name'), 'zh' ) . '。我们已收到您的咨询，详细信息如下：

咨询类型：{inquiry-type}
姓：{last-name}
名：{first-name}
公司/机构名称：{company}
电子邮箱：{email}
电话号码：{tel}
咨询内容：{message}
隐私政策同意：{privacy-consent}

--
这是一封自动回复邮件，发送给通过 ' . get_bloginfo('url') . ' 联系表单提交咨询的用户。如果您没有提交此咨询，请忽略此邮件。';

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
				'mail_subject' => '[' . pll_translate_string( get_bloginfo('name'), 'zh' ) . '] 感谢您的咨询',
				'mail_from' => get_option('admin_email'),
				'mail_sender' => pll_translate_string( get_bloginfo('name'), 'zh' ),
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
		'post_title'   => '联系我们',
		'post_content' => '<!-- wp:paragraph --><p>请填写以下表格的必要信息并提交。根据咨询内容的不同，我们的回复可能需要一些时间，或者可能无法提供回复，敬请谅解。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
		'post_title'   => '确认您的咨询',
		'post_content' => '<!-- wp:paragraph --><p>我们将发送以下内容的咨询。如果没有问题，请点击发送按钮完成咨询。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
		'post_title'   => '感谢您的咨询',
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
		'post_title'   => '确认您的咨询（错误）',
		'post_content' => '<!-- wp:paragraph {"className":"is-style-notice\u002d\u002dnegative"} --><p class="is-style-notice--negative">请检查以下错误。</p><!-- /wp:paragraph --><!-- wp:shortcode -->[mwform_formkey key="' . $tr_form_id . '"]<!-- /wp:shortcode -->',
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
