package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	public var noteData:Int = 0;
	public var sustainSplash:SustainSplash;

	public function new(x:Float, y:Float, leData:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		super(x, y);

		sustainSplash = new SustainSplash(this);
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		updateHitbox();
		offset.x = frameWidth / 2;
		offset.y = frameHeight / 2;

		offset.x -= 156 * Note.scales[PlayState.SONG.mania] / 2;
		offset.y -= 156 * Note.scales[PlayState.SONG.mania] / 2;
		//centerOffsets();
		/*
		if(animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
		} else {
			colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;

			if(animation.curAnim.name == 'confirm' && !PlayState.curStage.startsWith('school')) {
				offset.x -= 13;
				offset.y -= 13;
			}
		}
		*/
	}
}

class SustainSplash extends FlxSprite {
	public var strum:StrumNote;
	final noteColors:Array<String> = ["Purple", "Blue", "Green", "Red", "White", "Yellow", "Violet", "Darkred", "Dark"];
	override public function new(strum:StrumNote) {
		super();
		this.strum = strum;

		var color = noteColors[Main.gfxIndex[PlayState.mania][strum.noteData]];

		frames = Paths.getSparrowAtlas("holdCover" + color);
		animation.addByPrefix('cover', 'holdCoverStart'+color, 24, false);
		animation.addByPrefix('splash', 'holdCoverEnd'+color, 24, false);
		animation.addByPrefix('loop', 'holdCover'+color, 24);
		animation.play("loop");
		updateHitbox();
		visible = false;
		antialiasing = true;

		scale.set(Note.scales[PlayState.mania] / 0.7, Note.scales[PlayState.mania] / 0.7);
		updateHitbox();
	}

	public var updatedThisFrame:Bool = false;

	public inline function show() {
		updatedThisFrame = true;
		visible = true;
		if (animation.curAnim.name != "loop") {
			animation.play("cover");
			center();
		}
	}
	public inline function hide(miss:Bool = false) {
		if (animation.curAnim.name == "splash") return;

		updatedThisFrame = true;
		if (miss) visible = false;
		if (animation.curAnim.name != "splash") {
			animation.play("splash");
			center();
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (animation.curAnim.finished) {
			if (animation.curAnim.name == "cover") animation.play("loop");
			if (animation.curAnim.name == "splash") visible = false;
		}
		
		//if (animation.curAnim.name != "splash") center();
		//updateHitbox();
		center();
	}

	public function center() {
		//centerOffsets();
		var w = Note.swidths[0] * Note.scales[PlayState.mania];
		x = strum.x + ((w/2) - (width/2)) - (15 * scale.x);
		y = strum.y + ((w/2) - (height/2)) + (45 * scale.y);
	}
}