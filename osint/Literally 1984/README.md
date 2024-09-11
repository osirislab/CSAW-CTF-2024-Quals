# Challenge

<details> 
  <summary>Click to reveal flag</summary>
   csawctf{Susumu_Hirasawa}
</details>

## Description

This challenge is intended to test participants' grasp of context clues (the title) as well as problem-solving skills. The intended difficulty is easy.

An artist by the name of ‌ made a cover of a song I liked, but I don't remember the original composer of that song. Could you help me find the original composer? Flag Format: csawctf{Firstname_Lastname} (replace all spaces with _)

## Solution
 <details> 
  <summary>Click to reveal solution</summary>
   Checking the suspicious missing artist name, we find that it is unicode for a zero width non-joiner. Searching this up will give the artist x0o0x_, who has a cover of a song called "Big Brother." Finding the original composer, we find the flag.
</details>

