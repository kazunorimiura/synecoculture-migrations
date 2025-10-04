#!/bin/bash

# ./migrations/utils/cleanup_terms.sh <TAXONOMY_NAME>

# 削除するタクソノミー
taxonomy=$1

wp db query "DELETE t, tt, tr FROM wp_terms AS t INNER JOIN wp_term_taxonomy AS tt ON t.term_id = tt.term_id LEFT JOIN wp_term_relationships AS tr ON tt.term_taxonomy_id = tr.term_taxonomy_id WHERE tt.taxonomy = '$taxonomy';"
