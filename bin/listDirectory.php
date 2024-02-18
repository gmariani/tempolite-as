<?php 
	# Original <em>PHP</em> code by Chirp Internet: www.chirp.com.au
	# Please acknowledge use of this code by including this header.

	function getFileList($dir, $recurse=false, $depth=false) {
		# array to hold return value
		$retval = array();

		# add trailing slash if missing
		if(substr($dir, -1) != "/") $dir .= "/";

		# open pointer to <em>directory</em> and read list of files
		$d = @dir($dir) or die("getFileList: Failed opening <em>directory</em> $dir for reading");
		while(false !== ($entry = $d->read())) {
			# skip hidden files
			if($entry[0] == ".") continue;
			if(is_dir("$dir$entry")) {
				$retval[] = array(
				"name" => "$dir$entry/",
				"type" => filetype("$dir$entry"),
				"size" => 0,
				"lastmod" => filemtime("$dir$entry")
				);
				if($recurse && is_readable("$dir$entry/")) {
					if($depth === false) {
						$retval = array_merge($retval, getFileList("$dir$entry/", true));
					} elseif($depth > 0) {
						$retval = array_merge($retval, getFileList("$dir$entry/", true, $depth-1));
					}
				}
			} elseif(is_readable("$dir$entry")) {
				$retval[] = array(
				"name" => "$dir$entry",
				"type" => getExtension("$dir$entry"),
				"size" => filesize("$dir$entry"),
				"lastmod" => filemtime("$dir$entry")
				);
			}
		}
		$d->close();

		return $retval;
		
		/*
		 # single directory 
		 $dirlist = getFileList("./"); 
		 
		 # include all subdirectories recursively
		 $dirlist = getFileList("./", true);
		 
		 # include just one or two levels of subdirectories
		 $dirlist = getFileList("./", true, 1);
		 $dirlist = getFileList("./", true, 2);
		 */
	}
	
	function getExtension($file) {
		$pos = strrpos($file, '.');
		if(!$pos) {
			return 'Unknown Filetype';
		}
		$str = substr($file, $pos, strlen($file));
		return $str;
	}
	
	
	
	function directoryToArray($directory, $recursive) {
	$array_items = array();
	if ($handle = opendir($directory)) {
		while (false !== ($file = readdir($handle))) {
			if ($file != "." && $file != "..") {
				if (is_dir($directory. "/" . $file)) {
					if($recursive) {
						$array_items = array_merge($array_items, directoryToArray($directory. "/" . $file, $recursive));
					}
					//$file = $directory . "/" . $file;
					//$array_items[] = preg_replace("/\/\//si", "/", $file);
				} else {
					$file = $directory . "/" . $file;
					$array_items[] = preg_replace("/\/\//si", "/", $file);
				}
			}
		}
		closedir($handle);
	}
	return $array_items;
}
?>