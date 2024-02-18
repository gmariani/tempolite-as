/**
 * 
 * A Zune skin for Tempo.
 * 
 * 
 * v1.0 Initial Release
 * 
 * @author Gabriel Mariani
 * @version 1.0
*/

package {
	
	import flash.display.MovieClip;
	import gs.TweenLite;
	import com.coursevector.controls.Slider;
	import fl.events.SliderEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;

	public class ZuneSkin extends MovieClip {
		
		private var txtTitle:TextField;
		private var txtAlbum:TextField;
		private var txtArtist:TextField;
		private var txtTimeSeek:TextField;
		private var txtVolume:TextField;
		private var txtVolume2:TextField;
		private var sliderPlayHead:Slider;
		private var sliderVolume:Slider;
		private var mcVolume:MovieClip;
		private var mcVolume2:MovieClip;
		private var mcMute:MovieClip;
		private var mcHitArea:MovieClip;
		private var tmr:Timer = new Timer(3500);
		private var tmrVolume:Timer = new Timer(500, 1);
		private var tmrMouseCheck:Timer = new Timer(100);
		private var _volume:Number;
		
		public function ZuneSkin():void {
			init();
		}
		
		private function init():void {
			txtTitle = player.getChildByName("txtTitle") as TextField;
			txtAlbum = player.getChildByName("txtAlbum") as TextField;
			txtArtist = player.getChildByName("txtArtist") as TextField;
			txtTimeSeek = player.getChildByName("txtTimeSeek") as TextField;
			sliderPlayHead = player.getChildByName("playhead_slider") as Slider;
			mcVolume = player.getChildByName("mcVolume") as MovieClip;
			mcVolume2 = player.getChildByName("mcVolume2") as MovieClip;
			txtVolume = mcVolume.getChildByName("txtVolume") as TextField;
			txtVolume2 = mcVolume2.getChildByName("txtVolume2") as TextField;
			sliderVolume = player.getChildByName("volume_slider") as Slider;
			mcMute = player.getChildByName("mcMute") as MovieClip;
			mcHitArea = player.getChildByName("mcHitArea") as MovieClip;
			
			// TITLES //
			txtTitle.addEventListener(MouseEvent.CLICK, clickHandler);
			
			txtAlbum.visible = false;
			txtAlbum.alpha = 0;
			txtAlbum.addEventListener(MouseEvent.CLICK, clickHandler);
			
			txtArtist.visible = false;
			txtArtist.alpha = 0;
			txtArtist.addEventListener(MouseEvent.CLICK, clickHandler);
			
			tmr.addEventListener(TimerEvent.TIMER, timerHandler);
			tmr.start();
			
			tmrMouseCheck.addEventListener(TimerEvent.TIMER, timerHandler3);
			tmrMouseCheck.start();
			
			tmrVolume.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler2);
			
			// Seek //
			sliderPlayHead.addEventListener(SliderEvent.THUMB_PRESS, playheadHandler);
			sliderPlayHead.addEventListener(SliderEvent.THUMB_RELEASE, playheadHandler);
			txtTimeSeek.visible = false;
			txtTimeSeek.alpha = 0;
			//
			
			// Volume //
			sliderVolume.alpha = 0;
			sliderVolume.visible = false;
			sliderVolume.addEventListener(Event.CHANGE, changeHandler);
			
			mcVolume2.alpha = 0;
			mcVolume2.visible = false;
			
			mcVolume.mouseChildren = false;
			mcVolume.addEventListener(MouseEvent.MOUSE_OVER, volumeHandler);
			
			mcMute.alpha = 0;
			mcMute.visible = false;
			//mcMute.addEventListener(MouseEvent.MOUSE_UP, muteHandler);
		}
		
		private function clickHandler(e:MouseEvent):void {
			tmr.stop();
			timerHandler();
			tmr.start();
		}
		
		private function changeHandler(e:Event):void {
			//setVolumeText(Math.ceil(sliderVolume.value * 100));
			timerReset();
		}
		
		private function setVolumeText(n:int):void {
			txtVolume.text = "VOLUME " + n;
			txtVolume2.text = String(n);
		}
		
		/*private function muteHandler(e:MouseEvent):void {
			if(mcMute.currentFrame == 1) {
				_volume = Math.ceil(sliderVolume.value * 100);
				setVolumeText(0);
			} else {
				setVolumeText(_volume);
			}
		}*/
		
		private function volumeHandler(e:MouseEvent):void {
			timerReset();
		}
		
		private function timerReset():void {
			if(tmrVolume.running) {
				tmrVolume.reset();
			} else {
				tmrVolume.start();
			}
		}
		
		private function timerHandler(e:TimerEvent = null):void {
			if(txtTitle.visible == true) {
				TweenLite.to(txtTitle, .25, {autoAlpha:0});
				TweenLite.to(txtAlbum, .25, {autoAlpha:1});
				TweenLite.to(txtArtist, .25, {autoAlpha:0});
			} else if(txtAlbum.visible == true) {
				TweenLite.to(txtTitle, .25, {autoAlpha:0});
				TweenLite.to(txtAlbum, .25, {autoAlpha:0});
				TweenLite.to(txtArtist, .25, {autoAlpha:1});
			} else {
				TweenLite.to(txtTitle, .25, {autoAlpha:1});
				TweenLite.to(txtAlbum, .25, {autoAlpha:0});
				TweenLite.to(txtArtist, .25, {autoAlpha:0});
			}
		}
		
		private function timerHandler2(e:TimerEvent = null):void {
			if(mcVolume.visible) {
				mcVolume.mouseEnabled = false;
				TweenLite.to(mcVolume, .5, {autoAlpha:0, scaleX: 0, scaleY: 0});
				TweenLite.to(sliderVolume, .5, {autoAlpha:1, scaleX: 1, scaleY: 1});
				TweenLite.to(mcMute, .5, {autoAlpha:1, scaleX: 1, scaleY: 1});
				TweenLite.to(mcVolume2, .5, {autoAlpha:1, scaleX: 1, scaleY: 1});
			} else {
				mcVolume.mouseEnabled = true;
				TweenLite.to(mcVolume, .5, {autoAlpha:1, scaleX: 1, scaleY: 1});
				TweenLite.to(sliderVolume, .5, {autoAlpha:0, scaleX: 0, scaleY: 0});
				TweenLite.to(mcMute, .5, {autoAlpha:0, scaleX:0, scaleY:0});
				TweenLite.to(mcVolume2, .5, {autoAlpha:0, scaleX:0, scaleY:0});
			}
		}
		
		private function timerHandler3(e:TimerEvent = null):void {
			if(!mcMute.hitTestPoint(mouseX, mouseY) && !mcVolume2.hitTestPoint(mouseX, mouseY) && !sliderVolume.hitTestPoint(mouseX, mouseY)) {
				if(!mcVolume.visible) {
					if(!tmrVolume.running) tmrVolume.start();
				}
			} else {
				tmr.stop();
			}
			setVolumeText(Math.ceil(sliderVolume.value * 100));
		}
		
		private function playheadHandler(e:Event):void {
			if(e.type == SliderEvent.THUMB_PRESS) {
				TweenLite.to(txtTimeSeek, .75, {autoAlpha:1});
			} else if(e.type == SliderEvent.THUMB_RELEASE) {
				TweenLite.to(txtTimeSeek, .25, {autoAlpha:0});
			}
		}
	}
}