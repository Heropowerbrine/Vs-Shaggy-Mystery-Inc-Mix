package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";
	var godModeShit:Bool = false;

	public function new(x:Float, y:Float, camX:Float, camY:Float, soundShit:String = "")
	{
		var daBf:String = '';
		switch (PlayState.curStage)
		{
			case 'school' | 'schoolEvil':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}
		if (PlayState.SONG.player1 == "matt-player")
			{
				daBf = "matt-lost";
			}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		if (soundShit == "")
			add(bf);
		else 
			godModeShit = true;


		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		if (soundShit == "")
			FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		else 
			FlxG.sound.play(Paths.sound(soundShit));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
		#if mobile
		addVirtualPad(NONE, A_B);
		addVPadCam();
		#end
		if (godModeShit)
			_virtualpad.visible = false;
			endBullshit();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (godModeShit)
			return;
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT #if mobile || _virtualpad.buttonA.justPressed #end)
		{
			endBullshit();
		}

		if (controls.BACK #if mobile || _virtualpad.buttonB.justPressed #end)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			if (PlayState.isStoryMode)
				MusicBeatState.switchState(new StoryMenuState());
			else
				MusicBeatState.switchState(new FreeplayState());

			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			if (!godModeShit)
			{
				bf.playAnim('deathConfirm', true);
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			}
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
