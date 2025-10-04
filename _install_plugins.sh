#!/bin/bash

# ./migrations/_install_plugins.sh

wp plugin install wordpress-importer --activate
wp plugin install akismet --activate
wp plugin install smart-custom-fields --activate
wp plugin install public-post-preview --activate
wp plugin install tinymce-advanced --activate
wp plugin install redirection --activate
wp plugin install mw-wp-form --activate
wp plugin install recaptcha-for-mw-wp-form --activate
wp plugin install users-customers-import-export-for-wp-woocommerce --activate
wp plugin install wp-multibyte-patch
wp plugin activate polylang-pro
