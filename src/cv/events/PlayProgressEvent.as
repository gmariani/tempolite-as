package cv.events {
	
	import flash.events.Event;
	
	/**
	 * The PlayProgressEvent class defines events for the AudioPlayer and VideoPlayer. 
	 * These events include the following:
	 * <ul>
	 * <li><code>PlayProgressEvent.PLAY_PROGRESS</code>: dispatched constantly during playback.</li>
	 * </ul>
	 *
     * @see cv.media.AudioPlayer AudioPlayer
     * @see cv.media.VideoPlayer VideoPlayer
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class PlayProgressEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an <code>playProgress</code> 
		 * event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is 
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>percent</code></td><td>The percentage of progress for the media playing.</td></tr>
		 * 	  <tr><td><code>elapsed</code></td><td>The elapsed time of the media playing.</td></tr>
		 * 	  <tr><td><code>remain</code></td><td>The remaining time of the media playing.</td></tr>
		 * 	  <tr><td><code>total</code></td><td>The total time of the media playing.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
		 *  </table>
         *
         * @eventType playProgress
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const PLAY_PROGRESS:String = "playProgress";
		
		public static const PLAY_START:String = "playStart";
		
		public static const PLAY_COMPLETE:String = "playComplete";
		
		public static const STATUS:String = "status";
		
		/**
         * The reference to the percentage of progress for the media playing.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var percent:uint;
		
		/**
         * The reference to the elapsed time of the media playing.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var elapsed:Number;
		
		/**
         * The reference to the remaining time of the media playing.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var remain:Number;
		
		/**
         * The reference to the total time of the media playing.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var total:Number;
		
		/**
		 * Creates a new PlayProgressEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param percent The play progress in terms of percent.
		 * 
         * @param elapsed The time elapsed in terms of milliseconds.
		 * 
         * @param remain The time remaining in terms of milliseconds.
		 * 
         * @param total The total time in terms of milliseconds.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function PlayProgressEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, percent:uint=0, elapsed:Number=0, remain:Number=0, total:Number=0) {
			super(type, bubbles, cancelable);
			this.percent = percent;
			this.elapsed = elapsed;
			this.remain = remain;
			this.total = total;
		}
		
		/**
		 * Creates a copy of the PlayProgressEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new PlayProgressEvent object with parameter values that match those of the original.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function clone():Event {
			return new PlayProgressEvent(type, bubbles, cancelable, percent, elapsed, remain, total);
		}
		
		/**
		 * Returns a string that contains all the properties of the PlayProgressEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>PlayProgressEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> percent=<em>value</em> elapsed=<em>value</em> remain=<em>value</em> total=<em>value</em></code>]</p>
		 *
         * @return A string representation of the PlayProgressEvent object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function toString():String {
			return formatToString("LoadEvent", "type", "bubbles", "cancelable", "percent", "elapsed", "remain", "total", "eventPhase");
		}
	}
}