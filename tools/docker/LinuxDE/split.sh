#!/bin/bash

OUTPUT_FILE="debian-state-base.bin.zst"
SPLIT_SIZE="20M"

rm -f "${OUTPUT_FILE}.part"*

split -b "$SPLIT_SIZE" "$OUTPUT_FILE" "${OUTPUT_FILE}.part"

i=1
for f in "${OUTPUT_FILE}.part"* ; do
    mv "$f" "${OUTPUT_FILE}.part$i"
    echo "Created ${OUTPUT_FILE}.part$i"
    ((i++))
done