#!/bin/bash

# ./migrations/_url_rename.sh

wp search-replace https://synecoblog.kzmr.work http://synecoculture.test --skip-columns=guid
wp search-replace synecoblog.kzmr.work synecoculture.test --skip-columns=guid

wp search-replace https://synecoinc.kzmr.work http://synecoculture.test --skip-columns=guid
wp search-replace synecoinc.kzmr.work synecoculture.test --skip-columns=guid
