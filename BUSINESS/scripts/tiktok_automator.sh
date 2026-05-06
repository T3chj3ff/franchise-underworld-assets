#!/bin/bash
# ============================================================
# FRANCHISE UNDERWORLD — TIKTOK VIDEO AUTOMATOR
# Converts a static Model Sheet/District art into an engaging
# vertical video (9:16) with Ken Burns zoom and blurred background.
# Uses Composio to autonomously publish to TikTok.
#
# Usage: bash tiktok_automator.sh <image_path> <title>
# ============================================================

COMPOSIO="$HOME/.composio/composio"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_ROOT/BUSINESS/assets/videos"
mkdir -p "$OUTPUT_DIR"

IMAGE_PATH="$1"
TITLE="$2"
shift 2
CAPTION="$@"

if [ -z "$IMAGE_PATH" ] || [ -z "$TITLE" ]; then
  echo "Usage: bash tiktok_automator.sh <image_path> <title> <optional_caption>"
  exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
  echo "❌ Error: Image file not found at $IMAGE_PATH"
  exit 1
fi

if [[ -z "$CAPTION" ]]; then
  CAPTION="#FranchiseUnderworld #GraphicNovel #Lore #Cyberpunk #Animation #WorldBuilding"
fi

FILENAME=$(basename "$IMAGE_PATH")
FILENAME_NOEXT="${FILENAME%.*}"
OUTPUT_MP4="$OUTPUT_DIR/${FILENAME_NOEXT}_tiktok.mp4"

echo "🎥 Starting Vertical Video Generation for TikTok..."
echo "Input: $IMAGE_PATH"

# 1. GENERATE VERTICAL VIDEO (Ken Burns + Blurred Background)
# - scales image to fit width 1080, applies a slow 10% zoom over 8 seconds.
# - overlays it on a deeply blurred, dark version of itself filling 1080x1920.

ffmpeg -y -loop 1 -i "$IMAGE_PATH" \
  -vf "
    color=c=black:s=1080x1920[bg];
    [0:v]scale=1080:1920:force_original_aspect_ratio=increase,boxblur=40:40,format=yuv420p[blurred];
    [0:v]scale=1080:-2,zoompan=z='min(zoom+0.0015,1.15)':d=240:x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':s=1080x1080[fg];
    [bg][blurred]overlay=format=auto[bg2];
    [bg2][fg]overlay=(W-w)/2:(H-h)/2:format=auto
  " \
  -c:v libx264 -t 8 -pix_fmt yuv420p -r 30 "$OUTPUT_MP4"

if [ $? -ne 0 ]; then
  echo "❌ FFmpeg failed to generate video."
  exit 1
fi

echo "✅ Video generated successfully: $OUTPUT_MP4"

# 2. UPLOAD TO TIKTOK VIA COMPOSIO
echo "📱 Uploading to TikTok..."

# The video must be accessible via URL for Composio/TikTok API if running from cloud, 
# but if Composio accepts local paths or we upload to a temp bucket, we handle that here.
# Assuming standard file upload is supported by the composio CLI for TikTok:
# (If it requires a URL, we will need to hook into the GitHub raw link or similar first)

# Note: TikTok requires OAuth via Composio
# Make sure you have connected your TikTok account: `composio add tiktok`

UPLOAD_RES=$($COMPOSIO execute TIKTOK_UPLOAD_VIDEO -d "{
  \"video_path\": \"$OUTPUT_MP4\",
  \"title\": \"$TITLE\",
  \"caption\": \"$CAPTION\"
}")

echo "$UPLOAD_RES"
echo "✅ TikTok automation completed."
