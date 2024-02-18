/**
 * 
 * A Winamp skin for Tempo.
 * 
 * TODO: 
 *      Add player state. So icons will be highlighted based on status of player
 *      Draggable windows
 *      Shrink file size
 * 
 * v1.0 Initial Release
 * 
 * @author Gabriel Mariani
 * @version 1.0
*/

package {
	
	import fl.controls.List;
	import fl.controls.ProgressBar;
	import flash.events.TimerEvent;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;

	import com.coursevector.display.SpectrumAnalyzer;
	import com.coursevector.display.Oscilloscope;
	import WinampCellRenderer;

	public class WinampSkin extends MovieClip {
		
		private var txtTitle:TextField;
		private var txtArtist:TextField;
		private var txtTicker:TextField;
		private var txtTime:TextField;
		private var txtTimeDown:TextField;
		private var txtTimeTotal:TextField;
		private var songTicker:Boolean = false;
		private var infoTimer:Timer = new Timer(1500, 1);
		private var songTickerTimer:Timer = new Timer(100);
		private var Prev_Icon:MovieClip;
		private var Play_Icon:MovieClip;
		private var Pause_Icon:MovieClip;
		private var Stop_Icon:MovieClip;
		private var Next_Icon:MovieClip;
		private var mcShuffle:MovieClip;
		private var mcMute:MovieClip;
		private var mcRepeat:MovieClip;
		private var display_mask:MovieClip;
		private var mcDisplayTop:MovieClip;
		private var playerTitleBar:MovieClip;
		private var playlistTitleBar:MovieClip;
		private var btnPL:SimpleButton;
		private var PL_Icon:MovieClip;
		private var sprVisual:Sprite = new Sprite();
		private var specAn:SpectrumAnalyzer = new SpectrumAnalyzer();
		private var osc:Oscilloscope = new Oscilloscope();
		private var song_list:List;
		private var load_bar:ProgressBar;
		private var volume_slider:MovieClip;
		private var _strTotal:String;
		
		public function WinampSkin():void {
			init();
		}
		
		private function init():void {
			
			sprVisual.x = 217.7;
			sprVisual.y = 50;
			sprVisual.addEventListener(MouseEvent.CLICK, visualizerHandler);
			
			// Spectrum Analyzer
			specAn.barWidth = 3;
			specAn.barAmount = 18;
			specAn.lineSpace = 1.9;
			specAn.showPeaks = true;
			specAn.plotHeight = 25;
			sprVisual.addChild(specAn);
			
			// Oscilloscope
			osc.lineColor = 0xFFFFFF;
			osc.soundChannel = Oscilloscope.COMBINED;
			osc.numChannels = 36;
			osc.lineStyle = Oscilloscope.LINES;
			osc.plotHeight = 12.5;
			osc.alpha = .5;
			osc.y = 2;
			osc.visible = false;
			sprVisual.addChild(osc);
			
			// Hit Area
			var sprHitArea:Sprite = new Sprite();
			sprHitArea.graphics.beginFill(0xFFFFFF, 0);
			sprHitArea.graphics.drawRect(0, 0, 70, 23);
			sprHitArea.graphics.endFill();
			sprVisual.addChild(sprHitArea);
			
			player.addChild(sprVisual);
			
			Prev_Icon = player.getChildByName("Prev_Icon") as MovieClip;
			Prev_Icon.mouseEnabled = false;
			
			Play_Icon = player.getChildByName("Play_Icon") as MovieClip;
			Play_Icon.mouseEnabled = false;
			
			Pause_Icon = player.getChildByName("Pause_Icon") as MovieClip;
			Pause_Icon.mouseEnabled = false;
			
			Stop_Icon = player.getChildByName("Stop_Icon") as MovieClip;
			Stop_Icon.mouseEnabled = false;
			
			Next_Icon = player.getChildByName("Next_Icon") as MovieClip;
			Next_Icon.mouseEnabled = false;
			
			display_mask = player.getChildByName("display_mask") as MovieClip;
			display_mask.mouseEnabled = false;
			
			mcDisplayTop = player.getChildByName("mcDisplayTop") as MovieClip;
			mcDisplayTop.mouseEnabled = false;
			
			volume_slider = player.getChildByName("volume_slider") as MovieClip;
			volume_slider.addEventListener(Event.CHANGE, changeHandler);
			
			txtTimeTotal = player.getChildByName("txtTimeTotal") as TextField;
			txtTimeTotal.addEventListener(Event.CHANGE, changeHandler);
			txtTimeTotal.visible = false;
			
			txtTime = player.getChildByName("txtTime") as TextField;
			txtTime.addEventListener(MouseEvent.CLICK, clickHandler);
			txtTime.addEventListener(Event.CHANGE, changeHandler);
			
			txtTimeDown = player.getChildByName("txtTimeDown") as TextField;
			txtTimeDown.visible = false;
			txtTimeDown.addEventListener(Event.CHANGE, changeHandler);
			txtTimeDown.addEventListener(MouseEvent.CLICK, clickHandler);
			
			txtTitle = player.getChildByName("txtTitle") as TextField;
			txtTitle.addEventListener(Event.CHANGE, changeHandler);
			txtTitle.visible = false;
			
			txtArtist = player.getChildByName("txtArtist") as TextField;
			txtArtist.addEventListener(Event.CHANGE, changeHandler);
			txtArtist.visible = false;
			
			txtTicker = player.getChildByName("txtTicker") as TextField;
			txtTicker.autoSize = TextFieldAutoSize.LEFT;
			
			mcShuffle = player.getChildByName("mcShuffle") as MovieClip;
			mcShuffle.addEventListener(MouseEvent.CLICK, clickHandler);
			
			mcMute = player.getChildByName("mcMute") as MovieClip;
			mcMute.addEventListener(MouseEvent.CLICK, clickHandler);
			
			mcRepeat = player.getChildByName("mcRepeat") as MovieClip;
			mcRepeat.addEventListener(MouseEvent.CLICK, clickHandler);
			
			infoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, timerHandler);
			
			songTickerTimer.addEventListener(TimerEvent.TIMER, tickerHandler);
			
			// Configure List
			var tf:TextFormat = new TextFormat();
			tf.color = 0xFFFFFF;
			
			song_list = playlist.getChildByName("song_list") as List;
			song_list.setStyle("cellRenderer", WinampCellRenderer);
			song_list.setRendererStyle("textFormat", tf);
			
			song_list.setStyle("skin", Winamp_List_skin);
			
			song_list.setStyle("downArrowDisabledSkin", Winamp_ScrollArrowDown_skin);
			song_list.setStyle("downArrowDownSkin", Winamp_ScrollArrowDown_skin);
			song_list.setStyle("downArrowOverSkin", Winamp_ScrollArrowDown_skin);
			song_list.setStyle("downArrowUpSkin", Winamp_ScrollArrowDown_skin);
			
			song_list.setStyle("focusRectSkin", Winamp_focusRectSkin);
			
			song_list.setStyle("thumbDisabledSkin", Winamp_ScrollThumb_skin);
			song_list.setStyle("thumbDownSkin", Winamp_ScrollThumb_skin);
			song_list.setStyle("thumbOverSkin", Winamp_ScrollThumb_skin);
			song_list.setStyle("thumbUpSkin", Winamp_ScrollThumb_skin);
			
			song_list.setStyle("trackDisabledSkin", Winamp_ScrollTrack_skin);
			song_list.setStyle("trackDownSkin", Winamp_ScrollTrack_skin);
			song_list.setStyle("trackOverSkin", Winamp_ScrollTrack_skin);
			song_list.setStyle("trackUpSkin", Winamp_ScrollTrack_skin);
			
			song_list.setStyle("upArrowDisabledSkin", Winamp_ScrollArrowUp_skin);
			song_list.setStyle("upArrowDownSkin", Winamp_ScrollArrowUp_skin);
			song_list.setStyle("upArrowOverSkin", Winamp_ScrollArrowUp_skin);
			song_list.setStyle("upArrowUpSkin", Winamp_ScrollArrowUp_skin);
			
			song_list.setStyle("thumbIcon", Winamp_ScrollBar_thumbIcon);
			
			// Configure Loadbar
			initProgressBar();
			
			// Add draggability
			playerTitleBar = player.getChildByName("mcTitle") as MovieClip;
			playerTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, dragHandler);
			playerTitleBar.addEventListener(MouseEvent.MOUSE_UP, dragHandler);
			
			playlistTitleBar = playlist.getChildByName("mcTitle") as MovieClip;
			playlistTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, dragHandler);
			playlistTitleBar.addEventListener(MouseEvent.MOUSE_UP, dragHandler);
			
			// Init PlayList Button
			playlist.visible = false;
			var mcMLPL:MovieClip = player.getChildByName("MLPL_mc") as MovieClip;
			PL_Icon = mcMLPL.getChildByName("PL_Icon") as MovieClip;
			PL_Icon.visible = false;
			btnPL = mcMLPL.getChildByName("play_list") as SimpleButton;
			btnPL.addEventListener(MouseEvent.CLICK, plHandler);
		}
		
		private function initProgressBar():void {
			load_bar = player.getChildByName("load_bar") as ProgressBar;
			load_bar.indeterminate = false;
			load_bar.setStyle("trackSkin", Winamp_ProgressBar_trackSkin);
			//load_bar.setStyle("indeterminateSkin", Winamp_ProgressBar_indeterminateSkin);
			load_bar.setStyle("barSkin", Winamp_ProgressBar_barSkin);
		}
		
		private function changeTitle(msg:String):void {
			songTickerTimer.stop();
			txtTicker.text = msg;
			centerTitle();
			
			if(infoTimer.running) infoTimer.stop();
			infoTimer.start();
		}
		
		private function resetTitle():void {
			txtTicker.text = (txtArtist.text != "") ? txtArtist.text + " - " + txtTitle.text : txtTitle.text;
			if (txtTimeTotal.text != "") txtTicker.appendText(" (" + txtTimeTotal.text + ")");
		}
		
		private function centerTitle():void {
			var rectBounds:Rectangle = display_mask.getBounds(player);
			txtTicker.x = (((rectBounds.right - rectBounds.left) / 2) + rectBounds.left) - (txtTicker.textWidth / 2);
		}
		
		private function plHandler(e:MouseEvent):void {
			playlist.visible = !playlist.visible;
			PL_Icon.visible = playlist.visible;
		}
		
		private function dragHandler(e:MouseEvent):void {
			if(e.type == MouseEvent.MOUSE_DOWN) {
				e.currentTarget.parent.startDrag();
			} else {
				e.currentTarget.parent.stopDrag();
			}
		}
		
		private function changeHandler(e:Event):void {
			switch(e.currentTarget) {
				case txtTime:
					var strMin:String = txtTime.text.split(":")[0];
					if(strMin.length < 2) txtTime.text = "0" + txtTime.text;
					break;
				case txtTimeDown:
					var arrTime:Array = txtTimeDown.text.split(":");
					var strMinDown:String = arrTime[0];
					strMinDown = strMinDown.substr(1);
					if(strMinDown.length < 2) txtTimeDown.text = "-0" + strMinDown + ":" + arrTime[1];
					break;
				case txtTitle:
					resetTitle();
					if(!songTickerTimer.running) songTickerTimer.start();
					break;
				case txtArtist:
					resetTitle();
					break;
				case txtTimeTotal:
					if (txtTimeTotal.text != _strTotal) {
						_strTotal = txtTimeTotal.text;
						resetTitle();
					}
					break;
				case volume_slider:
					changeTitle("VOLUME: " + Math.ceil(volume_slider.value * 100) + "%");
					break;
			}
		}
		
		private function clickHandler(e:MouseEvent):void {
			switch(e.currentTarget) {
				case txtTime:
				case txtTimeDown:
					txtTime.visible = !txtTime.visible;
					txtTimeDown.visible = !txtTimeDown.visible;
					break;
				case mcShuffle:
					if (mcShuffle.currentFrame == 1) {
						changeTitle("PLAYLIST SHUFFLING: ON");
					} else {
						changeTitle("PLAYLIST SHUFFLING: OFF");
					}
					break;
				case mcRepeat:
					if(mcRepeat.currentFrame == 1) {
						changeTitle("REPEAT: ALL");
					} else {
						changeTitle("REPEAT: TRACK");
					}
					break;
				case mcMute:
					if(mcMute.currentFrame == 1) {
						changeTitle("MUTE ON");
					} else {
						changeTitle("MUTE OFF");
					}
					break;
			}
		}
		
		private function timerHandler(e:TimerEvent):void {
			centerTitle();
			resetTitle();
			songTickerTimer.start();
		}
		
		private function tickerHandler(e:TimerEvent):void {
			var rectBounds:Rectangle = display_mask.getBounds(player);
			if (txtTicker.textWidth > 290) {
				if (!songTicker) {
					if ((txtTicker.x + txtTicker.width) > rectBounds.right) {
						txtTicker.x -= 2;
					} else {
						songTicker = true;
					}
				} else {
					if (txtTicker.x < rectBounds.left) {
						txtTicker.x += 2;
					} else {
						songTicker = false;
					}
				}
			} else {
				centerTitle();
			}
		}
		
		private function visualizerHandler(e:MouseEvent):void {
			if(specAn.visible == true) {
				specAn.visible = false;
				osc.visible = true;
			} else if(osc.visible == true) {
				osc.visible = false;
				specAn.visible = false;
			} else {
				specAn.visible = true;
				osc.visible = false;
			}
		}
	}
}