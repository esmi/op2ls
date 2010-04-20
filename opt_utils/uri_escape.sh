#!/bin/bash
echo "$1"| perl -MURI::Escape -ne 'print uri_escape($_);'

