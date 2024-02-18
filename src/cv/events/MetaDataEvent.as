package cv.events {
	
	import flash.events.Event;
	
	/**
	 * The MetaDataEvent class defines events for the AudioPlayer and VideoPlayer. 
	 * These events include the following:
	 * <ul>
	 * <li><code>MetaDataEvent.AUDIO_METADATA</code>: dispatched when the AudioPlayer has recieved metadata.</li>
	 * <li><code>MetaDataEvent.VIDEO_METADATA</code>: dispatched when the VideoPlayer has recieved metadata.</li>
	 * </ul>
	 *
     * @see cv.media.AudioPlayer AudioPlayer
     * @see cv.media.VideoPlayer VideoPlayer
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class MetaDataEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an <code>audioMetadata</code> 
		 * event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is 
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>data</code></td><td>The metadata object.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
		 *  </table>
         *
         * @eventType audioMetadata
		 *
         * @see #VIDEO_METADATA
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const AUDIO_METADATA:String = "audioMetadata";
		
		/**
         * Defines the value of the <code>type</code> property of an <code>videoMetadata</code> 
		 * event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is 
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>data</code></td><td>The metadata object.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
		 *  </table>
         *
         * @eventType videoMetadata
		 *
         * @see #AUDIO_METADATA
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const VIDEO_METADATA:String = "videoMetadata";
		
		/**
         * The reference to the metadata object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var data:Object;
		
		/**
		 * Creates a new MetaDataEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param data The metadata object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function MetaDataEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, data:Object = null) {
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		/**
		 * Creates a copy of the MetaDataEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new MetaDataEvent object with parameter values that match those of the original.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function clone():Event {
			return new MetaDataEvent(type, bubbles, cancelable, data);
		}
		
		/**
		 * Returns a string that contains all the properties of the MetaDataEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>MetaDataEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> data=<em>value</em></code>]</p>
		 *
         * @return A string representation of the MetaDataEvent object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function toString():String {
			return formatToString("MenuEvent", "type", "bubbles", "cancelable", "data", "eventPhase");
		}
	}
}