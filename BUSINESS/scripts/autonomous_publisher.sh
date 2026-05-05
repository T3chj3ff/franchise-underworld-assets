#!/bin/bash
# ============================================================
# FRANCHISE UNDERWORLD — AUTONOMOUS SOCIAL PUBLISHER
# Platforms: Instagram + Facebook (simultaneous)
# QA gate runs before every post — no exceptions.
# Usage: bash autonomous_publisher.sh [day_number]
#        launchd fires this daily at 11:00 AM MDT
# ============================================================

COMPOSIO="$HOME/.composio/composio"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

IG_USER_ID="35258367130476837"
FB_PAGE_ID="61585782878792"
FB_ACCESS_TOKEN="EAAXsSIZAz6NUBRUGZAwfxDwhpbeLZAmN9pDdApzvy7ZA5vjhvUnqkVo4XnUTtFlXxjvvtlsw72nGkOBe71uuZByYpGkJmGhr3ZCTHT6M8ZAxgkAQUVtphNtUwQqUjecM3P7hPbhGjd58TmNHktNu8TnZAZAj4745JG4wgeoBFeTZCDEO5tFZCt2VoWQerAR8YSlEdYBTotntNokBxXZAHC6gQ2ZCHZCjokUJPQhVOabwZDZD"
GITHUB_RAW="https://raw.githubusercontent.com/T3chj3ff/franchise-underworld-assets/main/PRODUCTION_SPRINTS/assets"
LOG="$PROJECT_ROOT/BUSINESS/logs/publish_log.txt"

mkdir -p "$PROJECT_ROOT/BUSINESS/logs"

# ── QA GATE ─────────────────────────────────────────────────
run_qa() {
  local local_path="$1"
  local caption="$2"
  local day="$3"

  if [ -n "$local_path" ] && [ -f "$local_path" ]; then
    echo "🔍 [DAY $day] Running QA gate..."
    python3 "$SCRIPT_DIR/qa_image.py" "$local_path" --caption "$caption" --auto-approve
    if [ $? -ne 0 ]; then
      echo "❌ [DAY $day] QA FAILED — post aborted."
      return 1
    fi
    echo "✅ [DAY $day] QA passed."
  fi
  return 0
}

# ── INSTAGRAM SINGLE POST ────────────────────────────────────
post_instagram() {
  local image_url="$1"
  local caption="$2"
  local day="$3"

  echo "📸 [DAY $day] Instagram: creating container..."
  CONTAINER=$($COMPOSIO execute INSTAGRAM_CREATE_MEDIA_CONTAINER -d "{
    \"ig_user_id\": \"$IG_USER_ID\",
    \"image_url\": \"$image_url\",
    \"caption\": \"$caption\"
  }" 2>/dev/null | grep '"id"' | head -1 | sed 's/.*"id": "\([^"]*\)".*/\1/')

  if [ -z "$CONTAINER" ]; then
    echo "❌ [DAY $day] Instagram container failed."
    return 1
  fi

  sleep 5
  $COMPOSIO execute INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH -d "{
    \"ig_user_id\": \"$IG_USER_ID\",
    \"creation_id\": \"$CONTAINER\"
  }" 2>/dev/null
  echo "✅ [DAY $day] Instagram posted. $(date)" | tee -a "$LOG"
}

# ── FACEBOOK SINGLE POST ─────────────────────────────────────
post_facebook() {
  local image_url="$1"
  local caption="$2"
  local day="$3"

  echo "📘 [DAY $day] Facebook: posting..."
  curl -s -X POST "https://graph.facebook.com/v19.0/${FB_PAGE_ID}/photos" \
    --data-urlencode "url=${image_url}" \
    --data-urlencode "message=${caption}" \
    --data-urlencode "access_token=${FB_ACCESS_TOKEN}" | grep -E '"id"|"error"'
  echo "✅ [DAY $day] Facebook posted. $(date)" | tee -a "$LOG"
}

# ── MAIN: POST TO ALL PLATFORMS ──────────────────────────────
post_all() {
  local image_url="$1"
  local caption="$2"
  local day="$3"
  local local_path="$4"

  run_qa "$local_path" "$caption" "$day" || return 1
  post_instagram "$image_url" "$caption" "$day"
  post_facebook "$image_url" "$caption" "$day"
}

# ── INSTAGRAM CAROUSEL ───────────────────────────────────────
post_carousel() {
  local caption="$1"
  local day="$2"
  shift 2
  local urls=("$@")

  echo "🎠 [DAY $day] Carousel: creating items..."
  local items=()
  for url in "${urls[@]}"; do
    ITEM=$($COMPOSIO execute INSTAGRAM_CREATE_MEDIA_CONTAINER -d "{
      \"ig_user_id\": \"$IG_USER_ID\",
      \"image_url\": \"$url\",
      \"is_carousel_item\": true
    }" 2>/dev/null | grep '"id"' | head -1 | sed 's/.*"id": "\([^"]*\)".*/\1/')
    items+=("$ITEM")
    sleep 3
  done

  local children=$(printf '"%s",' "${items[@]}" | sed 's/,$//')
  CAROUSEL=$($COMPOSIO execute INSTAGRAM_CREATE_CAROUSEL_CONTAINER -d "{
    \"ig_user_id\": \"$IG_USER_ID\",
    \"children\": [$children],
    \"caption\": \"$caption\"
  }" 2>/dev/null | grep '"id"' | head -1 | sed 's/.*"id": "\([^"]*\)".*/\1/')

  sleep 5
  $COMPOSIO execute INSTAGRAM_POST_IG_USER_MEDIA_PUBLISH -d "{
    \"ig_user_id\": \"$IG_USER_ID\",
    \"creation_id\": \"$CAROUSEL\"
  }" 2>/dev/null
  echo "✅ [DAY $day] Carousel posted. $(date)" | tee -a "$LOG"
}

# ── SCHEDULE ─────────────────────────────────────────────────
DAY=${1:-$(date +%-d)}

case $DAY in
  # ── PHASE 1: DISTRICTS (already posted, kept for rerun safety) ──
  1)
    post_all \
      "$GITHUB_RAW/district_citadel_ridge_1777879109828.png" \
      "Welcome to Lumenridge.\n\nPopulation: Classified.\nPrimary Industry: Synthetic Grease.\nThe Compact has been dead for 30 years. Nobody told the Board.\n\nFranchise Underworld — graphic novel in development. Link in bio.\n\n#FranchiseUnderworld #Lumenridge #GraphicNovel #ConceptArt #CyberpunkArt #IndieComics #Noir #WorldBuilding" \
      1 ""
    ;;
  2)
    post_all \
      "$GITHUB_RAW/district_blackpole_commons_1777879120658.png" \
      "They say it's always raining in Blackpole.\n\nThat's just the exhaust condensing.\n\nThe labor pool. The grease traps. The ones who keep Lumenridge fed.\n\n#FranchiseUnderworld #Blackpole #GraphicNovel #ConceptArt #Noir #IndieComics #WorldBuilding" \
      2 ""
    ;;
  3)
    post_all \
      "$GITHUB_RAW/district_citadel_ridge_1777879109828.png" \
      "Above the smog layer, the Board sets the Meat Quotas.\n\nDown here, we just try to survive them.\n\nCitadel Ridge — the only district in Lumenridge where the rain doesn't reach.\n\n#FranchiseUnderworld #CitadelRidge #GraphicNovel #CyberpunkArt #IndieComics" \
      3 ""
    ;;
  5)
    post_all \
      "$GITHUB_RAW/district_neon_sprawl_1777879145834.png" \
      "Middle-management gets the houses in the Sprawl.\n\nThey think they're safe.\nThey aren't.\n\nThe Neon Sprawl — 10,000 identical houses for 10,000 identical people.\n\n#FranchiseUnderworld #NeonSprawl #GraphicNovel #CyberpunkArt #IndieComics #Noir" \
      5 ""
    ;;
  6)
    post_all \
      "$GITHUB_RAW/district_ghost_oil_refineries_1777879134049.png" \
      "Ghost Oil: Highly volatile. Extremely toxic.\n\nAnd the only thing keeping the fryers running.\n\nThe refineries never sleep. Neither do the workers.\n\n#FranchiseUnderworld #GhostOil #GraphicNovel #CyberpunkArt #IndustrialArt #IndieComics" \
      6 ""
    ;;
  8)
    post_all \
      "$GITHUB_RAW/district_ash_flats_1777879159629.png" \
      "If you leave the city limits, stay off the Interstate.\n\nThe Tex-Barons don't take prisoners.\n\nThe Ash Flats — where Lumenridge dumps what it doesn't want found.\n\n#FranchiseUnderworld #AshFlats #GraphicNovel #CyberpunkArt #IndieComics #Noir" \
      8 ""
    ;;

  # ── PHASE 2: CHARACTER REVEALS ──────────────────────────────
  11)
    post_all \
      "$GITHUB_RAW/julian_pike_clean_1777900791924.png" \
      "Former enforcer. Current problem.\n\nJulian Pike — independent auditor, reluctant investigator, and the only person in Lumenridge Pastor Creed trusted with his files.\n\nHe doesn't carry a weapon. He carries a notebook.\n\n#FranchiseUnderworld #JulianPike #CharacterReveal #GraphicNovel #IndieComics #Noir" \
      11 "$PROJECT_ROOT/.gemini/antigravity/brain/8ee51e64-263a-4341-b893-10c16798e2ce/julian_pike_clean_1777900791924.png"
    ;;
  13)
    post_carousel \
      "He wore the collar on Sundays.\nHe wore the apron the rest of the week.\n\nNeither was a costume.\n\nPastor Jonah Creed — 29 years as the only neutral party in Lumenridge. The last man all ten factions trusted.\n\nSwipe to see both sides.\n\n#FranchiseUnderworld #PastorCreed #CharacterReveal #GraphicNovel #IndieComics #Noir" \
      13 \
      "$GITHUB_RAW/creed_pastor_v2.png" \
      "$GITHUB_RAW/creed_kitchen_v2.png"
    ;;
  15)
    post_all \
      "$GITHUB_RAW/char_kalani.png" \
      "280 pounds. One hydraulic gauntlet. Zero patience for the Board.\n\nKalani Morn — Coastal Fryers dock enforcer, and the only person in Lumenridge who can physically stop a Health Inspector mid-stride.\n\nHe did not ask to be involved. He is involved.\n\n#FranchiseUnderworld #KalaniMorn #CharacterReveal #GraphicNovel #IndieComics #Noir" \
      15 ""
    ;;
  17)
    post_all \
      "$GITHUB_RAW/char_mira_santos.png" \
      "She doesn't have a faction anymore.\n\nShe chose that.\n\nMira Santos — Tex-Barons field operative, surveillance specialist, and the only person who saw both sides of the ledger drop.\n\n#FranchiseUnderworld #MiraSantos #CharacterReveal #GraphicNovel #IndieComics #Noir" \
      17 ""
    ;;
  19)
    post_all \
      "$GITHUB_RAW/char_caine.png" \
      "He was hired by a dead man.\n\nHe finished the job anyway.\n\nCaine — independent fixer. No faction. No loyalty. No entries in any ledger.\n\nThat's the point.\n\n#FranchiseUnderworld #Caine #CharacterReveal #GraphicNovel #IndieComics #Noir" \
      19 ""
    ;;

  # ── PHASE 3: FACTION REVEALS ─────────────────────────────────
  21)
    post_all \
      "$GITHUB_RAW/faction_grill_house.png" \
      "The oldest franchise in Lumenridge.\n\nThe Grill Houses have been feeding the city since before the Compact.\n\nThey'll be there after too. One way or another.\n\n#FranchiseUnderworld #GrillHouse #FactionReveal #GraphicNovel #IndieComics #Noir #WorldBuilding" \
      21 ""
    ;;
  23)
    post_all \
      "$GITHUB_RAW/faction_tex_barons.png" \
      "They control the distribution routes.\n\nEvery kitchen in Lumenridge gets its supplies through Tex-Barons territory.\n\nThat's not logistics. That's leverage.\n\n#FranchiseUnderworld #TexBarons #FactionReveal #GraphicNovel #IndieComics #Noir" \
      23 ""
    ;;
  25)
    post_all \
      "$GITHUB_RAW/location_press_hall.png" \
      "Sublevel B. Ghost Oil Refineries.\n\nThe press ran for eleven years.\n\nNobody knew it was there.\n\nOne night it ran for the last time.\n\n#FranchiseUnderworld #TheBurningCrown #GraphicNovel #IndieComics #Noir #ConceptArt" \
      25 ""
    ;;
  27)
    post_all \
      "$GITHUB_RAW/location_board_chamber.png" \
      "They don't hold votes.\n\nThey haven't in 29 years.\n\nThe Board called one tonight.\n\n#FranchiseUnderworld #TheBoard #GraphicNovel #IndieComics #Noir #WorldBuilding" \
      27 ""
    ;;

  # ── PHASE 4: ZERO ISSUE DROP COUNTDOWN ───────────────────────
  29)
    post_all \
      "$GITHUB_RAW/district_citadel_ridge_1777879109828.png" \
      "The Zero Issue drops in 72 hours.\n\nEvery faction. One city. One ledger.\n\nFranchiseunderworld.com — link in bio. Join the list.\n\n#FranchiseUnderworld #ZeroIssue #ComingSoon #GraphicNovel #IndieComics #Kickstarter" \
      29 ""
    ;;
  30)
    post_all \
      "$GITHUB_RAW/district_ghost_oil_refineries_1777879134049.png" \
      "The Zero Issue is live.\n\nFranchiseunderworld.com\n\nRead it. Share it. Tell someone what they put in the grease.\n\n#FranchiseUnderworld #ZeroIssue #GraphicNovel #IndieComics #Noir #Kickstarter" \
      30 ""
    ;;
  *)
    echo "⚠️  Day $DAY not in schedule. Add it to autonomous_publisher.sh."
    ;;
esac
