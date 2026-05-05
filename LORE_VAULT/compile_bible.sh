#!/bin/bash
# Autonomous Lore Compiler
BIBLE="00_MASTER_BIBLE.md"
echo "# FRANCHISE UNDERWORLD - MASTER BIBLE" > $BIBLE
echo "*(Auto-generated from Lore Vault)*" >> $BIBLE
echo "" >> $BIBLE

for dir in 01_FACTIONS 02_CHARACTERS 03_LOCATIONS 05_ART_DIRECTIVES; do
  if [ -d "$dir" ]; then
    echo "## $dir" >> $BIBLE
    cat $dir/*.md 2>/dev/null >> $BIBLE
    echo "" >> $BIBLE
  fi
done
echo "✅ Master Bible Compiled."
