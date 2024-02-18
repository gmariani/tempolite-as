/**
* TempoLite ©2009 Gabriel Mariani. March 30th, 2009
* Visit http://blog.coursevector.com/tempolite for documentation, updates and more free code.
*
*
* Copyright (c) 2009 Gabriel Mariani
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
**/

package cv.formats {
	
	import cv.data.PlayList;
	import cv.interfaces.IPlaylistParser;
	
	//--------------------------------------
	//  Class description
	//--------------------------------------	
	/**
	 * The RSS class parses RSS formatted playlist files and returns a PlayList.
	 * It incorporates all changes and additions, starting with 
	 * the basic spec for RSS 0.91 (June 2000) and includes new features 
	 * introduced in RSS 0.92 (December 2000) and RSS 0.94 (August 2002). 
	 */
	public class RSS extends PlayList implements IPlaylistParser {
		
		public function isValid(ext:String, data:String):Boolean {
			var xml:XML = new XML(data);
			return (xml.localName().toString().toLowerCase() == "rss");
		}
		
		public function toPlayList(data:String):PlayList {
			var p:PlayList = new PlayList();
			var xml:XML = new XML(data);
			
			default xml namespace = xml.namespace();
			
			// 1.0 is structured differently from 0.9x and 2.0, becuase of that, it's not fully supported.
			var version:String = xml.@version;
			if (version == "1.0") trace("RSS - RSS 1.0 is not fully supported, attempting parse.");
			
			/*
			// Get Channel Header
			var objChannel:Object = new Object();
			// Required elements
			objChannel.title = xml..title.toString();
			objChannel.link = xml..link.toString();
			objChannel.description = xml..description.toString();
			// Optional elements
			if(xml..hasOwnProperty("language")) 		objChannel.language = 		xml..language.toString();
			if(xml..hasOwnProperty("copyright")) 		objChannel.copyright = 		xml..copyright.toString();
			if(xml..hasOwnProperty("managingEditor")) 	objChannel.managingEditor = xml..managingEditor.toString();
			if(xml..hasOwnProperty("webMaster")) 		objChannel.webMaster = 		xml..webMaster.toString();
			if(xml..hasOwnProperty("pubDate")) 			objChannel.pubDate = 		xml..pubDate.toString();
			if(xml..hasOwnProperty("lastBuildDate")) 	objChannel.lastBuildDate = 	xml..lastBuildDate.toString();
			if(xml..hasOwnProperty("category")) 		objChannel.category = 		xml..category.toString();
			if(xml..hasOwnProperty("generator")) 		objChannel.generator = 		xml..generator.toString();
			if(xml..hasOwnProperty("docs")) 			objChannel.docs = 			xml..docs.toString();
			if(xml..hasOwnProperty("cloud")) 			objChannel.cloud = 			xml..cloud.toString();
			if(xml..hasOwnProperty("ttl")) 				objChannel.ttl = 			xml..ttl.toString();
			if(xml..hasOwnProperty("image")) 			objChannel.image = 			xml..image.toString();
			if(xml..hasOwnProperty("rating")) 			objChannel.rating = 		xml..rating.toString();
			if(xml..hasOwnProperty("textInput")) 		objChannel.textInput = 		xml..textInput.toString();
			if(xml..hasOwnProperty("skipHours")) 		objChannel.skipHours = 		xml..skipHours.toString();
			if(xml..hasOwnProperty("skipDays")) 		objChannel.skipDays = 		xml..skipDays.toString();
			*/
			
			// Get Items
			for each (var item:XML in xml..item) {
				var o:Object = new Object();
				if(item.hasOwnProperty("title")) o.title = item.title.toString(); // The title of the item. i.e. Venice Film Festival Tries to Quit Sinking
				if(item.hasOwnProperty("link")) o.url = item.link.toString(); // The URL of the item. i.e. http://nytimes.com/2004/12/07FEST.html
				if(item.hasOwnProperty("description")) o.description = item.description.toString(); // The item synopsis.
				if(item.hasOwnProperty("author")) o.author = item.author.toString(); // Email address of the author of the item. i.e. oprah\@oxygen.net
				if(item.hasOwnProperty("category")) o.category = item.category.toString(); // Includes the item in one or more categories.
				if(item.hasOwnProperty("comments")) o.comments = item.comments.toString(); // URL of a page for comments relating to the item. i.e. http://www.myblog.org/cgi-local/mt/mt-comments.cgi?entry_id=290
				if(item.hasOwnProperty("enclosure")) o.enclosure = item.enclosure.toString(); // Describes a media object that is attached to the item.
				if(item.hasOwnProperty("guid")) o.guid = item.guid.toString(); // A string that uniquely identifies the item. i.e. http://inessential.com/2002/09/01.php#a2
				if(item.hasOwnProperty("pubDate")) o.pubDate = item.pubDate.toString(); // Indicates when the item was published. i.e. Sun, 19 May 2002 15:21:36 GMT
				if(item.hasOwnProperty("source")) o.source = item.source.toString(); // The RSS channel that the item came from.
				p.push(o);
			}
			
			default xml namespace = new Namespace("");
			
			return p;
		}
	}
}