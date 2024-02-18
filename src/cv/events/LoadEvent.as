package cv.events {
	
	import flash.events.Event;
	
	/**
	 * The LoadEvent class defines events for TempoLite, AudioPlayer and VideoPlayer. 
	 * These events include the following:
	 * <ul>
	 * <li><code>LoadEvent.LOAD_START</code>: dispatched after a file has begun loading.</li>
	 * </ul>
	 *
     * @see cv.media.AudioPlayer AudioPlayer
     * @see cv.media.VideoPlayer VideoPlayer
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class LoadEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an  
		 * <code>loadStart</code> event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *    <tr>
         *      <th>Property</th>
         *      <th>Value</th>
         *    </tr>
		 *    <tr>
         *      <td><code>bubbles</code></td>
         *      <td><code>false</code></td></tr>
		 *    <tr><td><code>cancelable</code></td><td><code>false</code>; there is
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>time</code></td><td>The estimated duration of the media file.</td></tr>
		 * 	  <tr><td><code>url</code></td><td>TThe url of the item being loaded.</td></tr>
		 *    <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>index</code></td><td>The zero-based index in the DataProvider
		 * 			that contains the renderer.</td></tr>
		 * 	  <tr><td><code>item</code></td><td>A reference to the data that belongs to the renderer.</td></tr>
		 * 	  <tr><td><code>mediaType</code></td><td>The type of media being loaded, either "audio" or "video".</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
         *  </table>
         *
         * @eventType loadStart
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const LOAD_START:String = "loadStart";
		
		/**
         * Defines the value of the <code>type</code> property of an  
		 * <code>loadProgress</code> event object. 
         *
         * @eventType loadProgress
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const LOAD_PROGRESS:String = "loadProgress";
		
		/**
         * Defines the value of the <code>type</code> property of an  
		 * <code>loadComplete</code> event object. 
         *
         * @eventType loadComplete
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const LOAD_COMPLETE:String = "loadComplete";
		
		/**
		 * Gets the url of the item that is associated with this event.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var url:String;
		
		/**
		 * Gets the media type of the item that is associated with this event.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var mediaType:String;
		
		/**
		 * Gets the duration of the item that is associated with this event.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var time:Number;
		
		/**
		 * Creates a new LoadEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param url The url of the item being loaded.
         *
         * @param mediaType The type of media being loaded, either "audio" or "video".
         *
         * @param time The estimated duration of the media file.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, url:String = "", mediaType:String = "", time:Number= 0) {
			super(type, bubbles, cancelable);
			this.url = url;
			this.mediaType = mediaType;
			this.time = time;
		}
		
		/**
		 * Creates a copy of the LoadEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new LoadEvent object with parameter values that match those of the original.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function clone():Event {
			return new LoadEvent(type, bubbles, cancelable, url, mediaType, time);
		}
		
		/**
		 * Returns a string that contains all the properties of the LoadEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>LoadEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> url=<em>value</em>
		 * 	mediaType=<em>value</em> time=<em>value</em></code>]</p>
		 *
         * @return A string representation of the LoadEvent object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function toString():String {
			return formatToString("LoadEvent", "type", "bubbles", "cancelable", "url", "mediaType", "time", "eventPhase");
		}
	}
}