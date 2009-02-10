#!/bin/bash

TODAY="`date +%Y%m%d`"

(echo "START Fetch: `date +%x-%X`"; wns.sh --debug 300 DGT ; \
     wns.sh --debug 300 TPG ; echo "End fetch:`date +%x-%X`" ) > $TODAY-fetch.log

wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "DGT $TODAY 1" > $TODAY-parse-result.DGT 
wns.sh --tag-seq -- | wns.sh --tag-parsing-bydate "TPG $TODAY 1" > $TODAY-parse-result.TPG
cat $TODAY-parse-result.DGT $TODAY-parse-result.TPG | wns.sh --tag-one-line > $TODAY.tag-report 
cat $TODAY.tag-report | wns.sh --add-folder-tag > $TODAY.fldr-report 
cat $TODAY.fldr-report | wns.sh --move-folder 


