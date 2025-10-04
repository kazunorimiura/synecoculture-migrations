#!/bin/bash

# ./migrations/static_pages/_update_show_on_front.sh <VALUE>

value=$1

wp eval '
update_option( "show_on_front", "'$value'" );
$updated_value = get_option( "show_on_front" );
echo "Update show_on_front: " . $updated_value . "\n";
'
