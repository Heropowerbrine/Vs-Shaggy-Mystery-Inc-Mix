package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var lastNoteType:Int = -1;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, noteType:Int = 0) {
		
		alpha = 0.6;

		if(lastNoteType != noteType) {
			var skin:String = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

			switch(noteType) {
				case 3: //Hurt note
					loadAnims('HURT' + skin);

				default:
					loadAnims(skin);
			}
			lastNoteType = noteType;
		}

		switch(noteType) {
			case 3:
				colorSwap.hue = 0;
				colorSwap.saturation = 0;
				colorSwap.brightness = 0;
			
			default:
				colorSwap.hue = ClientPrefs.arrowHSV[note % 4][0] / 360;
				colorSwap.saturation = ClientPrefs.arrowHSV[note % 4][1] / 100;
				colorSwap.brightness = ClientPrefs.arrowHSV[note % 4][2] / 100;
		}

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		scale.set(Note.scales[PlayState.mania] / 0.7, Note.scales[PlayState.mania] / 0.7);
		updateHitbox();

		var w = Note.swidths[0] * Note.scales[PlayState.mania];
		setPosition(x + (w/2) - (width/2), y + (w/2) - (height/2));
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note0-" + i, "note impact " + i + " purple", 24, false);
			animation.addByPrefix("note1-" + i, "note impact " + i + " blue", 24, false);
			animation.addByPrefix("note2-" + i, "note impact " + i + " green", 24, false);
			animation.addByPrefix("note3-" + i, "note impact " + i + " red", 24, false);
			animation.addByPrefix("note4-" + i, "note impact " + i + " white", 24, false);
			animation.addByPrefix("note5-" + i, "note impact " + i + " yellow", 24, false);
			animation.addByPrefix("note6-" + i, "note impact " + i + " violet", 24, false);
			animation.addByPrefix("note7-" + i, "note impact " + i + " darkred", 24, false);
			animation.addByPrefix("note8-" + i, "note impact " + i + " dark0", 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}