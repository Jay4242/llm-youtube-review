#!/bin/bash
url=$1
cd ~/yt-dlp/ || exit 1

temp="0.7"

yt-dlp --no-warnings -q --skip-download --sub-format srv3 --write-auto-subs "${url}" -o video || exit 1
title=$(yt-dlp --no-warnings -q --skip-download --get-title "${url}")

cat video.en.srv3 | html2text > video.txt

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Write a synopsis of the video." "${temp}" | sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g'

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Decide if the video title was clickbait." "${temp}" | sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g'

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Write a short comment you would post about the video." "${temp}" | sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g'
