#!/bin/bash

# ./migrations/page_migrations/_attach_option_page.sh <OPTION_NAME> <PAGE_SLUG>

option_name=$1
page_slug=$2

wp eval '
$page = get_page_by_path("'$page_slug'", OBJECT, "page");
update_option( "'$option_name'", $page->ID );
$updated_value = get_option( "'$option_name'" );
echo "Update '$option_name': " . $updated_value . "\n";
'
