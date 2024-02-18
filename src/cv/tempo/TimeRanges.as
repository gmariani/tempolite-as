package cv.tempo {
	/**
	 * For getting the latest time that has been buffered, we need the buffered IDL attribute. It returns a 
	 * TimeRanges object which has a length attribute, a start() method and an end() method. In normal cases, 
	 * there will only be one range — the browser starts downloading from time 0, and the downloaded range 
	 * extends to however much is currently available. However, if the user seeks forward, the browser can 
	 * stop the current download and start a new request for a later part of the video. In this case, there 
	 * would be two ranges of buffered data.
	 * 
	 * The TimeRanges object's length IDL attribute returns how many ranges there are. The start() method 
	 * takes an argument index, where 0 represents the index of the first range, 1 represents the index of 
	 * the second range, and so forth. It returns the start time of the range with the given index. The end() 
	 * method similarly returns the end time of the range with the given index.
	 * 
	 * @author Gabriel Mariani
	 */
	public class TimeRanges {
		
		protected var _length:Number;
		protected var ranges:Array;
		
		public function TimeRanges() { }
		
		/**
		 * Returns the number of ranges in the object.
		 */
		public function get length():Number {
			return _length;
		}
		
		/**
		 * Returns the time for the start of the range with the given index.
		 * 
		 * Throws an IndexSizeError if the index is out of range.
		 * 
		 * @param	index
		 * @return
		 */
		public function start(index:Number):Number {
			//
		}
		
		/**
		 * Returns the time for the end of the range with the given index.
		 * 
		 * Throws an IndexSizeError if the index is out of range.
		 * 
		 * @param	index
		 * @return
		 */
		public function end(index:Number):Number {
			//
		}
	}
}