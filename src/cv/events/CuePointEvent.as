package cv.events {
	
	import flash.events.Event;
	
	/**
	 * The CuePointEvent class defines events for the VideoPlayer. 
	 * These events include the following:
	 * <ul>
	 * <li><code>CuePointEvent.CUE_POINT</code>: dispatched when the VideoPlayer has encountered a cue point.</li>
	 * </ul>
	 *
     * @see cv.media.VideoPlayer VideoPlayer
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class CuePointEvent extends Event {
		
		/**
         * Defines the value of the <code>type</code> property of an <code>cuePoint</code> 
		 * event object. 
		 * 
		 * <p>This event has the following properties:</p>
		 *  <table class="innertable" width="100%">
		 *     <tr><th>Property</th><th>Value</th></tr>
		 *     <tr><td><code>bubbles</code></td><td><code>false</code></td></tr>
		 *     <tr><td><code>cancelable</code></td><td><code>false</code>; there is 
		 *          no default behavior to cancel.</td></tr>	
		 * 	  <tr><td><code>cuePoint</code></td><td>The cue point object.</td></tr>
		 *     <tr><td><code>currentTarget</code></td><td>The object that is actively processing 
         *          the event object with an event listener.</td></tr>
		 * 	  <tr><td><code>target</code></td><td>The object that dispatched the event. The target is 
         *           not always the object listening for the event. Use the <code>currentTarget</code>
		 * 			property to access the object that is listening for the event.</td></tr>
		 *  </table>
         *
         * @eventType cuePoint
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static const CUE_POINT:String = "cuePoint";
		
		/**
         * The reference to the cue point object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var cuePoint:Object;
		
		/**
		 * Creates a new CuePointEvent object with the specified parameters. 
		 * 
         * @param type The event type; this value identifies the action that caused the event.
         *
         * @param bubbles Indicates whether the event can bubble up the display list hierarchy.
         *
         * @param cancelable Indicates whether the behavior associated with the event can be
		 *        prevented. 
		 * 
         * @param cuePoint The cue point object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function CuePointEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, cuePoint:Object = null) {
			super(type, bubbles, cancelable);
			this.cuePoint = cuePoint;
		}
		
		/**
		 * Creates a copy of the CuePointEvent object and sets the value of each parameter to match
		 * the original.
		 *
         * @return A new CuePointEvent object with parameter values that match those of the original.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function clone():Event {
			return new CuePointEvent(type, bubbles, cancelable, cuePoint);
		}
		
		/**
		 * Returns a string that contains all the properties of the CuePointEvent object. The string
		 * is in the following format:
		 * 
		 * <p>[<code>CuePointEvent type=<em>value</em> bubbles=<em>value</em>
		 * 	cancelable=<em>value</em> cuePoint=<em>value</em></code>]</p>
		 *
         * @return A string representation of the CuePointEvent object.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function toString():String {
			return formatToString("CuePointEvent", "type", "bubbles", "cancelable", "cuePoint", "eventPhase");
		}
	}
}