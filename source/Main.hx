package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import lime.app.Application;
import mobile.backend.MobileScaleMode;
import mobile.backend.SUtil;
import mobile.backend.CopyState;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;
	public static var drums:Bool = false;
	public static var menuBad:Bool = false;
	public static var menuMusPlay:Bool = false;
	public static var skipDes:Bool = false;
	public static var ammo:Array<Int> = [4, 6, 7, 9];
	public static var gfxIndex:Array<Dynamic> = [
		[0, 1, 2, 3],
		[0, 2, 3, 5, 1, 8],
		[0, 2, 3, 4, 5, 1, 8],
		[0, 1, 2, 3, 4, 5, 6, 7, 8]
	];
	public static var gfxHud:Array<Dynamic> = [
		[0, 1, 2, 3],
		[0, 2, 3, 0, 1, 3],
		[0, 2, 3, 4, 0, 1, 3],
		[0, 1, 2, 3, 4, 0, 1, 2, 3]
	];
	public static var gfxAlterInd:Array<Dynamic> = [
		[2, 3, 3, 2],
		[0, 1, 2, 2, 1, 0],
		[0, 1, 2, 3, 2, 1, 0],
		[0, 1, 2, 1, 3, 1, 2, 1, 0]
	];
	public static var letterMax:Array<Int> = [9, 4];
	public static var skinName:Array<String> = ['assets', 'alter'];
	public static var gfxDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'SPACE'];
	public static var charDir:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT', 'UP'];
	public static var gfxLetter:Array<String> = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();
		#if mobile
 		#if android
 		SUtil.requestPermissions();
 		#end
 		Sys.setCwd(SUtil.getStorageDirectory());
 		#end
		mobile.backend.CrashHandler.init();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		#if (openfl <= "9.2.0")
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
		#else
		if (zoom == -1.0)
 			zoom = 1.0;
 		#end

		#if !debug
		initialState = TitleState;
		#end

		addChild(new FlxGame(gameWidth, gameHeight, #if mobile CopyState.checkExistingFiles() ? initialState: CopyState #else initialState #end, framerate, framerate, skipSplash, startFullscreen));

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
		#if android FlxG.android.preventDefaultKeys = [BACK]; #end
		FlxG.scaleMode = new MobileScaleMode();

		
	}

	static var didChange:Bool = false;
	public static function yea() {
		if (didChange) return;

		didChange = true;
		Application.current.window.setIcon(lime.graphics.Image.fromFile("assets/images/shaggyIcon.png"));
		Application.current.window.title = "Friday Night Funkin' VS Shaggy Mystery Inc Mix";
	}
}
