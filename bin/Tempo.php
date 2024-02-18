<?php
/////////////////////////////////////////////////////////////////
/// Tempo() by Gabriel Mariani <www.coursevector.com>          //
//  available at http://labs.coursevector.com/tempo            //
//                                                             //
/////////////////////////////////////////////////////////////////
//                                                             //
// Please see readme.txt for more information                  //
//                                                            ///
/////////////////////////////////////////////////////////////////

// Defines
define('TEMPO_VERSION', '0.9.1');

include_once("../php_lib/listDirectory.php");
include_once('../php_lib/getid3/getid3.php');

class Tempo {
	
	// SETTING
	var $masterPlayList = "Tempo.m3u";
	var $masterPlayListFormat = "M3U"; // M3U, B4S, PLS
	var $musicDirectory = "music/";
	var $videoDirectory = "video/";
	var $playlistDirectory = "playlists/";
	//$refreshInterval = 60; // Minutes
	
	// Private
	var $getID3;

	function Tempo() {
		// Instatiate getID3
		$this->getID3 = new getID3;
		
		// Check for PHP version >= 4.1.0
		if (phpversion() < '4.1.0') {
			//$this->startup_error .= 'getID3() requires PHP v4.1.0 or higher - you are running v'.phpversion();
		}
		
		// define a constant rather than looking up every time it is needed
		if (!defined('TEMPO_OS_ISWINDOWS')) {
			if (strtoupper(substr(PHP_OS, 0, 3)) == 'WIN') {
				define('TEMPO_OS_ISWINDOWS', true);
			} else {
				define('TEMPO_OS_ISWINDOWS', false);
			}
		}
	}
	
	////////////
	// Public //
	////////////
	
	function refreshIndex() {
		$this->refresh($this->musicDirectory, $this->masterPlayList, $this->masterPlayListFormat);
	}
	
	function refresh($dir, $strFilename, $strFormat) {
		$handle = fopen($this->playlistDirectory . $strFilename, 'w');
		/*
		determin based on extension
		switch($strFormat) {
			case "M3U" :
				$strData = $this->getM3U($dir);
				break;
			case "B4S" :
				//$strData = $this->getB4S($dir);
				break;
			case "PLS" :
				//$strData = $this->getPLS($dir);
				break;
			default :
				$strData = $this->getM3U($dir);
		}*/
		
		$strData = $this->getM3U($dir);
		
		if(fwrite($handle, $strData) == false) {
			echo "success=false";
		} else {
			echo "success=true";
		}
		fclose($handle); 
	}
	
	function getPlayLists() {
		header ("content-type: text/xml");
		
		echo '<?xml version="1.0" ?>',"\n";
		echo '<root>', "\n";
		
		$dirlist = getFileList($this->playlistDirectory, true);
		foreach($dirlist as $file) {
			echo "\t", '<playlist><![CDATA['.$file['name'].']]></playlist>', "\n";
		}
		
		echo '</root>';
	}
	
	function savePlayList($strData, $strFilename) {
		$file = $this->playlistDirectory . $strFilename;
		$handle = fopen($file, 'w');
		if(fwrite($handle, $strData) == false) {
			echo "success=false";
		} else {
			echo "success=true";
		}
		fclose($handle);
	}
	
	function deletePlayList($strPath) {
		if($this->isPathInPath($strPath, $this->playlistDirectory)) {
			if(is_dir($strPath)) {
				echo "success=false";
			} else {
				if(unlink($strPath) == "1") {
					echo "success=true";
				} else {
					echo "success=false";
				}
			}
		} else {
			echo "success=false";
		}
	}
	
	function saveFile() {
		// Method = POST
		// Content-Type = multipart/form-data
		// name='Filedata'
		// filename='example.jpg'
		$uploadfile = $this->musicDirectory . basename($_FILES['Filedata']['name']);
		if ( move_uploaded_file($_FILES['Filedata']['tmp_name'] , $uploadfile)) {
		  echo "success=true&fileName=" . basename($_FILES['Filedata']['name']);
		}else{
		  echo "success=false";
		}
	}
	
	function deleteFile($strPath) {
		// if it's a directory, delete all files inside
		if($this->isPathInPath($strPath, $this->musicDirectory)) {
			if(is_dir($strPath)) {
				// Want to verify this path is ONLY inside of either the music or playlist path. 
				// Don't want to give control to delete anything
				//deleteDir($strPath, true);
			} else {
				if(unlink($strPath) == "1") {
					echo "success=true";
				} else {
					echo "success=false";
				}
			}
		} else {
			echo "success=false";
		}
	}
	
	/////////////
	// PRIVATE //
	/////////////
	
	function isPathInPath($strPath, $strRef) {
		$orig = $strRef;
		if(substr($strRef, -1) == "/") $strRef = substr_replace($strRef, '\\', -1, -1);
		$regEx = "/$strRef/";
		preg_match($regEx, $strPath, $resultsArr);
		if($resultsArr[0] == $orig) return true; // should i check the entire array?
		return false;
	}
	
	function isAllowedFormat($strFormat) {
		if($strFormat == '.flv' || 
			$strFormat == '.mp4' || 
			$strFormat == '.m4v' || 
			$strFormat == '.m4a' || 
			$strFormat == '.3gp' || 
			$strFormat == '.mov' || 
			$strFormat == '.f4v' || 
			$strFormat == '.f4p' || 
			$strFormat == '.f4a' || 
			$strFormat == '.f4b' || 
			$strFormat == '.mp3'
		) {
			return true;
		}
			
		return false;
	}
	
	// *** Not currenlty used
	function rel_path($dest, $root = '', $dir_sep = '/') {
		$root = explode($dir_sep, $root);
		$dest = explode($dir_sep, $dest);
		$path = '.';
		$fix = '';
		$diff = 0;
		
		for($i = -1; ++$i < max(($rC = count($root)), ($dC = count($dest)));) {
			if(isset($root[$i]) and isset($dest[$i])) {
				if($diff) {
					$path .= $dir_sep . '..';
					$fix .= $dir_sep . $dest[$i];
					continue;
				}
				if($root[$i] != $dest[$i]) {
					$diff = 1;
					$path .= $dir_sep . '..';
					$fix .= $dir_sep . $dest[$i];
					continue;
				}
			} elseif(!isset($root[$i]) and isset($dest[$i])) {
				for($j = $i-1; ++$j < $dC;) {
					$fix .= $dir_sep . $dest[$j];
				}
				break;
			} elseif(isset($root[$i]) and !isset($dest[$i])) {
				for($j = $i-1; ++$j < $rC;) {
					$fix = $dir_sep . '..' . $fix;
				}
				break;
			}
		}
		return $path . $fix;
	}
	
	function deleteDir($dir, $DeleteMe) {
		if(!$dh = @opendir($dir)) return;
		while (false !== ($obj = readdir($dh))) {
			if($obj=='.' || $obj=='..') continue;
			if (!@unlink($dir.'/'.$obj)) deleteDir($dir.'/'.$obj, true);
		}

		closedir($dh);
		if ($DeleteMe) {
			@rmdir($dir);
		}
	} 
	
	function getM3U($dir) {
		// header('Content-Type: audio/x-mpegurl');
		$dirlist = getFileList($dir, true);
		$str = '#EXTM3U' . "\r\n";
		
		foreach($dirlist as $file) {
			if($this->isAllowedFormat(strtolower($file["type"]))) {
				if($file["type"] == ".mp3") {
					$fileInfo = $this->getID3->analyze($file['name']);
					getid3_lib::CopyTagsToComments($fileInfo);
					
					if (isset($fileInfo['comments_html']['title']) && isset($fileInfo['comments_html']['artist'])) {
						$shortName = $fileInfo['comments_html']['artist'][0] . ' - ' . $fileInfo['comments_html']['title'][0];
					} else {
						//$extLength = strlen($file['type']);
						//$endPos = strlen($fileInfo['filename']) - $extLength;
						//$shortName = substr($fileInfo['filename'], 0, $endPos);
						$shortName = basename($file['name'], $file["type"]);
					}
					
					$str .= '#EXTINF:' . (int) ($fileInfo['playtime_seconds']) . ',' . $shortName . "\r\n";
				} else {
					$str .= '#EXTINF:-1,' . basename($file['name'], $file["type"]) . "\r\n";
				}
				//$str .= rawurlencode($file['name']) . "\n";
				$str .= $file['name'] . "\r\n";
			}
		}
		
		return $str;
	}

}

$tempo = new Tempo;
$action = $_REQUEST["action"];
switch($action) {
	case "refreshIndex" :
		$tempo->refreshIndex();
		break;
	case "refresh" :
		$tempo->refresh($_REQUEST["path"], $_REQUEST["name"], $_REQUEST["format"]);
		break;
	case "getPlayLists" :
		$tempo->getPlayLists();
		break;
	case "savePlayList" :
		$tempo->deleteFile($_REQUEST["data"], $_REQUEST["name"]);
		break;
	case "deletePlayList" :
		$tempo->deletePlayList($_REQUEST["path"]);
		break;
	case "saveFile" :
		$tempo->saveFile();
		break;
	case "deleteFile" :
		$tempo->deleteFile($_REQUEST["path"]);
		break;
	default :
		echo "success=false";
}