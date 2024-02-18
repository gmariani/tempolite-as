package com.coursevector.tempo.view.events {

	public class PlayerEvent {
		
		// Types
		public static const MAINTAIN_ASPECT_RATIO:String = "maintainAspectRatio";
		public static const NO_SCALE:String = "noScale";
		public static const EXACT_FIT:String = "exactFit";
		public static const REPEAT_ALL:String = "all";
		public static const REPEAT_TRACK:String = "track";
		public static const REPEAT_NONE:String = "none";
		public static const VIDEO:String = "video";
		public static const AUDIO:String = "audio";
		
		// Events
		public static const PLAY:String = "play";
		public static const STOP:String = "stop";
		public static const PAUSE:String = "pause";
		public static const NEXT:String = "next";
		public static const PREVIOUS:String = "previous";
		public static const VOLUME:String = "volume";
		public static const MUTE:String = "mute";
		public static const SHUFFLE:String = "shuffle";
		public static const REPEAT:String = "repeat";
		public static const SEEK:String = "seek";
		public static const NO_SONG:String = "noSong";
		public static const SET_SCREEN:String = "setScreen";
	}
}