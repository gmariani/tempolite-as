<?
include_once("../php_lib/listDirectory.php");
?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">

<head>
    <title>--- Tempo v0.9---</title>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="keywords" content="mp3 player, as3, flash, tempo" />
    <meta name="description" content="Flash based music player built in Flash 9/AS3 with PureMVC." />
    <meta name="revised" content="Gabriel Mariani, 2/8/2008" />

    <!-- SWFObject embed by Geoff Stearns geoff@deconcept.com http://blog.deconcept.com/swfobject/ -->
    <link rel="stylesheet" type="text/css" href="css/style.css" />

    <script type="text/javascript" src="http://www.coursevector.com/js/swfobject.js"></script>
</head>

<body>

    <div id="wrapper">
        <div id="flashcontent">
            <strong>You need to upgrade your Flash Player</strong><br>
            This site requires atleast version 9. If you would like to continue anyways, please click <a href="index.html?detectflash=false">here</a> to bypass.
        </div>
    </div>
    <br />
    <div align="center">
        <span>
            Playlists:
            <select onChange="swapPlaylist(this); return false;">
                <?
                $dirlist = getFileList("playlists", true);
                foreach ($dirlist as $file) {
                    echo "<option value=" . $file['name'] . ">" . basename($file['name'], $file["type"]) . "</option>";
                }
                ?>
            </select>
            |
            Skins:
            <select onChange="swapSkin(this); return false;">
                <?
                $dirlist = getFileList("skins", true);
                foreach ($dirlist as $file) {
                    echo "<option value=" . $file['name'] . ">" . basename($file['name'], $file["type"]) . "</option>";
                }
                ?>
            </select>
            <br>
        </span>
        <span class="style1">
            <a href="http://www.coursevector.com/" target="_blank">Tempo v0.9 by Course Vector </a> |
            <a href="Tempo.php?action=refresh&path=videos&name=Videos.m3u" target="_blank">Refresh Video Playlist</a> |
            <a href="Tempo.php?action=refreshIndex" target="_blank">Refresh Main Playlist</a>
        </span>

        <br />
        <A href="http://www.adobe.com/go/getflashplayer/"><IMG src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" width="112" height="33" border="0"></A>
    </div>

    <script type="text/javascript">
        // <![CDATA[

        var so = new SWFObject("Tempo.swf", "Tempo", "640", "600", "9", "#97C0E1");
        so.useExpressInstall('flash/expressinstall.swf');
        so.addVariable("skinURL", "skins/DefaultSkin.swf");
        so.addParam("allowScriptAccess", "always");
        so.addParam("allowFullScreen", "true");
        so.write("flashcontent");

        var flashObj = document.getElementById("Tempo");

        function swapSkin(o) {
            flashObj.loadSkin(o.options[o.selectedIndex].value);
        }

        function swapPlaylist(o) {
            flashObj.loadPlayList(o.options[o.selectedIndex].value);
        }

        // ]]>
    </script>


</body>

</html>