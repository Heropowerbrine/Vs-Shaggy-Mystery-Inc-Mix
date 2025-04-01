package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flash.system.System;

class PauseSubState extends MusicBeatSubstate
{
	static final songData = [
		"where-are-you" => {displayName: "Where Are You (Mystery Inc Mix)", composer:"SamTheSly", charter:"TheZoroForce240"},
		"eruption" => {displayName: "Eruption (Mystery Inc Mix)", composer:"SicOn", charter:"TheOnlyVolume"},
		"kaio-ken" => {displayName: "Kaio Ken (Mystery Inc Mix)", composer:"TheOnlyVolume ft. Somf", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},

		"whats-new" => {displayName: "Whats New (real)", composer:"volume did this", charter:"and this"},
		"blast" => {displayName: "Blast (Mystery Inc Mix)", composer:"TheOnlyVolume", charter:"TheZoroForce240"},
		"super-saiyan" => {displayName: "Super Saiyan (Mystery Inc Mix)", composer:"SicOn", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},

		"god-eater" => {displayName: "GOD EATER (Mystery Inc Mix)", composer:"Rareblin", charter:"TheZoroForce240 (Canon), RhysRJJ (Mania)"},

		"power-link" => {displayName: "Power Link (Mystery Inc Mix)", composer:"ThatOneGuy ft. krayzoneX", charter:"TheOnlyVolume"},
		"revenge" => {displayName: "Revenge", composer:"TheOnlyVolume", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},
		"final-destination" => {displayName: "Final Destination (Mystery Inc Mix)", composer:"Rareblin", charter:"RhysRJJ (Canon), Syridias (Mania)"},

		"soothing-power" => {displayName: "Soothing Power (Mystery Inc Mix)", composer:"Ahloof", charter:"TheOnlyVolume"},
		"thunderstorm" => {displayName: "Thunderstorm (Mystery Inc Mix)", composer:"Atomified Productions", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},
		"dissasembler" => {displayName: "Dissasembler (Mystery Inc Mix)", composer:"Somf", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},

		"astral-calamity" => {displayName: "Astral Calamity (Mystery Inc Mix)", composer:"Leebert ft. TheOnlyVolume", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},

		"talladega" => {displayName: "Talladega (Mystery Inc Mix)", composer:"Rareblin ft. TheOnlyVolume", charter:"RhysRJJ (Canon), TheZoroForce240 (Mania)"},

		"big-shot" => {displayName: "Big Shot (Matt Mix)", composer:"TheOnlyVolume", charter:"RhysRJJ (Canon, Mania)"},
	];

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Toggle Practice Mode', 'Botplay', 'Exit to menu'];
	var difficultyChoices = ['MANIA', 'CANON', 'BACK'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;

	public function new(x:Float, y:Float)
	{
		super();
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficultyStuff.length) {
			/*
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
			*/
		}

		if (!WeekData.songHasMania[PlayState.SONG.song]) {
			menuItemsOG.remove('Change Difficulty');
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		if (songData.exists(PlayState.SONG.song.toLowerCase())) {
			levelInfo.text = songData.get(PlayState.SONG.song.toLowerCase()).displayName;
		} else {
			levelInfo.text = PlayState.displaySongName;
		}
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var artistText:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		if (songData.exists(PlayState.SONG.song.toLowerCase())) {
			artistText.text = "Artist: " + songData.get(PlayState.SONG.song.toLowerCase()).composer;
		} else {
			artistText.text = "idk";
		}
		artistText.scrollFactor.set();
		artistText.setFormat(Paths.font('vcr.ttf'), 32);
		artistText.updateHitbox();
		add(artistText);

		var charterText:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		if (songData.exists(PlayState.SONG.song.toLowerCase())) {
			charterText.text = "Charter: " + songData.get(PlayState.SONG.song.toLowerCase()).charter;
		} else {
			charterText.text = "idk";
		}
		charterText.scrollFactor.set();
		charterText.setFormat(Paths.font('vcr.ttf'), 32);
		charterText.updateHitbox();
		add(charterText);


		var levelDifficulty:FlxText = new FlxText(20, 15 + 96, 0, "", 32);
		levelDifficulty.text += difficultyChoices[PlayState.storyDifficulty];
		if (CoolUtil.difficultyStuff[PlayState.storyDifficulty][0] == "GOD") levelDifficulty.text = "GOD";
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var controls:FlxText = new FlxText(20, 15, 0, "Controls: ", 32);

		var cj = [0, 12, 12, 19];
		var controlArray = ClientPrefs.lastControls.copy();
		for (i in 0...Main.ammo[PlayState.mania])
		{
			if (PlayState.mania == 1 && i == 3) cj[1] ++;

			controls.text += InputFormatter.getKeyName(controlArray[(cj[PlayState.mania] + i) * 2]);

			if (i != Main.ammo[PlayState.mania] - 1) controls.text += '|';
		}

		controls.scrollFactor.set();
		controls.setFormat(Paths.font('vcr.ttf'), 32);
		controls.updateHitbox();
		controls.alpha = 0;
		add(controls);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 128, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 166, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		botplayText = new FlxText(20, FlxG.height - 40, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		artistText.alpha = 0;
		charterText.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		artistText.x = FlxG.width - (artistText.width + 20);
		charterText.x = FlxG.width - (charterText.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(artistText, {alpha: 1, y: artistText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(charterText, {alpha: 1, y: charterText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});

		FlxTween.tween(controls, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			for (i in 0...difficultyChoices.length-1) {
				if(difficultyChoices[i] == daSelected) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					PlayState.originallyPickedDiff = curSelected;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.cpuControlled = false;
					return;
				}
			} 

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.practiceMode = !PlayState.practiceMode;
					PlayState.usedPractice = true;
					practiceText.visible = PlayState.practiceMode;

					if (PlayState.SONG.song == 'Talladega' && PlayState.isStoryMode || CoolUtil.difficultyStuff[PlayState.storyDifficulty][0] == "GOD") System.exit(0);
				case "Restart Song":
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
				case 'Botplay':
					PlayState.cpuControlled = !PlayState.cpuControlled;
					PlayState.usedPractice = true;
					botplayText.visible = PlayState.cpuControlled;

					if (PlayState.SONG.song == 'Talladega' && PlayState.isStoryMode || CoolUtil.difficultyStuff[PlayState.storyDifficulty][0] == "GOD") System.exit(0);
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.usedPractice = false;
					PlayState.changedDifficulty = false;
					PlayState.cpuControlled = false;

					trace('COCKCKCKC');
					if (PlayState.SONG.song == 'Talladega' && PlayState.isStoryMode) System.exit(0);

				case 'BACK':
					menuItems = menuItemsOG;
					regenMenu();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0, 70 * i + 30, menuItems[i], true, false);
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}
}
