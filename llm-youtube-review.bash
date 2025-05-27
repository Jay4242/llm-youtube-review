#!/bin/bash
url=$1
temp_dir=$(mktemp -d -p /dev/shm/ ) || exit 1
cd "$temp_dir" || exit 1
temp="0.7"

yt-dlp --no-warnings -q --skip-download --sub-format srv3 --write-auto-subs "${url}" -o video || exit 1
title=$(yt-dlp --no-warnings -q --skip-download --get-title "${url}")

if cat video.en.srv3 | html2text > video.txt ; then
   echo "Video had Automatic Subtitles."
else
   #No Subtitles
   echo "No Automatic Youtube Subtitles found, creating our own..."
   ssh anon@anon-ai.lan subtitle-out.bash "${url}" || exit 1
   rsync -rav --progress "anon@anon-ai.lan:/dev/shm/subtitle-out/video.wav.srt" "${temp_dir}/video.srt.txt"
   cat "${temp_dir}/video.srt.txt" | grep -vE '^[0-9]+$' | grep -v -e "^$" -e "-->" > video.txt
fi

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Write a synopsis of the video." "${temp}" #| sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g' -e "s/'$//g"

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Give a point by point bulletpoint of the points listed in this transcript." "${temp}" #| sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g' -e "s/'$//g"

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Decide if the video title was clickbait." "${temp}" #| sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g' -e "s/'$//g"

llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Write a short comment you would post in response to the video as a viewer." "${temp}" #| sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g' -e "s/'$//g"

read -p "Any notes about the comment?: " notes

while [ -n "${notes}" ]; do
  llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`."  "Write a short comment you would post in response to the video as a viewer.  Remember the notes: \`${notes}\`" "${temp}" #| sed -e 's/\\n/\n/g' -e "s/\\'/'/g" -e "s/^'$//g" -e 's/\\//g' -e "s/'$//g"
  read -p "Any notes about the comment?: " notes
done

read -p "Any command for the video?: " command

while [ -n "${command}" ]; do
  llm-python-file.py video.txt "You are a helpful assistant."  "The following is a youtube video transcription for a video named \`${title}\`." "${command}" "${temp}"
  read -p "Any notes about the comment?: " command
done

# Clean up the temporary directory
rm -rf "$temp_dir"
