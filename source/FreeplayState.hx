package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class FreeplayState extends MusicBeatState
{
	//Character head icons for your songs
	static var songsHeads:Array<Dynamic> = [
		['dad'],							//Week 1
		['spooky', 'spooky', 'monster'],	//Week 2
		['pico'],							//Week 3
		['mom'],							//Week 4
		['parents', 'parents', 'monster'],	//Week 5
		['senpai', 'senpai', 'spirit']		//Week 6
	];

	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	public static var coolColors:Array<Int> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var menuCol:FlxSprite;
	var sxmBG:FlxSprite;

	var letter:FlxSprite;
	var bigLetter:FlxSprite;

	var cmd_screen:FlxSprite;
	var cmd_text:FlxText;

	var hb_text_small:FlxSprite;
	var hb_bg:FlxSprite;
	var rot:Float = 0;

	var hb_big_border:FlxSprite;
	var hb_big_bg:FlxSprite;
	var hb_big_text:FlxSprite;
	var hb_flash:FlxSprite;

	var hb_water:FlxSprite;
	var hb_water_back:FlxSprite;

	var hb_step:Int = 0;

	var hb_big_size:Array<Float> = [100, 100];

	var wiiCursor:FlxSprite;

	override function create()
	{
		CoolUtil.difficultyStuff = CoolUtil.defaultDifficulty.copy();
		wiiCursor = new FlxSprite(0, 0).loadGraphic(Paths.image('wii_cursor'));
		wiiCursor.updateHitbox();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length)
		{
			var songArray:Array<String> = initSonglist[i].split(":");

			var skip = false;
			var sng = songArray[0];
			if ((sng == 'Talladega' || sng == 'BIG-SHOT') && !FlxG.save.data.ending[2]) skip = true;
			
			if (!skip)
			{
				addSong(songArray[0], 0, songArray[1]);
				songs[songs.length-1].color = Std.parseInt(songArray[2]);
			}
		}
		var colorsList = CoolUtil.coolTextFile(Paths.txt('freeplayColors'));
		for (i in 0...colorsList.length)
		{
			coolColors.push(Std.parseInt(colorsList[i]));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		/*
		for (i in 1...WeekData.songsNames.length) {
			#if !debug
			if (StoryMenuState.weekUnlocked[i])
			#end
				addWeek(WeekData.songsNames[i], i, songsHeads[i-1]);
		}
		*/

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.screenCenter(X);
		bg.screenCenter(Y);
		add(bg);

		menuCol = new FlxSprite().loadGraphic(Paths.image('menuColor'));
		add(menuCol); menuCol.screenCenter();
		sxmBG = new FlxSprite().loadGraphic(Paths.image('menuBG-wii'));
		add(sxmBG); sxmBG.screenCenter();
		sxmBG.x = FlxG.width - 1280;
		sxmBG.y = FlxG.height - 720;

		var sxmSongs = ["power-link", "revenge", "final-destination"];
		if (!sxmSongs.contains(songs[curSelected].songName.toLowerCase()))
			menuCol.alpha = sxmBG.alpha = 0;

		cursorOWidth = wiiCursor.width;
		cursorSize = cursorOWidth;

		letter = new FlxSprite(0, 0).loadGraphic(Paths.image('letterbomb'));
		letter.updateHitbox();
		letter.setGraphicSize(80);
		letter.x = FlxG.width - 163;
		letter.y = FlxG.height - 147;
		letter.scrollFactor.set();

		hb_bg = new FlxSprite(0, 0).loadGraphic(Paths.image('hb_bg'));
		hb_bg.scrollFactor.set();
		hb_bg.alpha = 0;
		hb_bg.antialiasing = true;

		hb_text_small = new FlxSprite(FlxG.width - 1280 + 100, 0).loadGraphic(Paths.image('hb_text_small'));
		hb_text_small.scrollFactor.set();
		hb_text_small.alpha = 0;

		bigLetter = new FlxSprite(0, 0).loadGraphic(Paths.image('letterbomb'));
		bigLetter.scrollFactor.set();
		bigLetter.screenCenter(X);
		bigLetter.y = -600;
		bigLetter.updateHitbox();

		cmd_screen = new FlxSprite(-500, -400).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
		cmd_screen.scrollFactor.set();
		cmd_screen.alpha = 0;

		cmd_text = new FlxText(10, 10, 0, '', 20);
		cmd_text.scrollFactor.set();
		cmd_text.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		if (!FlxG.save.data.showLetter)
		{
			letter.alpha = 0;
		}
		if (FlxG.save.data.wii >= 1)
		{
			letter.alpha = 0;
			hb_text_small.alpha = 1;
			hb_bg.frames = Paths.getSparrowAtlas('hb_files/hb_sc_bg');
			hb_bg.animation.addByPrefix('idle', 'water bitmap animation', 15);
			hb_bg.animation.play('idle');
			hb_bg.x = FlxG.width - 1280 + 100;
			hb_bg.y = 61;

			hb_big_border = new FlxSprite(100, 61).loadGraphic(Paths.image('hb_files/hb_big_border'));
			hb_big_border.scrollFactor.set();
			hb_big_border.alpha = 0;
			hb_big_border.setGraphicSize(260, 142);
			hb_big_border.antialiasing = true;
			hb_big_border.updateHitbox();

			hb_big_bg = new FlxSprite(100, 61).loadGraphic(Paths.image('hb_files/hb_big_bg'));
			hb_big_bg.scrollFactor.set();
			hb_big_bg.alpha = 0;
			hb_big_bg.setGraphicSize(260, 142);
			hb_big_bg.antialiasing = true;
			hb_big_bg.updateHitbox();

			hb_big_size = [260, 142];

			hb_water_back = new FlxSprite(0, 720).loadGraphic(Paths.image('hb_files/water_back'));
			hb_water_back.scrollFactor.set();
			hb_water_back.alpha = 0;

			hb_water = new FlxSprite(0, 720).loadGraphic(Paths.image('hb_files/water'));
			hb_water.scrollFactor.set();
			hb_water.alpha = 0;

			hb_big_text = new FlxSprite(0, 0).loadGraphic(Paths.image('hb_files/hb_big_text'));
			hb_big_text.scrollFactor.set();
			hb_big_text.alpha = 0;

			hb_flash = new FlxSprite(0, 0).loadGraphic(Paths.image('hb_files/hb_big_bg'));
			hb_flash.alpha = 0;
			hb_flash.scrollFactor.set();
		}

		add(hb_bg);
		add(hb_text_small);


		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		bg.color = songs[curSelected].color;
		intendedColor = bg.color;
		changeSelection();
		changeDiff();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to this Song / Press RESET to Reset your Score and Accuracy.";
		#else
		var leText:String = "Press RESET to Reset your Score and Accuracy.";
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

		add(letter);
		add(bigLetter);
		add(wiiCursor);
		add(cmd_screen);
		add(cmd_text);

		if (FlxG.save.data.wii >= 1)
		{
			add(hb_big_bg);

			add(hb_water_back);
			add(hb_water);
			add(hb_big_text);

			add(hb_flash);
			add(hb_big_border);
		}

		super.create();
	}

	var wiiMenuState = 0;
	var wasOnMsg = false;
	var cursorSize:Float;
	var cursorOWidth:Float;
	var cmd_wait = 1;
	var cmd_ind = 0;

	function isOnBtt(xx:Float, yy:Float, dis:Float)
	{
		var xDis = xx - FlxG.mouse.x;
		var yDis = yy - FlxG.mouse.y;
		if (Math.sqrt(Math.pow(xDis, 2) + Math.pow(yDis, 2)) < dis)
		{
			return(true);
		}
		else return(false);
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = intendedRating;

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + (Math.floor(lerpRating * 10000) / 100) + '%)';
		positionHighscore();

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = false;
		var space = false;

		if (wiiMenuState == 0) {
			accepted = controls.ACCEPT;
			space = FlxG.keys.justPressed.SPACE;
		}

		if (wiiMenuState <= 0)
		{
			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}

			
			if (controls.UI_LEFT_P)
				changeDiff(-1);
			if (controls.UI_RIGHT_P)
				changeDiff(1);
		}



		//wii shit
		hb_text_small.x = FlxG.width - 1280 + 130;
		hb_text_small.y = 100 + Math.cos(rot / 30) * 5;
		rot ++;
		hb_bg.alpha = hb_text_small.alpha;

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			MusicBeatState.switchState(new MainMenuState());
		}

		var sxmAlpha = 0;

		var sxmSongs = ["power-link", "revenge", "final-destination"];
		if (sxmSongs.contains(songs[curSelected].songName.toLowerCase())) {
			sxmAlpha = 1;
			updateState(elapsed);
		}
		

		wiiCursor.alpha = menuCol.alpha = sxmBG.alpha = FlxMath.lerp(sxmBG.alpha, sxmAlpha, CoolUtil.boundTo(elapsed * 7, 0, 1));
		if (FlxG.save.data.showLetter && wiiMenuState == 0 && !(FlxG.save.data.wii >= 1))
			letter.alpha = wiiCursor.alpha;

		if (wiiMenuState == 0 && FlxG.save.data.wii >= 1) {
			hb_bg.alpha = hb_text_small.alpha = wiiCursor.alpha;
		}

		

		#if PRELOAD_ALL
		if(space && instPlaying != curSelected)
		{
			destroyFreeplayVocals();
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
			else
				vocals = new FlxSound();

			FlxG.sound.list.add(vocals);
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
			vocals.play();
			vocals.persist = true;
			vocals.looped = true;
			vocals.volume = 0.7;
			instPlaying = curSelected;
		}
		else #end if (accepted && (curDifficulty != 0 || WeekData.songHasMania[songs[curSelected].songName]))
		{
			var songLowercase:String = songs[curSelected].songName.toLowerCase();
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CURRENT WEEK: ' + WeekData.getCurrentWeekNumber());
			if(colorTween != null) {
				colorTween.cancel();
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		else if(controls.RESET)
		{
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}
		wiiCursor.x = FlxG.mouse.x;
		wiiCursor.y = FlxG.mouse.y;
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficultyStuff.length-1;
		if (curDifficulty >= CoolUtil.difficultyStuff.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		var diffTxt = ['MANIA', 'CANON'];
		diffText.text = '< ' + diffTxt[curDifficulty] + ' >';
		positionHighscore();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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
		changeDiff();
	}

	private function positionHighscore() {
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}


	function updateState(elapsed) {
		var curExt = false;
		switch (wiiMenuState)
		{
			case 0:
				if (FlxG.save.data.showLetter != null && FlxG.save.data.showLetter)
				{
					if (FlxG.save.data.wii == 0)
					{
						var onMsg = isOnBtt(FlxG.width - 100, FlxG.height - 100, 60);
						if (onMsg)
						{
							curExt = true;
							if (!wasOnMsg)
							{
								FlxG.sound.play(Paths.sound('menu/cursor'));
							}
							if (FlxG.mouse.justPressed)
							{
								FlxG.sound.play(Paths.sound('menu/select'));
								letter.alpha = 0;
								menuCol.alpha = 0;
								bg.alpha = 0.5;
								wiiMenuState = 1;
							}
						}
						wasOnMsg = onMsg;
					}
					else
					{
						var onMsg = isOnBtt(FlxG.width - 1280 + 210, 130, 120);
						if (onMsg)
						{
							curExt = true;
							if (!wasOnMsg)
							{
								FlxG.sound.play(Paths.sound('menu/cursor'));
							}
							if (FlxG.mouse.justPressed)
							{
								FlxG.sound.play(Paths.sound('menu/open'));
								FlxG.sound.music.stop();
								destroyFreeplayVocals();
								trace("yea");
								wiiMenuState = 3;
							}
						}
						wasOnMsg = onMsg;
					}
				}
			case 1:
				bigLetter.y += ((FlxG.height / 2 - 50) - bigLetter.y) / 3;
				if (isOnBtt(bigLetter.getMidpoint().x, bigLetter.getMidpoint().y, 65))
				{
					curExt = true;
					if (FlxG.mouse.justPressed)
					{
						FlxG.sound.music.stop();
						destroyFreeplayVocals();
						bigLetter.alpha = 0;
						wiiMenuState = 2;
						bg.alpha = 0;
						cmd_screen.alpha = 1;
						//grpSongs.kill();
					}
				}
			case 2:
				if (cmd_wait > 0) cmd_wait --
				else if (cmd_wait == 0)
				{
					var ltxt = cmd_text.text;
					cmd_text.text += cmd_list[cmd_ind] + '\n';
					switch (cmd_ind)
					{
						case 10:
							cmd_wait = 20;
						case 13 | 14 | 15:
							cmd_wait = 30;
						case 16 | 17:
							cmd_wait = 60;
						case 18:
							cmd_wait = 100;
						case 20:
							cmd_wait = -1;
						case 21:
							if (ltxt != '')
							{
								MusicBeatState.switchState(new FreeplayState());
								cmd_text.text = 'aweonao';
								cmd_wait = -2;
							}
							else
							{
								cmd_wait = 100;
							}
						case 22:
							cmd_wait = 120;
						case 24:
							cmd_wait = 300;
						case 25:
							FlxG.save.data.wii = 1;
							FlxG.save.flush();
							bg.alpha = 1;
							/*
							cmd_screen.alpha = 0;
							cmd_text.kill();
							wiiMenuState = 0;
							*/
							MusicBeatState.switchState(new FreeplayState());
						default:
							cmd_wait = 2;
					}
					cmd_ind ++;
				}
				else
				{
					if (FlxG.keys.justPressed.Y)
					{
						cmd_text.text = '';
						cmd_wait = 1;
					}
					else if (FlxG.keys.justPressed.N)
					{
						cmd_text.text = 'Installation has been cancelled.';
						cmd_wait = 200;
					}
				}
			case 3:
				//INDEX:homebrew transition
				cmd_screen.alpha += 0.01;
				hb_big_bg.alpha += 0.02;

				hb_big_size[0] += ((FlxG.width + 1) - hb_big_size[0]) / 18;
				//hb_big_size[1] += (720 - hb_big_size[1]) / 6;
				hb_big_bg.x += (0 - hb_big_bg.x) / 18;
				hb_big_bg.y += (0 - hb_big_bg.y) / 18;

				hb_big_bg.setGraphicSize(Std.int(hb_big_size[0]));
				hb_big_bg.updateHitbox();

				if (hb_big_bg.width >= FlxG.width)
				{
					wiiMenuState = 4;
					FlxG.sound.play(Paths.sound('menu/hb_jingle'));
				}
			case 4:
				switch (hb_step)
				{
					case 500:
						hb_big_text.alpha = 1;
						hb_flash.alpha = 1;
					case 940:
						curSelected = 2;
						{
							CoolUtil.difficultyStuff = [
								['GOD', '-god'],
							];
							PlayState.SONG = Song.loadFromJson("final-destination-god", "final-destination");
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = 0;
							PlayState.storyWeek = 3;
							if(colorTween != null) {
								colorTween.cancel();
							}
							LoadingState.loadAndSwitchState(new PlayState());				
						}
				}

				hb_water.alpha = 1;
				hb_water_back.alpha = 1;
				var movslow = 50;
				hb_water.y += (30 - hb_water.y) / movslow;
				hb_water_back.y += (30 - hb_water.y) / movslow;

				var rotlen = 450;
				hb_water.x = -211 - rotlen + Math.sin(hb_step / 70) * rotlen;
				hb_water_back.x = -177 - rotlen + Math.sin(hb_step / 90) * rotlen;

				hb_big_text.y = Math.sin(hb_step / 60) * 20;

				if (hb_flash.alpha > 0) hb_flash.alpha -= 0.03;
				hb_step ++;
		}
		if (wiiMenuState == 3 || wiiMenuState == 4)
		{
			if (FlxG.save.data.wii >= 1)
			{
				hb_big_border.alpha = hb_big_bg.alpha;
				hb_big_border.setGraphicSize(Std.int(hb_big_bg.width));
				hb_big_border.updateHitbox();
				hb_big_border.x = hb_big_bg.x;
				hb_big_border.y = hb_big_bg.y;
			}
		}
		var cToW = cursorOWidth;
		if (curExt) cToW = cursorOWidth * 1.3;

		cursorSize += (cToW - cursorSize) / 3;
		wiiCursor.setGraphicSize(Std.int(cursorSize));
	}

	var cmd_list:Array<String> = [
		'savezelda (tueidj@tueidj.net)',
		'',
		'Copyright 2008,2009 Segher Boessenkool',
		'Copyright 2008 Haxx Enterprises',
		'Copyright 2008 Hector Martin ("marcan")',
		'Copyright 2003,2004 Felix Domke',
		'',
		'This code is licensed to you under the terms of the',
		'GNU GPL, version 2; see the file COPYING',
		'',
		'Font and graphics by Fantom Larcade', //10
		'', //11
		'',
		'Cleaning up enviroment... OK.', //13
		'SD card detected', //14
		'Opening boot.elf:', //15
		'reading 2153056 bytes...', //16
		'Done.', //17
		'Valid ELF image detected.', //18
		'',
		'Install homebrew channel on this wii? [y,n]', //20
		'Downloading files...',
		'Installing the Homebrew Channel...',
		'..................................',
		'SUCCESS.',
		''
		];
	
		var cmd_accept:Array<String> = [
	
		];
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		if(week < FreeplayState.coolColors.length) {
			this.color = FreeplayState.coolColors[week];
		}
	}
}
