package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	#if mobile
 	var _hitbox:FlxHitbox;
 	var _virtualpad:FlxVirtualPad;
 
 	public function addHitbox(?keyCount:Int = 3) {
 		_hitbox = new FlxHitbox(keyCount);
 
 		var camMobile = new FlxCamera();
 	    camMobile.bgColor.alpha = 0;
 		FlxG.cameras.add(camMobile, false);
 
 		_hitbox.cameras = [camMobile];
  		add(_hitbox);
 	}
 
 	public function addVirtualPad(?dpad:FlxDPadMode, ?action:FlxActionMode) {
 		_virtualpad = new FlxVirtualPad(dpad, action);
 		_virtualpad.alpha = ClientPrefs.data.controlsAlpha;
 		add(_virtualpad);
 	}
 
 	public function removeVirtualPad() {
 		remove(_virtualpad);
 	}
 
 	public function addVPadCam() {
 		var camMobile = new FlxCamera();
 		camMobile.bgColor.alpha = 0;
 		FlxG.cameras.add(camMobile, false);
 
 		_virtualpad.cameras = [camMobile];
 	}
 	#end

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		#if MODS_ALLOWED
		if(!ClientPrefs.imagesPersist) {
			Paths.customImagesLoaded.clear();
		}
		#end
		super.create();

		// Custom made Trans out
		if(!FlxTransitionableState.skipNextTransOut) {
			openSubState(new CustomFadeTransition(1, true));
		}
		FlxTransitionableState.skipNextTransOut = false;
	}

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.7, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
