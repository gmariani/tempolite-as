# Description
TempoLite 3.0 is a complete refactoring of the code. I've finally made it modular enough that you can pick and choose which components you need at the time. If you only want to play an mp3, then just use the SoundPlayer. If you need to play a video use the NetStreamPlayer. If you're not sure if you're going to be loading an mp3 or a video, use TempoLite and it will play the media with the correct player. By using only what you need you can keep filesize down. TempoLite (1.0) is now the core of Tempo, with Tempo expanding upon TempoLite's capabilities. With that said, TempoLite focuses on playing and managing media, nothing else. Any UI elements would be handled by the user or by Tempo.

TempoLite is no longer a component you drag into the library. It is now purely just a set of calsses you copy to your project folder. I've found this is simpler to test and update than needing to update something in the FLA constantly.

# Competitors
This is a list of other known Flash media players currently out. While some media players may seem fancy or elaborate TempoLite's goal is to be small, and efficient. Below is a list of comparable players with similar capabilities and file sizes:

- [Wimpy Wasp 1.0.116](http://www.wimpyplayer.com/products/wimpy_wasp.html) : 64kb - Plays only one video/song, no playlist (Not Free)
- [Wimpy Button 4.0.4](http://www.wimpyplayer.com/products/wimpy_button.html) : 30kb - Plays only one song, no playlist (Not Free)
- [video.Maru 3.5b](http://videomaru.com/) : 28kb
- TempoLite : 15kb

*There was an embedded Flash demo of TempoLite styled as a Wimpy Button*

This Wimpy Button styled TempoLite demo is only __8Kb__ (version 2.0 was 20kb but allowed for playlista M4A and videos), compared to the __30Kb__ for the actual Wimpy Button.

# Usage
## Item Object
An item object is used for handling a single item. You pass an item object to add audio or video to the play list. When you try to retrieve audio or video from the play list, it is returned as an item object. Below is the format of an item object :
```javascript
{title: "My Song", length: "100", url: "mySong.mp3", extOverride: "m4a"}
```
If no title is passed, it will be set to "". If no length is passed, it will be set to -1. If extOverride isn't passed, Tempo will get that last three letters of the file name to guess the file format.

## Support Video Formats
Below is a list of the supported video formats. This is basically a run down of the videos Flash can play.
- flv
- mp4
- m4v
- 3gp
- mov
- f4v
- f4p
- f4b

## Support Audio Formats
Below is a list of the supported audio formats, this is basically a run down of the sounds Flash can play.
- m4a
- f4a
- mp3

## Support Play List Formats
You can pass the following play list file types to Tempo. For each file type (if XML based) is a list of the corresponding tags as they relate to the Item Object described above.
- ASX
  - `<title>` = Title
  - `<ref>` or `<base>` = URL
  - `<duration>` = Length
  - [Example](/bin/playlists/asx_example.xml)
  - [Spec](https://msdn.microsoft.com/en-us/library/ms910265.aspx)
- XSPF
  - `<title>` = Title
  - `<location>` = URL
  - `<duration>` = Length
  - [Example](/bin/playlists/xspf_example.xml)
  - [Spec](http://xspf.org/specs)
- M3U
  - [Example](/bin/playlists/m3u_example.m3u)
  - [Spec](http://forums.winamp.com/showthread.php?threadid=65772)
- ATOM
  - `<title>` = Title
  - `<media:group><media:content url="value">` = URL
  - `<duration>` = Length
  - [Spec](https://developers.google.com/youtube/2.0/developers_guide_protocol?csw=1#Understanding_Video_Entries)
