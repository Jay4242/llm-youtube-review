# llm-youtube-review
A simple youtube LLM Agent that describes the video, judges if the title was clickbait, and then generates a comment.  All based on the subtitles of the video.

## llm-youtube-review.bash
Takes in a youtube URL as a parameter.

Uses a ~/yt-dlp/ directory to download the subtitles of the video using yt-dlp.

It strips some of the subtitle tags using html2text.

 It then makes three LLM calls using llm-python-file.py, feeding the subtitles to the LLM.
