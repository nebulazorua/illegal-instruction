package;

import GlitchShader.Fuck;
import openfl.filters.ShaderFilter;
import flixel.graphics.FlxGraphic;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.effects.FlxFlicker;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets as OpenFlAssets;
import openfl.filters.ShaderFilter;
import editors.ChartingState;
import editors.CharacterEditorState;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import Note.EventNote;
import openfl.events.KeyboardEvent;
import flixel.util.FlxSave;
import Achievements;
import StageData;
import FunkinLua;
import DialogueBoxPsych;
import GlitchShader.GlitchShaderA;
import GlitchShader.GlitchShaderB;
#if sys
import sys.FileSystem;
#end
import SonicNumber.SonicNumberDisplay;
import flixel.tweens.FlxTween.FlxTweenManager;
using StringTools;

class PlayState extends MusicBeatState
{
	var camGlitchShader:GlitchShaderB;
	var camFuckShader:Fuck;
	var camGlitchFilter:BitmapFilter;
	var camFuckFilter:BitmapFilter;
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	public var piss:Array<FlxTween> = [];
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, ModchartSprite>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, ModchartText>();
	public var modchartSaves:Map<String, FlxSave> = new Map<String, FlxSave>();
	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var songSpeedTween:FlxTween;
	public var songSpeed(default, set):Float = 1;
	public var songSpeedType:String = "multiplicative";
	public var noteKillOffset:Float = 350;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;
	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	public var vocals:FlxSound;

	public var dad:Character = null;
	public var gf:Character = null;
	public var boyfriend:Boyfriend = null;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<EventNote> = [];

	private var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	private var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	public var startingSong:Bool = false;
	private var updateTime:Bool = true;
	public static var changedDifficulty:Bool = false;
	public static var chartingMode:Bool = false;

	//Gameplay settings
	public var healthGain:Float = 1;
	public var healthLoss:Float = 1;
	public var instakillOnMiss:Bool = false;
	public var cpuControlled:Bool = false;
	public var practiceMode:Bool = false;

	public var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:DialogueFile = null;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var scoreTxt:FlxText;
	var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;
	private var singAnimations:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];

	public var inCutscene:Bool = false;
	public var skipCountdown:Bool = false;
	var songLength:Float = 0;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	//Achievement shit
	var keysPressed:Array<Bool> = [];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;
	public var introSoundsSuffix:String = '';

	// Debug buttons
	private var debugKeysChart:Array<FlxKey>;
	private var debugKeysCharacter:Array<FlxKey>;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	// HUD
	// TODO: diff HUD designs
	var isPixelHUD:Bool = false;
	var chaotixHUD:FlxSpriteGroup;

	var fcLabel:FlxSprite;
	var ringsLabel:FlxSprite;
	var hudDisplays:Map<String, SonicNumberDisplay> = [];
	var hudStyle:Map<String, String> = [
		"my-horizon" => "chaotix",
		"our-horizon" => "chaotix",
		"long sky" => "chotix"
	];
	// for the time counter
	var hudMinute:SonicNumber;
	var hudSeconds:SonicNumberDisplay;
	var hudMS:SonicNumberDisplay;
	//intro stuff
	var startCircle:FlxSprite;
	var startText:FlxSprite;
	var blackFuck:FlxSprite;
	// chaotix shit
	var fucklesBeats:Bool = true;
	// fuckles
	public var fucklesDrain:Float = 0;
	public var fucklesMode:Bool = false;
	public var drainMisses:Float = 0; // EEE OOO EH OO EE AAAAAAAAA
	// glad my comment above stayed lmao -neb
	//general stuff (statics n shit...)
	var theStatic:FlxSprite;  //THE FUNNY THE FUNNY!!!!

	//duke shit
	//entrance (ee oo ayy eh)
	var entranceBG:FlxSprite;
	var entranceTowers:FlxSprite;
	var entranceClock:FlxSprite;
	var entranceFloor:FlxSprite;
	var entrancePointers:FlxSprite;

	// horizon
	var fucklesBGPixel:FlxSprite;
	var fucklesFGPixel:FlxSprite;
	var fucklesAmyBg:FlxSprite;
	var fucklesVectorBg:FlxSprite;
	var fucklesKnuxBg:FlxSprite;
	var fucklesEspioBg:FlxSprite;
	var fucklesCharmyBg:FlxSprite;
	var fucklesMightyBg:FlxSprite;
	var fucklesFuckedUpBg:FlxSprite;
	var fucklesFuckedUpFg:FlxSprite;
	var fucklesTheHealthHog:Array<Float>;
	var whiteFuck:FlxSprite;
	//horizon but real

	var horizonBg:FlxSprite;
	var horizonFloor:FlxSprite;
	var horizonTrees:FlxSprite;
	var horizonTrees2:FlxSprite;

	var horizonPurpur:FlxSprite;
	var horizonYellow:FlxSprite;
	var horizonRed:FlxSprite;
	
	var horizonAmy:FlxSprite;
	var horizonKnuckles:FlxSprite;
	var horizonEspio:FlxSprite;
	var horizonMighty:FlxSprite;
	var horizonCharmy:FlxSprite;
	var horizonVector:FlxSprite;
	// aughhhhhhhhhhhhhhhh
	var hellBg:FlxSprite;
	// - healthbar based things for mechanic use (like my horizon lol)
	var healthMultiplier:Float = 1; // fnf
	var healthDrop:Float = 0;
	var dropTime:Float = 0;
	// - camera bullshit
	var dadCamThing:Array<Int> = [0, 0];
	var bfCamThing:Array<Int> = [0, 0];
	var cameramove:Bool = FlxG.save.data.cammove;
	//zoom bullshit
	public var wowZoomin:Bool = false;
	public var holyFuckStopZoomin:Bool = false;
	public var pleaseStopZoomin:Bool = false;
	public var ohGodTheZooms:Bool = false;
	// normal shit
	private var metalTrail:FlxTrail;
	private var amyTrail:FlxTrail;
	private var normalTrail:FlxTrail;
	var soulGlassTime:Bool = false;
	var normalBg:FlxSprite;
	var normalFg:FlxSprite;
	var normalTv:FlxSprite;
	var normalVg:FlxSprite;
	var normalShadow:FlxSprite;
	var normalDoor:FlxSprite;
	var normalScreen:FlxSprite;
	var normalChars:FlxSprite;

	public var normalCharShit:Int;
	public var normalBool:Bool = false;

	//curse shit (just admit it!!!!)
	var hexTimer:Float = 0;
	var hexes:Float = 0;
	var fucklesSetHealth:Float = 0;
	var barbedWires:FlxTypedGroup<ShakableSprite>;
	var wireVignette:FlxSprite;
	//the fucking actual assets
	var curseStatic:FlxSprite;
	var curseFloor:FlxSprite;
	var curseSky:FlxSprite;
	var curseTrees:FlxSprite;
	var curseTreesTwo:FlxSprite;
	var curseFountain:FlxSprite;

	//hjog shit dlskafj;lsa
	var staticlol:StaticShader;
	private var staticAlpha:Float = 1;

	var hogBg:BGSprite;
	var hogMotain:BGSprite;
	var hogWaterFalls:FlxSprite;
	var hogFloor:FlxSprite;
	var hogLoops:FlxSprite;
	var hogTrees:BGSprite;
	var hogRocks:BGSprite;
	var hogOverlay:BGSprite;
	//manual blast
	var scorchedBg:BGSprite;
	var scorchedMotain:BGSprite;
	var scorchedWaterFalls:FlxSprite;
	var scorchedFloor:FlxSprite;
	var scorchedMonitor:FlxSprite;
	var scorchedHills:FlxSprite;
	var scorchedTrees:BGSprite;
	var scorchedRocks:BGSprite;

	var scoreRandom:Bool = false;

	override public function create()
	{
		Paths.clearStoredMemory();

		// for lua
		instance = this;

		blackFuck = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		startCircle = new FlxSprite();
		startText = new FlxSprite();

		debugKeysChart = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));
		debugKeysCharacter = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_2'));
		PauseSubState.songName = null; //Reset to default

		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];

		// For the "Just the Two of Us" achievement
		for (i in 0...keysArray.length)
		{
			keysPressed.push(false);
		}

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// Gameplay settings
		healthGain = ClientPrefs.getGameplaySetting('healthgain', 1);
		healthLoss = ClientPrefs.getGameplaySetting('healthloss', 1);
		instakillOnMiss = ClientPrefs.getGameplaySetting('instakill', false);
		practiceMode = ClientPrefs.getGameplaySetting('practice', false);
		cpuControlled = ClientPrefs.getGameplaySetting('botplay', false);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		#if desktop
		storyDifficultyText = CoolUtil.difficulties[storyDifficulty];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		curStage = PlayState.SONG.stage;
		//trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) { //Stage couldn't be found, create a dummy stage for preventing a crash
			stageData = {
				directory: "",
				defaultZoom: 0.9,
				isPixelStage: false,

				boyfriend: [770, 100],
				girlfriend: [400, 130],
				opponent: [100, 100],
				hide_girlfriend: false,

				camera_boyfriend: [0, 0],
				camera_opponent: [0, 0],
				camera_girlfriend: [0, 0],
				camera_speed: 1
			};
		}

		defaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];

		if(stageData.camera_speed != null)
			cameraSpeed = stageData.camera_speed;

		boyfriendCameraOffset = stageData.camera_boyfriend;
		if(boyfriendCameraOffset == null) //Fucks sake should have done it since the start :rolling_eyes:
			boyfriendCameraOffset = [0, 0];

		opponentCameraOffset = stageData.camera_opponent;
		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		girlfriendCameraOffset = stageData.camera_girlfriend;
		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		switch (curStage)
		{
			case 'entrance':

				defaultCamZoom = 0.75;
				isPixelHUD = false;

				entranceBG = new FlxSprite(-300, -300);
				entranceBG.loadGraphic(Paths.image('entrance/bg', 'exe'));
				entranceBG.scrollFactor.set(0.9, 1);
				entranceBG.scale.set(1.2, 1.2);
				entranceBG.antialiasing = true;
				add(entranceBG);

				entranceTowers = new FlxSprite(-350, 0);
				entranceTowers.loadGraphic(Paths.image('entrance/towers', 'exe'));
				entranceTowers.scrollFactor.set(1.05, 1);
				entranceTowers.scale.set(1.2, 1.2);
				entranceTowers.antialiasing = true;
				add(entranceTowers);

				entranceClock = new FlxSprite(-350, -50);
				entranceClock.loadGraphic(Paths.image('entrance/clock', 'exe'));
				entranceClock.scrollFactor.set(1, 1);
				entranceClock.scale.set(1.2, 1.2);
				entranceClock.antialiasing = true;
				add(entranceClock);

				entranceFloor = new FlxSprite(-325, -50);
				entranceFloor.loadGraphic(Paths.image('entrance/floor', 'exe'));
				entranceFloor.scrollFactor.set(1, 1);
				entranceFloor.scale.set(1.2, 1.2);
				entranceFloor.antialiasing = true;
				add(entranceFloor);

				entrancePointers = new FlxSprite(-300, -50);
				entrancePointers.loadGraphic(Paths.image('entrance/pointers', 'exe'));
				entrancePointers.scrollFactor.set(1.1, 1);
				entrancePointers.scale.set(1.2, 1.2);
				entrancePointers.antialiasing = true;
				add(entrancePointers);

			case 'horizon':

				GameOverSubstate.deathSoundName = 'chaotix-death';
				GameOverSubstate.loopSoundName = 'chaotix-loop';
				GameOverSubstate.endSoundName = 'chaotix-retry';
				GameOverSubstate.characterName = 'bf-chaotix-death';

				defaultCamZoom = 0.87;
				isPixelStage = true;
				isPixelHUD = true;

				fucklesBGPixel = new FlxSprite(-1450, -725);
				fucklesBGPixel.loadGraphic(Paths.image('chaotix/horizonsky', 'exe'));
				fucklesBGPixel.scrollFactor.set(1.2, 0.9);
				fucklesBGPixel.scale.set(1, 1);
				fucklesBGPixel.antialiasing = false;
				add(fucklesBGPixel);

				fucklesFuckedUpBg = new FlxSprite(-1300, -500);
				fucklesFuckedUpBg.frames = Paths.getSparrowAtlas('chaotix/corrupt_background', 'exe');
				fucklesFuckedUpBg.animation.addByPrefix('idle', 'corrupt background', 24, true);
				fucklesFuckedUpBg.animation.play('idle');
				fucklesFuckedUpBg.scale.x = 1;
				fucklesFuckedUpBg.scale.y = 1;
				fucklesFuckedUpBg.visible = false;
				fucklesFuckedUpBg.antialiasing = false;
				add(fucklesFuckedUpBg);

				fucklesFGPixel = new FlxSprite(-550, -735);
				fucklesFGPixel.loadGraphic(Paths.image('chaotix/horizonFg', 'exe'));
				fucklesFGPixel.scrollFactor.set(1, 0.9);
				fucklesFGPixel.scale.set(1, 1);
				fucklesFGPixel.antialiasing = false;
				add(fucklesFGPixel);

				fucklesFuckedUpFg = new FlxSprite(-550, -735);
				fucklesFuckedUpFg.loadGraphic(Paths.image('chaotix/horizonFuckedUp', 'exe'));
				fucklesFuckedUpFg.scrollFactor.set(1, 0.9);
				fucklesFuckedUpFg.scale.set(1, 1);
				fucklesFuckedUpFg.visible = false;
				fucklesFuckedUpFg.antialiasing = false;
				add(fucklesFuckedUpFg);


				fucklesAmyBg = new FlxSprite(1195, 630);
				fucklesAmyBg.frames = Paths.getSparrowAtlas('chaotix/BG_amy', 'exe');
				fucklesAmyBg.animation.addByPrefix('idle', 'amy bobbing', 24);
				fucklesAmyBg.animation.addByPrefix('fear', 'amy fear', 24, true);
				fucklesAmyBg.scale.x = 6;
				fucklesAmyBg.scale.y = 6;
				fucklesAmyBg.antialiasing = false;


				fucklesCharmyBg = new FlxSprite(1000, 500);
				fucklesCharmyBg.frames = Paths.getSparrowAtlas('chaotix/BG_charmy', 'exe');
				fucklesCharmyBg.animation.addByPrefix('idle', 'charmy bobbing', 24);
				fucklesCharmyBg.animation.addByPrefix('fear', 'charmy fear', 24, true);
				fucklesCharmyBg.scale.x = 6;
				fucklesCharmyBg.scale.y = 6;
				fucklesCharmyBg.antialiasing = false;


				fucklesMightyBg = new FlxSprite(590, 650);
				fucklesMightyBg.frames = Paths.getSparrowAtlas('chaotix/BG_mighty', 'exe');
				fucklesMightyBg.animation.addByPrefix('idle', 'mighty bobbing', 24);
				fucklesMightyBg.animation.addByPrefix('fear', 'mighty fear', 24, true);
				fucklesMightyBg.scale.x = 6;
				fucklesMightyBg.scale.y = 6;
				fucklesMightyBg.antialiasing = false;


				fucklesEspioBg = new FlxSprite(1400, 660);
				fucklesEspioBg.frames = Paths.getSparrowAtlas('chaotix/BG_espio', 'exe');
				fucklesEspioBg.animation.addByPrefix('idle', 'espio bobbing', 24);
				fucklesEspioBg.animation.addByPrefix('fear', 'espio fear', 24, true);
				fucklesEspioBg.scale.x = 6;
				fucklesEspioBg.scale.y = 6;
				fucklesEspioBg.antialiasing = false;


				fucklesKnuxBg = new FlxSprite(-60, 645);
				fucklesKnuxBg.frames = Paths.getSparrowAtlas('chaotix/BG_knuckles', 'exe');
				fucklesKnuxBg.animation.addByPrefix('idle', 'knuckles bobbing', 24);
				fucklesKnuxBg.animation.addByPrefix('fear', 'knuckles fear', 24, true);
				fucklesKnuxBg.scale.x = 6;
				fucklesKnuxBg.scale.y = 6;
				fucklesKnuxBg.antialiasing = false;


				fucklesVectorBg = new FlxSprite(-250, 615);
				fucklesVectorBg.frames = Paths.getSparrowAtlas('chaotix/BG_vector', 'exe');
				fucklesVectorBg.animation.addByPrefix('idle', 'vector bobbing', 24);
				fucklesVectorBg.animation.addByPrefix('fear', 'vector fear', 24, true);
				fucklesVectorBg.scale.x = 6;
				fucklesVectorBg.scale.y = 6;
				fucklesVectorBg.antialiasing = false;

				add(fucklesAmyBg);
				add(fucklesCharmyBg);
				add(fucklesMightyBg);
				add(fucklesEspioBg);
				add(fucklesKnuxBg);
				add(fucklesVectorBg);

				whiteFuck = new FlxSprite(-600, 0).makeGraphic(FlxG.width * 6, FlxG.height * 6, FlxColor.BLACK);
				whiteFuck.alpha = 0;
				add(whiteFuck);

				if (SONG.song.toLowerCase() == 'our-horizon')
					{

						horizonBg = new FlxSprite(-500, 285);
						horizonBg.loadGraphic(Paths.image('chaotix/new_horizon/starline', 'exe'));
						horizonBg.scrollFactor.set(1, 1);
						horizonBg.scale.set(1.1, 1.1);
						horizonBg.antialiasing = true;
						add(horizonBg);

						horizonPurpur = new FlxSprite(-150, 425);
						horizonPurpur.frames = Paths.getSparrowAtlas('chaotix/firework/pink_firework', 'exe');
						horizonPurpur.animation.addByPrefix('idle', 'red firework', 8);
						horizonPurpur.scrollFactor.set(1, 1);
						horizonPurpur.antialiasing = true;
						add(horizonPurpur);

						horizonRed = new FlxSprite(400, 425);
						horizonRed.frames = Paths.getSparrowAtlas('chaotix/firework/red_firework', 'exe');
						horizonRed.animation.addByPrefix('idle', 'red firework', 8);
						horizonRed.scrollFactor.set(1, 1);
						horizonRed.antialiasing = true;
						add(horizonRed);

						horizonYellow = new FlxSprite(800, 425);
						horizonYellow.frames = Paths.getSparrowAtlas('chaotix/firework/yellow_firework', 'exe');
						horizonYellow.animation.addByPrefix('idle', 'red firework', 8);
						horizonYellow.scrollFactor.set(1, 1);
						horizonYellow.antialiasing = true;
						add(horizonYellow);

						horizonFloor = new FlxSprite(-500, 285);
						horizonFloor.loadGraphic(Paths.image('chaotix/new_horizon/floor', 'exe'));
						horizonFloor.scrollFactor.set(1, 1);
						horizonFloor.scale.set(1.1, 1.1);
						horizonFloor.antialiasing = true;
						add(horizonFloor);

						horizonEspio = new FlxSprite(-300, 400);
						horizonEspio.frames = Paths.getSparrowAtlas('chaotix/new_horizon/espio_bopper', 'exe');
						horizonEspio.animation.addByPrefix('idle', 'espio bopper instance 1', 24);
						horizonEspio.scrollFactor.set(1, 1);
						horizonEspio.setGraphicSize(Std.int(horizonEspio.width * 0.5));
						horizonEspio.antialiasing = true;
						add(horizonEspio);

						horizonTrees = new FlxSprite(-400, 285);
						horizonTrees.loadGraphic(Paths.image('chaotix/new_horizon/trees', 'exe'));
						horizonTrees.scrollFactor.set(1, 1);
						horizonTrees.scale.set(1.1, 1.1);
						horizonTrees.antialiasing = true;
						add(horizonTrees);

						horizonAmy = new FlxSprite(800, 400);
						horizonAmy.frames = Paths.getSparrowAtlas('chaotix/new_horizon/amy_bopper', 'exe');
						horizonAmy.animation.addByPrefix('idle', 'amy bopper instance 1', 24);
						horizonAmy.scrollFactor.set(1, 1);
						horizonAmy.setGraphicSize(Std.int(horizonAmy.width * 0.5));
						horizonAmy.antialiasing = true;
						add(horizonAmy);

						horizonMighty = new FlxSprite(500, 400);
						horizonMighty.frames = Paths.getSparrowAtlas('chaotix/new_horizon/mighty_bopper', 'exe');
						horizonMighty.animation.addByPrefix('idle', 'mighty bopper', 24);
						horizonMighty.scrollFactor.set(1, 1);
						horizonMighty.setGraphicSize(Std.int(horizonMighty.width * 0.5));
						horizonMighty.antialiasing = true;
						add(horizonMighty);

						horizonCharmy = new FlxSprite(675, 200);
						horizonCharmy.frames = Paths.getSparrowAtlas('chaotix/new_horizon/charmy_bopper', 'exe');
						horizonCharmy.animation.addByPrefix('idle', 'charmy bopper', 24);
						horizonCharmy.scrollFactor.set(1, 1);
						horizonCharmy.setGraphicSize(Std.int(horizonCharmy.width * 0.5));
						horizonCharmy.antialiasing = true;
						add(horizonCharmy);

						horizonTrees2 = new FlxSprite(-500, 285);
						horizonTrees2.loadGraphic(Paths.image('chaotix/new_horizon/trees2', 'exe'));
						horizonTrees2.scrollFactor.set(1, 1);
						horizonTrees2.scale.set(1.1, 1.1);
						horizonTrees2.antialiasing = true;
						add(horizonTrees2);

						horizonKnuckles = new FlxSprite(-750, 780);
						horizonKnuckles.frames = Paths.getSparrowAtlas('chaotix/new_horizon/knuckles_bopper', 'exe');
						horizonKnuckles.animation.addByPrefix('idle', 'knuckles bopper instance 1', 24);
						horizonKnuckles.scrollFactor.set(0.9, 0.75);
						horizonKnuckles.setGraphicSize(Std.int(horizonKnuckles.width * 0.85));
						horizonKnuckles.antialiasing = true;

						horizonVector = new FlxSprite(750, 700);
						horizonVector.frames = Paths.getSparrowAtlas('chaotix/new_horizon/vector_bopper', 'exe');
						horizonVector.animation.addByPrefix('idle', 'vector bopper', 24);
						horizonVector.scrollFactor.set(0.9, 0.75);
						horizonVector.setGraphicSize(Std.int(horizonVector.width * 0.85));
						horizonVector.antialiasing = true;

						horizonBg.visible = false;
						horizonFloor.visible = false;
						horizonTrees.visible = false;
						horizonTrees2.visible = false;

						horizonPurpur.visible = false;
						horizonYellow.visible = false;
						horizonRed.visible = false;

						horizonAmy.visible = false;
						horizonCharmy.visible = false;
						horizonEspio.visible = false;
						horizonMighty.visible = false;
						horizonKnuckles.visible = false;
						horizonVector.visible = false;
						
					}

			case 'chotix':
				{
					isPixelHUD = true;
					defaultCamZoom = 0.8;

					hellBg = new FlxSprite(-750, 0);
					hellBg.loadGraphic(Paths.image('chaotix/hell', 'exe'));
					hellBg.scrollFactor.set(1, 1);
					hellBg.scale.set(1.2, 1.2);
					hellBg.antialiasing = false;
					add(hellBg);
				}

			case 'founded':
				isPixelHUD = false;
				defaultCamZoom = 0.95;

				normalBg = new FlxSprite(-150, -200);
				normalBg.loadGraphic(Paths.image('normal/bg', 'exe'));
				normalBg.scrollFactor.set(1, 1);
				normalBg.antialiasing = true;
				normalBg.scale.set(1.2, 1.2);
				add(normalBg);

				normalDoor = new FlxSprite(-245, -760);
				normalDoor.frames = Paths.getSparrowAtlas('normal/doorbangin', 'exe');
				normalDoor.animation.addByPrefix('idle', 'doorbangin', 24, false);
				normalDoor.scrollFactor.set(1, 1);
				normalDoor.antialiasing = true;
				normalDoor.scale.set(1.2, 1.2);

				normalScreen = new FlxSprite(1600, 150);
				normalScreen.frames = Paths.getSparrowAtlas('normal/bigscreen', 'exe');
				normalScreen.animation.addByPrefix('idle', 'bigscreenstaticfinal', 24, true);
				normalScreen.animation.play('idle');
				normalScreen.scrollFactor.set(1, 1);
				normalScreen.antialiasing = true;
				normalScreen.alpha = 0.5;
				normalScreen.scale.set(1.2, 1.2);
				

				normalChars = new FlxSprite(1650, 235);
				normalChars.frames = Paths.getSparrowAtlas('normal/charactersappear', 'exe');
				normalChars.animation.addByPrefix('chaotix', 'Chaotix Appears', 24, false);
				normalChars.animation.addByPrefix('curse', 'Curse Appears', 24, false);
				normalChars.animation.addByPrefix('rex', 'Revived Appears', 24, false);
				normalChars.animation.addByPrefix('rodent', 'Rodent Appears', 24, false);
				normalChars.animation.addByPrefix('spoiled', 'Spoiled Appears', 24, false);
				normalChars.scrollFactor.set(1, 1);
				normalChars.antialiasing = true;
				normalChars.scale.set(1.2, 1.2);
				add(normalChars);
				add(normalScreen);

				normalTv = new FlxSprite(-150, -200);
				normalTv.loadGraphic(Paths.image('normal/tv', 'exe'));
				normalTv.scrollFactor.set(1, 1);
				normalTv.antialiasing = true;
				normalTv.scale.set(1.2, 1.2);
				add(normalTv);

				normalShadow = new FlxSprite(-150, -220);
				normalShadow.loadGraphic(Paths.image('normal/shadow', 'exe'));
				normalShadow.scrollFactor.set(1, 1);
				normalShadow.antialiasing = true;
				normalShadow.scale.set(1.2, 1.2);
				normalShadow.alpha = 0.8;
				add(normalShadow);

				normalVg = new FlxSprite(-150, -200);
				normalVg.loadGraphic(Paths.image('normal/vignette', 'exe'));
				normalVg.scrollFactor.set(1, 1);
				normalVg.antialiasing = true;
				normalVg.scale.set(1.2, 1.2);

				normalFg = new FlxSprite(-150, -200);
				normalFg.loadGraphic(Paths.image('normal/front', 'exe'));
				normalFg.scrollFactor.set(1.1, 1);
				normalFg.antialiasing = true;
				normalFg.scale.set(1.2, 1.2);


				case 'curse':
					//THE CURSE OF X SEETHES AND MALDS

					isPixelHUD = false;
					defaultCamZoom = 0.60;

					curseSky = new FlxSprite(-300, -150);
					curseSky.loadGraphic(Paths.image('curse/background', 'exe'));
					curseSky.scrollFactor.set(1, 1);
					curseSky.antialiasing = true;
					curseSky.scale.set(1.5, 1.5);
					add(curseSky);

					curseTrees = new FlxSprite(-300, -150);
					curseTrees.loadGraphic(Paths.image('curse/treesfarback', 'exe'));
					curseTrees.scrollFactor.set(1, 1);
					curseTrees.antialiasing = true;
					curseTrees.scale.set(1.5, 1.5);
					add(curseTrees);

					curseTreesTwo = new FlxSprite(-300, -150);
					curseTreesTwo.loadGraphic(Paths.image('curse/treesback', 'exe'));
					curseTreesTwo.scrollFactor.set(1, 1);
					curseTreesTwo.antialiasing = true;
					curseTreesTwo.scale.set(1.5, 1.5);
					add(curseTreesTwo);

					curseFountain = new FlxSprite(350, 0);
					curseFountain.frames = Paths.getSparrowAtlas('curse/goofyahfountain', 'exe');
					curseFountain.animation.addByPrefix('fotan', "fountainlol", 24, true);
					curseFountain.animation.play('fotan');
					curseFountain.scale.x = 1.4;
					curseFountain.scale.y = 1.4;
					add(curseFountain);

					curseFloor = new FlxSprite(-250, 700);
					curseFloor.loadGraphic(Paths.image('curse/floor', 'exe'));
					curseFloor.scrollFactor.set(1, 1);
					curseFloor.antialiasing = true;
					curseFloor.scale.set(1.5, 1.5);
					add(curseFloor);

					curseStatic = new FlxSprite(0, 0);
					curseStatic.frames = Paths.getSparrowAtlas('curse/staticCurse', 'exe');
					curseStatic.animation.addByPrefix('stat', "menuSTATICNEW instance 1", 24, true);
					curseStatic.animation.play('stat');
					curseStatic.alpha = 0.25;
					curseStatic.screenCenter();
					curseStatic.scale.x = 4;
					curseStatic.scale.y = 4;
					curseStatic.visible = false;
					//curseStatic.blend = LIGHTEN;
					add(curseStatic);

			case 'hog':

				//
				/**
				dQvJjL*J@$$YUfZ#C0YO%mtc*#wucC#b0qnUzzwdv0*UJYB$$80ccjUvuULZCpX#YYzahpcxY*n0nQ/JrL8JC$$@8nO*0zd*UW8huL#MY
				@BBB@B%@@@@BBBB8B@@@@B@BB%B@@%%%B@@#BBBB@BB@%B@@$$@@@@B%@@@@BBBBB%@B@%@%@BBBBB@%@BBBB@@@BB@@%%@@B@BB@%8%%
				raXwdbJUh8@/p|0acp0batwd*c|Cmpq(tJd|ZfUpt)jX)kMB@B#B*0pmpw*WMCxm*hW0ZfohCvnqdqjk*Xtz0q&@bUa8bamhX%n|fk#tf
				wakpp*MpZdB$@mbw*WpZZkBZUb8ow0wp%q0ZmC#w0OQmaahM8$$@a*owhQpk#MMM#habo8#Zob&MOq8WLhhOmp0B$$%bW8*o&apB#bdw%
				@@@@@@$@@@@$@@@@@@@@@@@@@@@@@@@@$@@$@8@@@@@@@@@@$$$$@@@@@@@@$@@@$@@@@@@$@B@@8@@@@@@@@@@@@$@@@$@@@@@@@@@@@
				JdqCucj/qC@$$|LfqkcJQZ8/(Jh0r)tXbUf|rxXrrwum*JUU#$$BdMdzOn0U#dpZ0qYYd#hrzr0o(0UZ(x(rOU0@$$ouoMwwbwXBdtjJh
				W88WMW#W%W@$@M&W%B&MW8@&*WB%8##&B8&&MMW&WW&%BWWW@$$@8%&M8#MW%8&&%%WMWB%8M#W%M8MWavOWB88$$$B&%%88%88@B88WB
				W&&W##*k&W@$$hWa&&oW&&BkoM##kha#&ohdoaMha8oWBMMM8$$@%@%MW*%MB88W*W#M%%8hMo&%p*pt'  w#*#@$$8o%@M&&&o$WdkW8
				vOqzru(jqz@$$/XfwkznYQ%x-xi+u1/ca0uvtjvcnLxZoXcX&@$BZwQxJ/vvpw0LCdcrQMbXxfzk~i`  " !bLZ@$$Mvb*OQkwc8oXvvh
				%@@@@@@@@@@$@$@@@@@@@@@@@MI  .~c*@@@@@B@$@@@@@@@@@$@@@@@@@@@@@@@@@@@@@@@@Batl..,-p@J.(@$$$@@@@$@@@@@@@@@@
				0ao#ZmOCOQa@$$aLM%hhhom@0+ )f' ,/pWpOY0hhq0M8d0pbh$$$q#w#hLow#$ZoM8wQwoMqx+!<_uxL&0z^;QWo$$@#B&*W&z&@80mo
				}QcY~/1vZQC@$$avbom0pZX#` lrMpUOnj&JMQu)#q(0oj(U(%$$$(Y(JO1|]YB/~0*wt/n|J(}f{)On1f{Qj ;wM$$okw0OcYrpBbZdb
				%B@@@@@@@@@@@$$@@@@@@@m< }&@@@@@@@@@@@B@@@@@@@@@@@@$$@@$@@@@@@@@@@@@@@@B@@@@@@@@@@@@@|:/o@$$$@@@@@@@@@@@@
				ochnxaU/fux#d%$#Mh*ZCh`  x0mqrp*hxJbd#x]hbOL&0uYrpC$$$hU#MQmbqu$J{rOpt//r0QttnJL|)awXvC,"!$$duaojuzpJ@UmM
				UY*OUccXzx1_>I!Irxhhz( lCp0W*LJW8*bZp8b0awoZoZUXwqk$$$Bh%8*#Www@omaU&ppLLp8dO?c)8LfmMkpd":$$hUaoQpCvUBJza
				@B@8d0Uxzv1<.   ;O%h+xpo@@BBB@@@@B@@@@@%@BB@@@@@@@@@$B@B@@BB@@B@@@B@@@@@BX~~i."Z%B$@@J+Zbd@@@BB@BB@@BBB@@
				vrtQ/0hXUXo@%r<` '1m.}BLQpo|({i"])rOp)pxr0n(zYudh$$$kJ#&LJkwJBw(fuZvZux_?      }fOhx].;aWhX1nc!i/L(o1fpYQ
				h#aao&Moko@@@ha~  +_iQ%d0x[i.    .uddpWkdpqb#M#8%$@@B*%8#MW#MB%*Mh8o&-_^      .td#nI/I:}<"^.      `(ddWhB
				88BB%%%%%@@B&W*h< ..i%8%^         'O#&&BB8&%B%8$$$@B@BBBB&@B@%88&BB8}          ]&8~    ^,'I)jj/~"^^^C%B%8
				UxodxuXX0qc)l,. .   iJfv.           !v1cYujZMzY$$$%obdmqC/##*0ZCtp*[           '(x`   `Y#jLjpoUz00q-:cOdC
				BBB@BBov}I;^ .I.'   iBBB,            <%BBBBB@B@*@$@@@@BBBB@@@@@BBB[             WBki   ."?MB@@BBB@@BdWB@@
				m#MmQzf|{YZQv-'     >&&%0'            <opk#wqbanJB@#%MZW#p%8@bqbhr'            !qo%)   >'  +Xad##WBwo*8dZ
				)(/)twhJqk~^  ^.    iLvCq/             ~?jt)cqrJ`/8W*k|OmxMM%dJJ].            .v0Zm:   IQ]' .,<(uw8f_0WwU
				@B8BB@Box''i/ac..  "l8B@@O'             YB@@@BB&|lU@B<J@@@@@@@@0`             :MBM~'! I /%8u~' `O8@@BB@@@
				ukoXzC/!.+mopO^'` ^)^L#&mm]             `jbuzLmWBQ^0Y-h8bY8MBCv;              [MU] -C`<t.-wcqXi'`{8cqa#Yn
				x(nJz(Iim@$W| ,;  ,j ]zLakv"             :rxCoY$$k.'!kawqzW8%w.              -LU( IUv{ a+ nU#8q(l'~x[Z8bZ
				@@BO1fL8@$$M<'r';`(@"[@@@@@U             .n@@@@@$8[ '8@@@@@@8+              Ia8{ ]M@@p^nk`lk@@@@8Uiz@@@@@
				nUL]1UQUJ@B1.o~ } 0Cf XoJLjrI             'JoQ|$@%( -hp#Jt&#r              .c0".`uc1pn>i%} .wmrZap*:xCQv|
				UQLphpp#8#L]_C{'n:tLU(1Cwdwmcf;          .<)0WW%aL1I}xa*OoMC'            .-pCf'_LQppMULn|Yxr{CQ0Wd0mmpwbm
				%p8B$@@@@@M:L%I_*;{@@8 `vB@@@@U             `B@W@$di `W@@@@f I           IoB%[.zB@@@@@@0,@@%^,@@@@@@@o@@@
				n)OLpOYqLJf/Mp.ht.[jhB]' ;_Jdow[             }*C@@*  "UCdw-..'         ;/ptn).?X%OnYXY0p^%u&< ((Zc%0r0Ykj
				%*aW%8WWMh)W%Z(8v.pa&B#b} .{#&8%}            +*p@M}   lwq< ^          _o8%&p'<WMB&*oW#8k;@o%m"?*aoBWo**B*
				**B&o##MW0o@%ZU%z'#*@B%8Wn. X&*&al          '",.,'        ^`    .,,.^~bo*o*r'Jo&8MaMBM*p?BW@&i_kB8@8&%#&M
				Cx*kUvOrkk@8c#d}1utn@qX0xm: izwhxf.        '^       .   '"Iil", ..]c|r-1Yu~<(YwUcn(Xqv(nk8hBU:JxWa@qUmvdp
				o@B&#%%MW$$@#*#i1o%o8%8W8%k,}o#@&@L;,"   I,l;    ^''|,,'         {~Ii1u%&Bi~p*%%WB&8Ba/a%B#kplo&&&@B8WM@@
				mpM*Cph0hw@$@OoZJ'OMM#%LdYZLv^:J0wZ0hz);.       i-<.fp8U 'i_]]1{l~~~uLmz*U}.:cxaZdpObmmua$omWBj/&Ww@bLm0q
				xZkLUn|cmc@$@|0cU!L1Qp%r+.XwO- |*LcunfwYnzv(^  ~vx^ZmBhct '+0YUXLqn1dM8Y1' ,)]"c{//vaarZ$$&Z&WtYoqZBoXpr#
				#W@%&%&8BM@$@8M#J-W@WW@%M.'}0a>:8B&&*kOx(+.`l1wwx[UX(!1xWY> ^{cddM##aMqU^`x&0i,*&%W8B*d@@$B#W%Jh%B#B@B#%%
				zLobtLwrZYB$@vbcJ]cook%r0|, "c].}cf}Ufz<?X_xkXr}O0,     Xxb<  .";;>l?-;."<Mk!"^qzJQuOzu@@$bX#Wnu#oJ@OfYnC
				Yq*wOJcLdL@$@cwL0/mnmb%Utq*  rr uZJXYzkQLZma*Qxa0       rxZQWx_+l!i<}~ "fCUii/t0vccL#oQ$$$8w&&mh#kq%MOdJW
				%%@BBBBB@B$@@B%%Mx%@BB@BBBB. wB`tBBB&kOLOk#88BBk:       qBBB%BB8**#Mz`~dBBWi~&BBBB%B@%B$@$@%BB%%@@%B@@%BB
				bdtvLfwz@$$jdxL-vdpa#/YXJ' ]0,`+()Q)Jtz#nYWUxf.     `<X{bp8hohjUZ(,"Q1Z]u.{j0dxuYxmCf@$@pCo%Yjh*L@0fzf0c0
				MhdwZd#d@$$mhwaQbwk#%d0b&? -Zx   '<tkpdok#Wawpr^ '<(QOd0db&ahak#q:'m%k[}? UbwkOwmd8*p@$@BkW8aaW8aB8hhp8o*
				B@BB@BBB@$$B@BB%h@@@@B@B@v -%MmdI.  ;mBBBBB@BB@@@@@$@BBB@@@@@BB@c.OBBW+l" BBB@BB@BBBB@$@@B@$BB@@B@BBBBBBB
				QpUw*Q|p&$$fduLUXL0oMrCJh{ "CU]ixu[^  >1YxLZnm*$$BoBMZu1pb&W*0tf`ihmb[:' ?cxdpCQac|YcM$@kLo%vYh#C$UrdjQtu
				#*UOZOdJB$$OCrCa0*YL8ZzQ#h,.YZl`ZLXU|" .")MOJXW$$8ZvzXJmLmXO{I'' }Q*hL.I htvCaYwCLoJvB$@&n0*QYaMz&WbxqM*z
				8B#M@Mh8B$$M%MWa&B%B@MBM&o[ nd<.Y%hQpWvi  {hhW%@@%ohOLU|I.     ,_u0W8/,kroW#8&%#BM#MMB$$&W8@*oB@W$M#%oh*M
				adzoaJfLoW$&dJh*OhbbQ8Ut00k[<IX/">/i"iu/r/`:;_f(/+!:.      `I<(U*j]iCw_;0pL{a0Ymmufx/dM$%&#BaXdW0W&oxxZLU
				dbwZ#LwZn%$$&xOoQvMkc%apXq%hz]/L  X|  0Qhuf],    .'^I><_|JUz%x;wW^:'Q} ]Z0arkUzZdQd0cka$@a0kYcpLMJBM@0a0#
				Mo8hBhqaa&$$#hW@wd%Ba$bk%wOdhhjX. /#  Ud#l.bcnn(JQZ0a#&OM8#B(} ha  iol"Wo%8ZM#m#BadMbhW$$@&@8m*W*&$%hahmZ
				kmc*kYrUk#$$pzk8UwpdzBv(J0&|t(qp> l/" I|c  vp0hzB%$fwjQ)fZx)  .Q)  [t.1xCpJ_aLtZQnft1q*$$%*%orp*0oBM(rpQc
				*Moh&baamB$$%ZhWkw&#w%M*woBMq*h* ]Z[ !bb` rw#q?ctBwqr_ pkZ;  nb, Idix&dhkMO#pwa*k*kw#M$@Mh#pw*b&bB8@hWkW
				%&aMh*%b$$$#&&oWhM%%@Mo#md8##tk{.Yd:.(8n' ohar` J8*n^.1#B?. [&+'.bUWqZM*M@O*h8M&dhBhh@$@B@B8hw8%B%B8qoWb@
				nOdpUJXQ*@@#XwQjCz0XhJu0tWcvzu?Q!`+X"!-ut,i-hx_:i[wLi:^nuYt:;ru;"~0QZMcdQQCmxjW0vJuUq0@BB0On0aLZZq8LXXwaw
				WBB%W8&8%@@@&WWM&88W&%&&M@8&&%##~ )MnoQ,;0*I:1M#Y',!**1^'mM*,,<#j`:MWMI/&B8%WWB8&8M8BW@@@%&M8%WB&8@%&W8B%
				a&po%#dakhW$$@oB#dhbMh@#hMwWdd#*-'}mh%f:.Yo+ i#bJ  ^B&] 'Zkp '*h,'jMMZ ~k%*hk*dhB#mkbp#h@$$bobW#**WM$dha*
				wp/b&mz0X0w$$Bvzn/UQ0xLqcJj8YvYd_.xLnZt> nZi ^hnr  ^W8: "Ou- 1oz._Yaki^UL&CbLOxX80zQrCdv@$@LvtZbxhJU@0vuw
				8BB@BB@@@BB$$$@@@@BB@@@$@@B@BB@@f /%@B%u XBc .bB%  ^B@I ?BW+.J@a_MB%[,h%BB@BBB@BB@BB@BB@@$$B@B@B@@B@$B@@B
				JOzpkJLk#C0$$@qBkLwZ*w@**hOawZ%#U Iphkcw nQC' nJa  ^Ba  r*0^<o@mUQbb:^z#habzUdMQZkqhMk0#*$@UwLokwdpk@XwoW
				)Y?zzv{wh(X@$B(j([zu(/n0tLrorfxoL  ]OM}n([+z^ LrrI ^Wp .JZ[`pZBMwjvZ :nwCBc#xz+YdQ1ZOfv}&$@Yf}Qd/Q/j@n+uk
				8B%@@%&BB%B$$$B$BB%B@@$@@@8BB%@B%l )@@M%%#BBZ,k%%f ;@u nBB88@@@BBB&J cB@%@%B%B8%$@&BB%B%$$$BBBB%B@@@$BBB8
				#dvz8opOJww$$BLBZxZJkz$wzpZ*rvZk8X 'X#+ttZqrxcbXXh'n@i'bah*c%M@QXv?, k0bJ%#vzqdZWLUUn/phB$$rLcaaQLkm@tuQW
				ZbCd#qY0QOd$$BzCYvZ0YvZdzJJBLJYdb&-:ti xv0CZzbMUm%uw8n1UwdYZMko*#+.'[Cw80MQ*bbYZWLYQcq*Y@$@ZJzb*JdQ0@qXJw
				MB&@@8M%B8B$$$B$B%&%@B$BB@W%%8@@&WMdL  )%B%B%%B&&@B%@%8BBBWB$M-&u' 1#B%@8@&B%B&8@@#BB%%8@$$%B%B8%@@B$8%%&
				kwucWb0LXQ0$$BzoJt0JmxMZxO0*jrCd#p|/}   1LQ_/m*rx$$$Bobabbbno[ c^  h#mCaY8bzcZOZWJvXf/pmB$@fYrbhYJw0@tjYo
				aMbM8*baho#$$Bbkbpaakpo#dkbBakb#M%baC^  La>^O#8zi%$@B@hxb#bJ!' L" _&8koBa8h&##da%adap*&b@$@okp#&bMaa@*bbo
				W%%B8&W8BB@@B@%8B&%B%%BB&%&BBB88&8M*b!` (h^`f#%-,*MWMZJltMo1   Y^^Q&%@%%WW8B8W8%%8#%B%@%8@%&%%%&$%8%%B&W&
				LYhqvJXp@@bqUmcrUtOWUXaqXvbOOMvzzz"  [c  {/f .b@@q.` np}  "J  'wpwJrU%woY?ZhXzMQxvfLh@@M/wY[C0X|hJjzcWrtx
				BB@BBBB@$@@BBBBBBBB@BB@@@B@BB@BBBBj  vm  |Bn  u$@Z   W8I  iY  JB@@BBB@B$@%BBBB@BBBBB@@$@BBB%@@BB@BBBB@BBB
				*&bddZkd&B@BB8W&*#MW8B#pZ#8*akkh8Mvl'>xi".J/<.lCM0[ .vJ(' ~1} vZWhmqwo&wmbkdoqdWZwaab88@%a&bo#b&b8%Md*8p#
				x0-f)tOLU@@%*ZmLCxJbm8opYJapLq0fhYoC-.`Y~ "I)^ '0@b   [#. .nk  tMdY}|rWz/t||Qt)r1ckCvdM@B|L|Xm1f}O8zfb8z/
				@@$@@@@@@@$@@@@$@@@@@@@@@@@@@$@@@@@@81Ipa. i8l .(@h   Cq  ^qa }@@@@@@@@@@@@@$@@@$@@@@@$$@@$@@$@@@@$@@@@@@
				vdoYL*#bU@$@%*&#ahhh&B#wJdo#BaaXk#bbLqvYY< `c: .I@h   wt  lk8+vm%aUzvOWqL|zhmCComo8ZhmM$@OMLh*Y*0W%0oM%0J
				mUnv/ChL@@$v0vdWZuJd&L1c*apftJ#dQZnxJQY0_  |; .>&o` ~/x ^ua0JOdavuYo*Zr|u#ubxX[ujL&Zp@$@8Lh*dOpaw&&wOz#aw
				@@&%@BB%@$$B@BB%B@@@@B@%B%BBB88BB%BM@B@@#i 1X  Ioo' tBkcmB@@@@8BBB@BB%@&@@M&BB%B@B@B&$$$BBB@%8@@B@BB@%B%B
				bmLnj]kh@$$(mnQ#Lzmk#(rQ8L|(1a8Yt?f0w)vdLt .n  ;aW> ncJUpZ%pqpfwJJo#&cXUQMtvUhCf{jOcz$$@oY&%O*whL@w)+b8Lm
				#bZqLpWq$$$qwLbWphqbBhQ0WWaOmp&*baQmmZa#Oprrm} <8%QjJQwZZpphdaO&wqZ#*om0qMQp0kLqQp%wq@$@%0bWdO#&w8%#0p&8m
				@@B@@@@@@$$@@$@@@@@@$@@@@@@@@@@@@@@a$@$@@@@@$%z{$$@@@@$@@@$@@@@@@@@@@@@@@@B@@@@@@@@@@@$$@@@@@@B@@$$@@@@@@
				cdXmbZvYM$$|O/0*cJYp#/cZ&U)vLma/)cZ1mfuL||XC(bW@$%d*bXOYQmo*o0u0kwawwtkwOLjLkk(whntzXo$@azk8qwwbcBU/fm&c/
				WWMW8Mo#@$$#MoWBMooWB*aMB&#o#MB#oo*h&ooao*8&#8B$$BWWWoMa*W88&%WWWWW%%*&#%%**8%aMWo#Ma@$$BM8B&W88MB%WMM@8*

				avery why is this here
				**/
			
				defaultCamZoom = 0.68;
                hogBg = new BGSprite('hog/bg', 0, -300, 1.1, 0.9);
                hogBg.scale.x = 2;
                hogBg.scale.y = 2;
                add(hogBg);

				hogMotain = new BGSprite('hog/motains', 0, 0, 1.1, 0.9);
                hogMotain.scale.x = 1.5;
                hogMotain.scale.y = 1.5;
                add(hogMotain);

				hogWaterFalls = new FlxSprite(-1100, 200);
                hogWaterFalls.frames = Paths.getSparrowAtlas('hog/Waterfalls', 'exe');
                hogWaterFalls.animation.addByPrefix('water', 'British', 12);
                hogWaterFalls.animation.play('water');
                hogWaterFalls.scrollFactor.set(1, 1);
                add(hogWaterFalls);

                hogLoops = new FlxSprite(-200, 170);
                hogLoops.frames = Paths.getSparrowAtlas('hog/HillsandHills', 'exe');
                hogLoops.animation.addByPrefix('loops', 'DumbassMF', 12);
                hogLoops.animation.play('loops');
                hogLoops.scrollFactor.set(1, 0.9);
                add(hogLoops);

				hogTrees = new BGSprite('hog/trees', -600, -120, 1, 0.9);
                add(hogTrees);

				hogFloor = new BGSprite('hog/floor', -600, 750, 1.1, 0.9);
                hogFloor.scale.x = 1.25;
                hogFloor.scale.y = 1.25;
                add(hogFloor);

				hogRocks = new BGSprite('hog/rocks', -500, 600, 1.1, 0.9);
                hogRocks.scale.x = 1.25;
                hogRocks.scale.y = 1.25;

				hogOverlay = new BGSprite('hog/overlay', -800, -300, 1.1, 0.9);
                hogOverlay.scale.x = 1.25;
                hogOverlay.scale.y = 1.25;

				if (SONG.song.toLowerCase() == 'manual-blast')
					{
						camGlitchShader = new GlitchShaderB();
						camGlitchShader.iResolution.value = [FlxG.width, FlxG.height];
						camGlitchFilter = new ShaderFilter(camGlitchShader);

						camFuckShader = new Fuck();
						camFuckFilter = new ShaderFilter(camFuckShader);

						staticlol = new StaticShader();
						camGame.setFilters([new ShaderFilter(staticlol)]);
						staticlol.iTime.value = [0];
						staticlol.iResolution.value = [FlxG.width, FlxG.height];
						staticlol.alpha.value = [staticAlpha];
						camGame.filtersEnabled = false;

						scorchedBg = new BGSprite('hog/blast/Sunset', -200, 0, 1.1, 0.9);
						scorchedBg.scale.x = 1.75;
						scorchedBg.scale.y = 1.75;
						add(scorchedBg);
		
						scorchedMotain = new BGSprite('hog/blast/Mountains', 0, 0, 1.1, 0.9);
						scorchedMotain.scale.x = 1.5;
						scorchedMotain.scale.y = 1.5;
						add(scorchedMotain);
		
						scorchedWaterFalls = new FlxSprite(-1000, 200);
						scorchedWaterFalls.frames = Paths.getSparrowAtlas('hog/blast/Waterfalls', 'exe');
						scorchedWaterFalls.animation.addByPrefix('water', 'British instance 1', 12);
						scorchedWaterFalls.animation.play('water');
						scorchedWaterFalls.scale.x = 1.1;
						scorchedWaterFalls.scale.y = 1.1;
						scorchedWaterFalls.scrollFactor.set(1, 1);
						add(scorchedWaterFalls);

						scorchedHills = new BGSprite('hog/blast/Hills', -100, 230, 1, 0.9);
						add(scorchedHills);
		
						scorchedMonitor = new FlxSprite(1100, 265);
						scorchedMonitor.frames = Paths.getSparrowAtlas('hog/blast/Monitor', 'exe');
						scorchedMonitor.animation.addByPrefix('idle', 'Monitor', 12);
						scorchedMonitor.animation.addByPrefix('fatal', 'Fatalerror', 12);
						scorchedMonitor.animation.addByPrefix('nmi', 'NMI', 12);
						scorchedMonitor.animation.addByPrefix('needle', 'Needlemouse', 12);
						scorchedMonitor.animation.addByPrefix('starved', 'Storved', 12);
						scorchedMonitor.animation.play('idle');
						scorchedMonitor.scrollFactor.set(1, 0.9);
						add(scorchedMonitor);
						
		
						scorchedTrees = new BGSprite('hog/blast/Plants', -400, -50, 1, 0.9);
						add(scorchedTrees);
		
						scorchedFloor = new BGSprite('hog/blast/Floor', -400, 780, 1, 0.9);
						scorchedFloor.scale.x = 1.25;
						scorchedFloor.scale.y = 1.25;
						add(scorchedFloor);
		
						scorchedRocks = new BGSprite('hog/blast/Rocks', -500, 600, 1.1, 0.9);
						scorchedRocks.scale.x = 1.25;
						scorchedRocks.scale.y = 1.25;

						scorchedBg.visible = false;
						scorchedMotain.visible = false;
						scorchedWaterFalls.visible = false;
						scorchedHills.visible = false;
						scorchedMonitor.visible = false;
						scorchedTrees.visible = false;
						scorchedFloor.visible = false;
						scorchedRocks.visible = false;

					}

			default: //lol
				var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
				if(!ClientPrefs.lowQuality) {
					var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					add(stageLight);
					var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
					stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
					stageLight.updateHitbox();
					stageLight.flipX = true;
					add(stageLight);

					var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					add(stageCurtains);
				}
		}

		if(isPixelStage) {
			introSoundsSuffix = '-pixel';
		}

		add(gfGroup); //Needed for blammed lights

		add(dadGroup);
		add(boyfriendGroup);

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end


		// "GLOBAL" SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('scripts/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('scripts/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/scripts/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end


		// STAGE SCRIPTS
		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = 'stages/' + curStage + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
			luaArray.push(new FunkinLua(luaFile));
		#end


		var gfVersion:String = SONG.gfVersion;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.gfVersion = gfVersion; //Fix for the Chart Editor
		}

		if (!stageData.hide_girlfriend)
		{
			gf = new Character(0, 0, gfVersion);
			startCharacterPos(gf);
			gf.scrollFactor.set(0.95, 0.95);
			gfGroup.add(gf);
			startCharacterLua(gf.curCharacter);
		}

		dad = new Character(0, 0, SONG.player2);
		startCharacterPos(dad, true);
		dadGroup.add(dad);
		startCharacterLua(dad.curCharacter);

		boyfriend = new Boyfriend(0, 0, SONG.player1);
		startCharacterPos(boyfriend);
		boyfriendGroup.add(boyfriend);
		startCharacterLua(boyfriend.curCharacter);

		var camPos:FlxPoint = new FlxPoint(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.cameraPosition[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.cameraPosition[1];
		}

		if(dad.curCharacter.startsWith('gf')) {
			dad.setPosition(GF_X, GF_Y);
			if(gf != null)
				gf.visible = false;
		}

		switch(curStage)
		{
			case 'entrance':
				gfGroup.visible = false;

				theStatic = new FlxSprite(0, 0);
				theStatic.frames = Paths.getSparrowAtlas('staticc', 'exe');
				theStatic.animation.addByPrefix('stat', "staticc", 24, true);
				theStatic.animation.play('stat');
				theStatic.cameras = [camOther];
				theStatic.setGraphicSize(FlxG.width, FlxG.height);
				theStatic.screenCenter();
				theStatic.alpha = 0;
				add(theStatic);

			case 'horizon':
				boyfriend.y += 68;
				gf.x += 375;
				gf.y += 575;
				dad.x -= 90;
				dad.y += 70;
				if (SONG.song.toLowerCase() == 'our-horizon')
					{
						add(horizonKnuckles);
						add(horizonVector);
					}
			case 'founded':
				dad.visible = false;
				dad.x -= 500;
				add(normalDoor);
				add(normalFg);
				add(normalVg);
			case 'chotix':
				gf.visible = false;
				dad.setPosition(-500, 350);
			case 'curse':
				gf.x -= 50;
				gf.y -= 100;
				boyfriend.x += 70;
			case 'hog':
				gfGroup.visible = false;
				add(hogRocks);
				add(hogOverlay);
				if (SONG.song.toLowerCase() == 'manual-blast')
					{
						add(scorchedRocks);
					}
				hogOverlay.blend = LIGHTEN;
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
		}

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		var showTime:Bool = (ClientPrefs.timeBarType != 'Disabled');
		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 19, 400, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = showTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 44;

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.text = SONG.song;
		}
		updateTime = showTime;

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = showTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = showTime;

		if (!isPixelHUD)
			{
				add(timeBarBG);
				add(timeBar);
				add(timeTxt);
			}

		timeBarBG.sprTracker = timeBar;


		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		if(ClientPrefs.timeBarType == 'Song Name')
		{
			timeTxt.size = 24;
			timeTxt.y += 3;
		}

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();

		barbedWires = new FlxTypedGroup<ShakableSprite>();
		for(shit in 0...6){
			var wow = shit+1;
			var wire:ShakableSprite = new ShakableSprite().loadGraphic(Paths.image('barbedWire/' + wow));
			wire.scrollFactor.set();
			wire.antialiasing=true;
			wire.setGraphicSize(FlxG.width, FlxG.height);
			wire.updateHitbox();
			wire.screenCenter(XY);
			wire.alpha=0;
			wire.extraInfo.set("inUse",false);
			wire.cameras = [camOther];
			barbedWires.add(wire);
		}

		wireVignette = new FlxSprite().loadGraphic(Paths.image('black_vignette','exe'));
		wireVignette.scrollFactor.set();
		wireVignette.antialiasing=true;
		wireVignette.setGraphicSize(FlxG.width, FlxG.height);
		wireVignette.updateHitbox();
		wireVignette.screenCenter(XY);
		wireVignette.alpha=0;
		wireVignette.cameras = [camOther];
		wireVignette.cameras = [camOther];
			

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_notetypes/' + notetype + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		for (event in eventPushedMap.keys())
		{
			var luaToLoad:String = Paths.modFolders('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad))
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			else
			{
				luaToLoad = Paths.getPreloadPath('custom_events/' + event + '.lua');
				if(FileSystem.exists(luaToLoad))
				{
					luaArray.push(new FunkinLua(luaToLoad));
				}
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		healthBar.alpha = ClientPrefs.healthBarAlpha;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		iconP1.visible = !ClientPrefs.hideHud;
		iconP1.alpha = ClientPrefs.healthBarAlpha;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		iconP2.visible = !ClientPrefs.hideHud;
		iconP2.alpha = ClientPrefs.healthBarAlpha;
		add(iconP2);
		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		if (!isPixelHUD)
			{
				add(scoreTxt);
			}

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		// create the custom hud
		trace(curSong.toLowerCase());
		if(hudStyle.exists(curSong.toLowerCase())){
			chaotixHUD = new FlxSpriteGroup(33, 0);
			var labels:Array<String> = [
				"score",
				"time",
				"misses"
			];
			var scale:Float = 3;
			var style:String = hudStyle.get(curSong.toLowerCase());
			switch(style){
				case 'chotix':
					scale = 0.75;
			}

			for(i in 0...labels.length){
				var name = labels[i];
				var y = 48 * (i+1);
				var label = new FlxSprite(0, y);
				switch(name){
					case 'rings':
						label.loadGraphic(Paths.image('sonicUI/$style/$name'), true, 83, 12);
						label.animation.add("blink", [0, 1], 2);
						label.animation.add("static", [0], 0);
					case 'fullcombo':
						label.loadGraphic(Paths.image('sonicUI/$style/$name'), true, 83, 12);
						label.animation.add("blink", [0, 1], 2);
					default:
						label.loadGraphic(Paths.image('sonicUI/$style/$name'));
				}

				label.setGraphicSize(Std.int(label.width * scale));
				label.updateHitbox();
				label.antialiasing=false;
				label.scrollFactor.set();
				chaotixHUD.add(label);
				var hasDisplay:Bool = false;
				var displayCount:Int = 0;
				var displayX:Float = 150;
				var dispVar:String = '';
				switch(name){
					case 'rings':
						hasDisplay = true;
						displayCount = 3;
						displayX = 174;
						label.animation.play("blink", true);
						ringsLabel = label;
					case 'score':
						hasDisplay = true;
						displayCount = 7;
						dispVar = 'songScore';
					case 'fullcombo':
						hasDisplay = false;
						//fcLabel = label;
						label.animation.play("blink", true);
					case 'fc':
						hasDisplay = false;
						fcLabel = label;
						label.animation.play("SFC", true);
					case 'time':
						hasDisplay = false;
						hudMinute = new SonicNumber(150, y + (3 * scale), '0', style);
						hudMinute.setGraphicSize(Std.int(hudMinute.width * scale));
						hudMinute.updateHitbox();

						hudSeconds = new SonicNumberDisplay(198, y + (3 * scale), 2, scale, 0, style);
						hudMS = new SonicNumberDisplay(270, y + (3 * scale), 2, scale, 0, style);
						if(style=='chotix'){
							hudSeconds.x = 270;
							hudMS.x = 198;
							hudSeconds.blankCharacter = 'sex';
							hudMS.blankCharacter = 'sex';
						}else{
							hudSeconds.blankCharacter = '0';
							hudMS.blankCharacter = '0';
						}



						var singleQuote = new FlxSprite(171, y).loadGraphic(Paths.image('sonicUI/$style/colon'));
						singleQuote.setGraphicSize(Std.int(singleQuote.width * scale));
						singleQuote.updateHitbox();
						singleQuote.antialiasing=false;
						var doubleQuote = new FlxSprite(243, y).loadGraphic(Paths.image('sonicUI/$style/quote'));
						doubleQuote.setGraphicSize(Std.int(doubleQuote.width * scale));
						doubleQuote.updateHitbox();
						doubleQuote.antialiasing=false;

						singleQuote.x = 171;
						doubleQuote.x = 243;
						singleQuote.y = y;
						doubleQuote.y = y;

						chaotixHUD.add(singleQuote);
						chaotixHUD.add(doubleQuote);
						chaotixHUD.add(hudMinute);
						chaotixHUD.add(hudSeconds);
						chaotixHUD.add(hudMS);
					case 'misses':
						hasDisplay = true;
						displayCount = 3;
						displayX = 174;
						dispVar = 'songMisses';
						fcLabel = new FlxSprite(174 + ((8 * 3) * (displayCount+1)), y);
						fcLabel.loadGraphic(Paths.image('sonicUI/$style/fc'));
						fcLabel.loadGraphic(Paths.image('sonicUI/$style/fc'), true, Std.int(fcLabel.width/4), Std.int(fcLabel.height/2));
						fcLabel.animation.add("SFC", [0, 4], 0);
						fcLabel.animation.add("GFC", [1, 5], 0);
						fcLabel.animation.add("FC", [2, 6], 0);
						fcLabel.animation.add("SDCB", [3, 7], 0);
						fcLabel.setGraphicSize(Std.int(fcLabel.width * scale));
						fcLabel.updateHitbox();
						fcLabel.antialiasing=false;
						fcLabel.scrollFactor.set();
						fcLabel.animation.play("SFC", true);
						chaotixHUD.add(fcLabel);
				}
				if(hasDisplay){
					var dis:SonicNumberDisplay = new SonicNumberDisplay(displayX, y + (3 * scale), displayCount, scale, 0, style, this, dispVar);
					hudDisplays.set(name, dis);
					chaotixHUD.add(dis);
				}
			}

			add(chaotixHUD);

			if(!ClientPrefs.downScroll){
				for(member in chaotixHUD.members)
					member.y = (FlxG.height-member.height-member.y);
			}
			chaotixHUD.cameras = [camHUD];
		}

		/*if (SONG.song.toLowerCase() == 'our-horizon' || SONG.song.toLowerCase() == 'my-horizon') 
		{
			add(chaotixHUD);
		}*/

		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		startCircle.cameras = [camOther];
		startText.cameras = [camOther];
		blackFuck.cameras = [camOther];
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		// SONG SPECIFIC SCRIPTS
		#if LUA_ALLOWED
		var filesPushed:Array<String> = [];
		var foldersToCheck:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + '/')];

		#if MODS_ALLOWED
		foldersToCheck.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		if(Paths.currentModDirectory != null && Paths.currentModDirectory.length > 0)
			foldersToCheck.insert(0, Paths.mods(Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/'));
		#end

		for (folder in foldersToCheck)
		{
			if(FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if(file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
				}
			}
		}
		#end

		add(barbedWires);
		add(wireVignette);

		var daSong:String = Paths.formatToSongPath(curSong);
	
		switch (daSong)
			{
				case 'my-horizon' | 'our-horizon' | 'breakout' | 'malediction' | 'long-sky':
					add(blackFuck);
					startCircle.loadGraphic(Paths.image('openings/' + daSong + '_title_card', 'exe'));
					startCircle.frames = Paths.getSparrowAtlas('openings/' + daSong + '_title_card', 'exe');
					startCircle.animation.addByPrefix('idle', daSong + '_title', 24, false);
					//startCircle.setGraphicSize(Std.int(startCircle.width * 0.6));
					startCircle.alpha = 0;
					startCircle.screenCenter();
					add(startCircle);

					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							FlxTween.tween(startCircle, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut});
						});

					new FlxTimer().start(2.2, function(tmr:FlxTimer)
						{
							FlxTween.tween(blackFuck, {alpha: 0}, 2, {
								onComplete: function(twn:FlxTween)
								{
									remove(blackFuck);
									blackFuck.destroy();
									startCircle.animation.play('idle');
								}
							});
							FlxTween.tween(startCircle, {alpha: 1}, 4, {
								onComplete: function(twn:FlxTween)
								{
									remove(startCircle);
									startCircle.destroy();
								}
							});
						});
						new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								startCountdown();
							});
				case 'found-you':
					snapCamFollowToPos(700, 400);
					new FlxTimer().start(0, function(tmr:FlxTimer)
						{
							FlxG.camera.focusOn(camFollowPos.getPosition());
						});
					camHUD.visible = false;
					startCountdown();
				
				default:
					startCountdown();
			}
		
		RecalculateRating();

		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		if(ClientPrefs.hitsoundVolume > 0) CoolUtil.precacheSound('hitsound');
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		if (PauseSubState.songName != null) {
			CoolUtil.precacheMusic(PauseSubState.songName);
		} else if(ClientPrefs.pauseMusic != 'None') {
			CoolUtil.precacheMusic(Paths.formatToSongPath(ClientPrefs.pauseMusic));
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}

		Conductor.safeZoneOffset = (ClientPrefs.safeFrames / 60) * 1000;
		callOnLuas('onCreatePost', []);

		super.create();

		Paths.clearUnusedMemory();
		CustomFadeTransition.nextCamera = camOther;
	}

	function glitchFreeze()
	{
		var screencap:FlxSprite;
		screencap = new FlxSprite(0, 0, FlxScreenGrab.grab().bitmapData);
		FlxScreenGrab.defineCaptureRegion(0, 0, Std.int(FlxG.width / 2), Std.int(FlxG.height));
		screencap.cameras = [camHUD];
		scoreRandom = true;
		switch(FlxG.random.int(1, 2)){
			case 1:
				var glitchEffect = new FlxGlitchEffect(30,8,0.4,FlxGlitchDirection.HORIZONTAL);
				var glitchSprite = new FlxEffectSprite(screencap, [glitchEffect]);
				glitchSprite.scrollFactor.set(0,0);
				glitchSprite.cameras = [camHUD];
				glitchSprite.width = FlxG.width;
				glitchSprite.height = FlxG.height;
				add(glitchSprite);
					new FlxTimer().start(0.2, function(byebye:FlxTimer) {
						remove(glitchSprite);
					});
			case 2:
				camGame.filtersEnabled = true;
				new FlxTimer().start(0.45, function(byebye:FlxTimer) {
					camGame.filtersEnabled = false;
				});
		}
		// this is all commented for now
		// switch(FlxG.random.int(1, 8)){
		// 	case 1:
		// 		iconP1.changeIcon('dad');
		// 		iconP2.changeIcon('normal');
		// 	case 2:
		// 		iconP1.changeIcon('bf-chaotix');
		// 		iconP2.changeIcon('curse-pissbaby');
		// 	case 3:
		// 		iconP1.changeIcon('duke');
		// 		iconP2.changeIcon('gf');
		// 	case 4:
		// 		iconP1.changeIcon('hog');
		// 		iconP2.changeIcon('metal');
		// 	case 5:
		// 		iconP1.changeIcon('amy');
		// 		iconP2.changeIcon('chaotix-beast-pixel');
		// 	case 6:
		// 		iconP1.changeIcon('scorched');
		// 		iconP2.changeIcon('dad');
		// 	case 7:
		// 		iconP1.changeIcon('normal');
		// 		iconP2.changeIcon('chaotix-pixel');
		// 	case 8:
		// 		iconP1.changeIcon('duo');
		// 		iconP2.changeIcon('amy');
		// 	}
		// 	new FlxTimer().start(0.85, function(byebye:FlxTimer) {
		// 		iconP1.changeIcon(boyfriend.healthIcon);
		// 		iconP2.changeIcon(dad.healthIcon);
		// 		reloadHealthBarColors();
		// 	});
	}	

	function set_songSpeed(value:Float):Float
	{
		if(generatedMusic)
		{
			var ratio:Float = value / songSpeed; //funny word huh
			for (note in notes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
			for (note in unspawnNotes)
			{
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
				{
					note.scale.y *= ratio;
					note.updateHitbox();
				}
			}
		}
		songSpeed = value;
		noteKillOffset = 350 / songSpeed;
		return value;
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});

		if(luaDebugGroup.members.length > 34) {
			var blah = luaDebugGroup.members[34];
			blah.destroy();
			luaDebugGroup.remove(blah);
		}
		luaDebugGroup.insert(0, new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarColors() {
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));

		healthBar.updateBar();
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					startCharacterLua(newBoyfriend.curCharacter);
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					dadGroup.add(newDad);
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					startCharacterLua(newDad.curCharacter);
				}

			case 2:
				if(gf != null && !gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					gfGroup.add(newGf);
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					startCharacterLua(newGf.curCharacter);
				}
		}
	}

	function startCharacterLua(name:String)
	{
		#if LUA_ALLOWED
		var doPush:Bool = false;
		var luaFile:String = 'characters/' + name + '.lua';
		if(FileSystem.exists(Paths.modFolders(luaFile))) {
			luaFile = Paths.modFolders(luaFile);
			doPush = true;
		} else {
			luaFile = Paths.getPreloadPath(luaFile);
			if(FileSystem.exists(luaFile)) {
				doPush = true;
			}
		}

		if(doPush)
		{
			for (lua in luaArray)
			{
				if(lua.scriptName == luaFile) return;
			}
			luaArray.push(new FunkinLua(luaFile));
		}
		#end
	}

	function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
			char.danceEveryNumBeats = 2;
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				startAndEnd();
			}
			return;
		}
		else
		{
			FlxG.log.warn('Couldnt find video file: ' + fileName);
			startAndEnd();
		}
		#end
		startAndEnd();
	}

	function startAndEnd()
	{
		if(endingSong)
			endSong();
		else
			startCountdown();
	}

	var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:DialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, song);
			psychDialogue.scrollFactor.set();
			if(endingSong) {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					endSong();
				}
			} else {
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					startCountdown();
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			psychDialogue.cameras = [camHUD];
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];
	public static var startOnTime:Float = 0;

	public function startCountdown():Void
	{
		if(startedCountdown) {
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if(ret != FunkinLua.Function_Stop) {
			if (skipCountdown || startOnTime > 0) skipArrowStartTween = true;

			generateStaticArrows(0);
			generateStaticArrows(1);
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				//if(ClientPrefs.middleScroll) opponentStrums.members[i].visible = false;
			}

			if (isPixelHUD)
				{
					healthBar.x += 150;
					iconP1.x += 150;
					iconP2.x += 150;
					healthBarBG.x += 150;
				}
			else
				{
					//lol
				}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);
			callOnLuas('onCountdownStarted', []);

			var swagCounter:Int = 0;

			if (skipCountdown || startOnTime > 0) {
				clearNotesBefore(startOnTime);
				setSongTime(startOnTime - 500);
				return;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (gf != null && tmr.loopsLeft % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
				{
					gf.dance();
				}
				if (tmr.loopsLeft % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
				{
					boyfriend.dance();
					bfCamThing = [0, 0];
				}
				if (tmr.loopsLeft % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
				{
					dad.dance();
					dadCamThing = [0, 0];
				}

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['ready', 'set', 'go']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}

				switch (swagCounter)
				{
					case 0:
					case 1:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();

						if (PlayState.isPixelStage)
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

						ready.screenCenter();
						ready.antialiasing = antialias;
						countDownSprites.push(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(ready);
								remove(ready);
								ready.destroy();
							}
						});
					case 2:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();

						if (PlayState.isPixelStage)
							set.setGraphicSize(Std.int(set.width * daPixelZoom));

						set.screenCenter();
						set.antialiasing = antialias;
						countDownSprites.push(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(set);
								remove(set);
								set.destroy();
							}
						});
					case 3:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();

						if (PlayState.isPixelStage)
							go.setGraphicSize(Std.int(go.width * daPixelZoom));

						go.updateHitbox();

						go.screenCenter();
						go.antialiasing = antialias;
						countDownSprites.push(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								countDownSprites.remove(go);
								remove(go);
								go.destroy();
							}
						});
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = note.multAlpha;
					if(ClientPrefs.middleScroll && !note.mustPress) {
						note.alpha *= 0.5;
					}
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) {
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) {
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				daNote.active = false;
				daNote.visible = false;
				daNote.ignoreNote = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	public function setSongTime(time:Float)
	{
		if(time < 0) time = 0;

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = time;
		FlxG.sound.music.play();

		vocals.time = time;
		vocals.play();
		Conductor.songPosition = time;
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = onSongComplete;
		vocals.play();

		if(startOnTime > 0)
		{
			setSongTime(startOnTime - 500);
		}
		startOnTime = 0;

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());
		songSpeedType = ClientPrefs.getGameplaySetting('scrolltype','multiplicative');

		switch(songSpeedType)
		{
			case "multiplicative":
				songSpeed = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1);
			case "constant":
				songSpeed = ClientPrefs.getGameplaySetting('scrollspeed', 1);
		}

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);
		FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(PlayState.SONG.song)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String = Paths.json(songName + '/events');
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/events')) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<Dynamic> = Song.loadFromJson('events', songName).events;
			for (event in eventsData) //Event Notes
			{
				for (i in 0...event[1].length)
				{
					var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
					var subEvent:EventNote = {
						strumTime: newEventNote[0] + ClientPrefs.noteOffset,
						event: newEventNote[1],
						value1: newEventNote[2],
						value2: newEventNote[3]
					};
					subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
					eventNotes.push(subEvent);
					eventPushed(subEvent);
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
			
				var pixelStage = isPixelStage;
				if(daStrumTime >= Conductor.stepToSeconds(1000) && SONG.song.toLowerCase()=='our-horizon')
					isPixelStage = false;
				
				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.mustPress = gottaHitNote;
				swagNote.sustainLength = songNotes[2];
				swagNote.gfNote = (section.gfSection && (songNotes[1]<4));
				swagNote.noteType = songNotes[3];
				if(!Std.isOfType(songNotes[3], String)) swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts

				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				var floorSus:Int = Math.floor(susLength);
				if(floorSus > 0) {
					for (susNote in 0...floorSus+1)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(songSpeed, 2)), daNoteData, oldNote, true);
						sustainNote.mustPress = gottaHitNote;
						sustainNote.gfNote = (section.gfSection && (songNotes[1]<4));
						sustainNote.noteType = swagNote.noteType;
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							sustainNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								sustainNote.x += FlxG.width / 2 + 25;
							}
						}
					}
				}

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else if(ClientPrefs.middleScroll)
				{
					swagNote.x += 310;
					if(daNoteData > 1) //Up and Right
					{
						swagNote.x += FlxG.width / 2 + 25;
					}
				}

				if(!noteTypeMap.exists(swagNote.noteType)) {
					noteTypeMap.set(swagNote.noteType, true);
				}
				isPixelStage = pixelStage;
			}
			daBeats += 1;
		}
		for (event in songData.events) //Event Notes
		{
			for (i in 0...event[1].length)
			{
				var newEventNote:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
				var subEvent:EventNote = {
					strumTime: newEventNote[0] + ClientPrefs.noteOffset,
					event: newEventNote[1],
					value1: newEventNote[2],
					value2: newEventNote[3]
				};
				subEvent.strumTime -= eventNoteEarlyTrigger(subEvent);
				eventNotes.push(subEvent);
				eventPushed(subEvent);
			}
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	function eventPushed(event:EventNote) {
		switch(event.event) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event.value1.toLowerCase()) {
					case 'gf' | 'girlfriend' | '1':
						charType = 2;
					case 'dad' | 'opponent' | '0':
						charType = 1;
					default:
						charType = Std.parseInt(event.value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event.value2;
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event.event)) {
			eventPushedMap.set(event.event, true);
		}
	}

	function eventNoteEarlyTrigger(event:EventNote):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event.event]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event.event) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:EventNote, Obj2:EventNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	public var skipArrowStartTween:Bool = false; //for lua
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var targetAlpha:Float = 1;
			if (player < 1 && ClientPrefs.middleScroll) targetAlpha = 0.35;

			var babyArrow:StrumNote = new StrumNote(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, strumLine.y, i, player);
			babyArrow.downScroll = ClientPrefs.downScroll;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				if(ClientPrefs.middleScroll)
				{
					babyArrow.x += 310;
					if(i > 1) { //Up and Right
						babyArrow.x += FlxG.width / 2 + 25;
					}
				}
				opponentStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.postAddedToGroup();
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;
			if (songSpeedTween != null)
				songSpeedTween.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}

			for (tween in piss)
			{
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;
			if (songSpeedTween != null)
				songSpeedTween.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (char in chars) {
				if(char != null && char.colorTween != null) {
					char.colorTween.active = true;
				}
			}

			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (tween in piss) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;

			FlxTween.globalManager.forEach(function(tween:FlxTween)
				{
					tween.active = true;
				});
				FlxTimer.globalManager.forEach(function(timer:FlxTimer)
				{
					timer.active = true;
				});

			callOnLuas('onResume', []);

			#if desktop
			if (startTimer != null && startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var lastSection:Int = 0;

	override public function update(elapsed:Float)
	{
		/*if (FlxG.keys.justPressed.NINE)
		{
			iconP1.swapOldIcon();
		}*/
		if(camFuckShader!=null)
			camFuckShader.iTime.value[0] = Conductor.songPosition / 1000;
		
		if(camGlitchShader!=null){
			camGlitchShader.iResolution.value = [FlxG.width, FlxG.height];
			camGlitchShader.iTime.value[0] = Conductor.songPosition / 1000;
			if(camGlitchShader.amount>=1)camGlitchShader.amount=1;
			if(dad.curCharacter.startsWith("scorchedglitch"))
				camGlitchShader.amount = FlxMath.lerp(0.1, camGlitchShader.amount, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			else
				camGlitchShader.amount = FlxMath.lerp(0, camGlitchShader.amount, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}
		for(shader in glitchShaders){
			shader.iTime.value[0] += elapsed;
		}

		wireVignette.alpha = FlxMath.lerp(wireVignette.alpha, hexes/6, elapsed / (1/60) * 0.2);
		if(hexes > 0){
			var hpCap = 1.6 - ((hexes-1) * 0.3);
			if(hpCap < 0)
				hpCap = 0;
			var loss = 0.005 * (elapsed/(1/120));
			var newHP = health - loss;
			if(newHP < hpCap){
				loss = health - hpCap;
				newHP = health - loss;
			}
			if(loss<0)
				loss = 0;
			if(newHP > hpCap)
				health -= loss;
		}

		if(hexes>0)
		{
			hexTimer += elapsed;
			if (hexTimer >= 5)
			{
				hexTimer=0;
				hexes--;
				updateWires();
			}
		}

		var targetHP:Float = health;

		if (fucklesMode)
			{
				fucklesDrain = 0.0005; // copied from exe 2.0 lol sorry
				/*var reduceFactor:Float = combo / 150;
				if(reduceFactor>1)reduceFactor=1;
				reduceFactor = 1 - reduceFactor;
				health -= (fucklesDrain * (elapsed/(1/120))) * reduceFactor * drainMisses;*/
				if(drainMisses > 0)
					health -= (fucklesDrain * (elapsed/(1/120))) * drainMisses;
				else
					drainMisses = 0;

			}
		if(fucklesMode)
			{
				var newTarget:Float = FlxMath.lerp(health, targetHP, 0.1*(elapsed/(1/60)));
				if(Math.abs(newTarget-targetHP)<.002)
					{
						newTarget = targetHP;
		  			}
		 		else
					{
						targetHP = newTarget;
					}
			}

			targetHP = health;

		callOnLuas('onUpdate', [elapsed]);

		switch (curStage)
		{
		}

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * cameraSpeed, 0, 1);
			var offX:Float = 0;
			var offY:Float = 0;
			var focus:Character = boyfriend;
			var curSection:Int = Math.floor(curStep / 16);
			if(SONG.notes[curSection]!=null){
				if (gf != null && SONG.notes[curSection].gfSection)
				{
					focus = gf;
				}else if (!SONG.notes[curSection].mustHitSection)
				{
					focus = dad;
				}
			}
			if(focus.animation.curAnim!=null){
				var name = focus.animation.curAnim.name;
				if(name.startsWith("singLEFT"))
					offX = -20;
				else if(name.startsWith("singRIGHT"))
					offX = 20;

				if(name.startsWith("singUP"))
					offY = -20;
				else if(name.startsWith("singDOWN"))
					offY = 20;
			}

			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + offX, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + offY, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		if(staticlol!=null){
			staticlol.iTime.value[0] = Conductor.songPosition / 1000;
			staticlol.alpha.value = [staticAlpha];
		}

		super.update(elapsed);
		if(ratingName == '?') {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName;
		} else {
			scoreTxt.text = 'Score: ' + songScore + ' | Misses: ' + songMisses + ' | Rating: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
		}
		new FlxTimer().start(0.2, function(byebye:FlxTimer) {
		if(scoreRandom){
			switch(FlxG.random.int(1, 6)) {
				case 1:
					scoreTxt.text = 'sC0r3: ' + songScore + ' | m11ses: ' + songMisses + ' | R4t3ng: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				case 2:
					scoreTxt.text = 'mIsees: ' + songScore + ' | raITNtg: ' + songMisses + ' | socRec: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				case 3:
					scoreTxt.text = 'Ra11utNg: ' + songScore + ' | scIrh4: ' + songMisses + ' | Moosiies: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				case 4:
					scoreTxt.text = '342hj1: ' + songScore + ' | 5436yu: ' + songMisses + ' | 876rygu: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				case 5:
					scoreTxt.text = 'agehjk3: ' + songScore + ' | 4uihja: ' + songMisses + ' | 8ubnmb1: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
				case 6:
					scoreTxt.text = '4276uihj: ' + songScore + ' | a7d5h: ' + songMisses + ' | z7dyguhj: ' + ratingName + ' (' + Highscore.floorDecimal(ratingPercent * 100, 2) + '%)' + ' - ' + ratingFC;//peeps wanted no integer rating
			}
		}});

		if(botplayTxt.visible) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{

			FlxTween.globalManager.forEach(function(tween:FlxTween)
				{
					tween.active = false;
				});

				FlxTimer.globalManager.forEach(function(timer:FlxTimer)
				{
					timer.active = false;
				});

			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000 chance for Gitaroo Man easter egg
				/*if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					cancelMusicFadeTween();
					MusicBeatState.switchState(new GitarooPause());
				}
				else {*/
				if(FlxG.sound.music != null) {
					FlxG.sound.music.pause();
					vocals.pause();
				}
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				//}

				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.anyJustPressed(debugKeysChart) && !endingSong && !inCutscene)
		{
			openChartEditor();
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 9), 0, 1));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - iconOffset;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - iconOffset * 2;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		if (FlxG.keys.anyJustPressed(debugKeysCharacter) && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelMusicFadeTween();
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (startingSong)
		{
			if (startedCountdown)
				{
					Conductor.songPosition += elapsed * 1000;
					if (Conductor.songPosition >= 0)
					{
						switch (curSong)
						{
							case 'my-horizon':
								startSong();
							default:
								startSong();
						}
					}
				}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = Conductor.songPosition - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var songCalc:Float = (songLength - curTime);
					if(ClientPrefs.timeBarType == 'Time Elapsed') songCalc = curTime;

					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					if(ClientPrefs.timeBarType != 'Song Name')
						timeTxt.text = FlxStringUtil.formatTime(secondsTotal, false);

					if(chaotixHUD!=null){
						var curMS:Float = Math.floor(curTime);
						var curSex:Int = Math.floor(curMS / 1000);
						if (curSex < 0)
							curSex = 0;

						var curMins = Math.floor(curSex / 60);
						curMS%=1000;
						curSex%=60;

						curMS = Math.round(curMS/10);
						var stringMins = Std.string(curMins).split("");
						if(curMins > 9){
							hudMinute.number = '9';
							hudSeconds.displayed = 59;
							hudMS.displayed = 99;
						}else{
							hudMinute.number = stringMins[0];
							hudSeconds.displayed = curSex;
							hudMS.displayed = Std.int(curMS);
						}
					}



				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}



		if (camZooming)
		{
			var focus:Character = boyfriend;
			var curSection:Int = Math.floor(curStep / 16);
			if(SONG.notes[curSection]!=null){
				if (gf != null && SONG.notes[curSection].gfSection)
				{
					focus = gf;
				}else if (!SONG.notes[curSection].mustHitSection)
				{
					focus = dad;
				}
			}

			switch (focus.curCharacter)
			{
				case "beast_chaotix":
					FlxG.camera.zoom = FlxMath.lerp(1.2, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
				default:
					FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			}
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (!ClientPrefs.noReset && controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		doDeathCheck();

		if (unspawnNotes[0] != null)
		{
			var time:Float = 3000;//shit be werid on 4:3
			if(songSpeed < 1) time /= songSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			if (!inCutscene) {
				if(!cpuControlled) {
					keyShit();
				} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
					boyfriend.dance();
					//boyfriend.animation.curAnim.finish();
				}
			}

			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				var strumGroup:FlxTypedGroup<StrumNote> = playerStrums;
				if(!daNote.mustPress) strumGroup = opponentStrums;

				var strumX:Float = strumGroup.members[daNote.noteData].x;
				var strumY:Float = strumGroup.members[daNote.noteData].y;
				var strumAngle:Float = strumGroup.members[daNote.noteData].angle;
				var strumDirection:Float = strumGroup.members[daNote.noteData].direction;
				var strumAlpha:Float = strumGroup.members[daNote.noteData].alpha;
				var strumScroll:Bool = strumGroup.members[daNote.noteData].downScroll;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;

				if (strumScroll) //Downscroll
				{
					//daNote.y = (strumY + 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}
				else //Upscroll
				{
					//daNote.y = (strumY - 0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * songSpeed);
				}

				var angleDir = strumDirection * Math.PI / 180;
				if (daNote.copyAngle)
					daNote.angle = strumDirection - 90 + strumAngle;

				if(daNote.copyAlpha)
					daNote.alpha = strumAlpha;

				if(daNote.copyX)
					daNote.x = strumX + Math.cos(angleDir) * daNote.distance;

				if(daNote.copyY)
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
					if(strumScroll && daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end')) {
							daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * songSpeed + (46 * (songSpeed - 1));
							daNote.y -= 46 * (1 - (fakeCrochet / 600)) * songSpeed;
							if(PlayState.isPixelStage) {
								daNote.y += 8 + (6 - daNote.originalHeightForCalcs) * PlayState.daPixelZoom;
							} else {
								daNote.y -= 19;
							}
						}
						daNote.y += (Note.swagWidth / 2) - (60.5 * (songSpeed - 1));
						daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (songSpeed - 1);
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					opponentNoteHit(daNote);
				}

				if(daNote.mustPress && cpuControlled) {
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}

				var center:Float = strumY + Note.swagWidth / 2;
				if(strumGroup.members[daNote.noteData].sustainReduce && daNote.isSustainNote && (daNote.mustPress || !daNote.ignoreNote) &&
					(!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					if (strumScroll)
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}

				// Kill extremely late notes and cause misses
				if (Conductor.songPosition > noteKillOffset + daNote.strumTime)
				{
					if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
						noteMiss(daNote);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		checkEventNote();

		#if debug
		if(!endingSong && !startingSong) {
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
		}
		#end

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);
	}

	function openChartEditor()
	{
		persistentUpdate = false;
		paused = true;
		cancelMusicFadeTween();
		MusicBeatState.switchState(new ChartingState());
		chartingMode = true;

		#if desktop
		DiscordClient.changePresence("Chart Editor", null, null, true);
		#end
	}

	function fireWorksDeluxe()
		{

			horizonRed.animation.play('idle');

			new FlxTimer().start(2, function(tmr:FlxTimer) {
				horizonPurpur.animation.play('idle');
			});

			new FlxTimer().start(0.5, function(tmr:FlxTimer) {
				horizonYellow.animation.play('idle');
			});



			
		}

	public var isDead:Bool = false; //Don't mess with this on Lua!!!
	function doDeathCheck(?skipHealthCheck:Bool = false) {
		if (((skipHealthCheck && instakillOnMiss) || health <= 0) && !practiceMode && !isDead)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) {
				boyfriend.stunned = true;
				deathCounter++;

				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				persistentUpdate = false;
				persistentDraw = false;
				for (tween in modchartTweens) {
					tween.active = true;
				}
				for (tween in piss) {
					tween.active = true;
				}
				for (timer in modchartTimers) {
					timer.active = true;
				}
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x - boyfriend.positionArray[0], boyfriend.getScreenPosition().y - boyfriend.positionArray[1], camFollowPos.x, camFollowPos.y));

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var leStrumTime:Float = eventNotes[0].strumTime;
			if(Conductor.songPosition < leStrumTime) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0].value1 != null)
				value1 = eventNotes[0].value1;

			var value2:String = '';
			if(eventNotes[0].value2 != null)
				value2 = eventNotes[0].value2;

			triggerEventNote(eventNotes[0].event, value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						dad.playAnim('cheer', true);
						dad.specialAnim = true;
						dad.heyTimer = time;
					} else if (gf != null) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = time;
					}
				}
				if(value != 1) {
					boyfriend.playAnim('hey', true);
					boyfriend.specialAnim = true;
					boyfriend.heyTimer = time;
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value) || value < 1) value = 1;
				gfSpeed = value;

			case 'Add Camera Zoom':
				if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) {
					var camZoom:Float = Std.parseFloat(value1);
					var hudZoom:Float = Std.parseFloat(value2);
					if(Math.isNaN(camZoom)) camZoom = 0.015;
					if(Math.isNaN(hudZoom)) hudZoom = 0.03;

					FlxG.camera.zoom += camZoom;
					camHUD.zoom += hudZoom;
				}



			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;

						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.playAnim(value1, true);
					char.specialAnim = true;
				}

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}

				if (char != null)
				{
					char.idleSuffix = value2;
					char.recalculateDanceIdle();
				}

			case 'Screen Shake':
				var valuesArray:Array<String> = [value1, value2];
				var targetsArray:Array<FlxCamera> = [camGame, camHUD];
				for (i in 0...targetsArray.length) {
					var split:Array<String> = valuesArray[i].split(',');
					var duration:Float = 0;
					var intensity:Float = 0;
					if(split[0] != null) duration = Std.parseFloat(split[0].trim());
					if(split[1] != null) intensity = Std.parseFloat(split[1].trim());
					if(Math.isNaN(duration)) duration = 0;
					if(Math.isNaN(intensity)) intensity = 0;

					if(duration > 0 && intensity != 0) {
						targetsArray[i].shake(intensity, duration);
					}
				}

			case 'glitch':
				glitchFreeze();
			case 'Change Character':
				var charType:Int = 0;
				switch(value1) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) {
							if(!boyfriendMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var lastAlpha:Float = boyfriend.alpha;
							boyfriend.alpha = 0.00001;
							boyfriend = boyfriendMap.get(value2);
							boyfriend.alpha = lastAlpha;
							iconP1.changeIcon(boyfriend.healthIcon);
						}
						setOnLuas('boyfriendName', boyfriend.curCharacter);

					case 1:
						if(dad.curCharacter != value2) {
							if(!dadMap.exists(value2)) {
								addCharacterToList(value2, charType);
							}

							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							var lastAlpha:Float = dad.alpha;
							dad.alpha = 0.00001;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf && gf != null) {
									gf.visible = true;
								}
							} else if(gf != null) {
								gf.visible = false;
							}
							dad.alpha = lastAlpha;
							iconP2.changeIcon(dad.healthIcon);
						}
						setOnLuas('dadName', dad.curCharacter);

					case 2:
						if(gf != null)
						{
							if(gf.curCharacter != value2)
							{
								if(!gfMap.exists(value2))
								{
									addCharacterToList(value2, charType);
								}

								var lastAlpha:Float = gf.alpha;
								gf.alpha = 0.00001;
								gf = gfMap.get(value2);
								gf.alpha = lastAlpha;
							}
							setOnLuas('gfName', gf.curCharacter);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (songSpeedType == "constant")
					return;
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 1;
				if(Math.isNaN(val2)) val2 = 0;

				var newValue:Float = SONG.speed * ClientPrefs.getGameplaySetting('scrollspeed', 1) * val1;

				if(val2 <= 0)
				{
					songSpeed = newValue;
				}
				else
				{
					songSpeedTween = FlxTween.tween(this, {songSpeed: newValue}, val2, {ease: FlxEase.linear, onComplete:
						function (twn:FlxTween)
						{
							songSpeedTween = null;
						}
					});
				}
		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (gf != null && SONG.notes[id].gfSection)
		{
			camFollow.set(gf.getMidpoint().x, gf.getMidpoint().y);
			camFollow.x += gf.cameraPosition[0] + girlfriendCameraOffset[0];
			camFollow.y += gf.cameraPosition[1] + girlfriendCameraOffset[1];
			tweenCamIn();
			callOnLuas('onMoveCamera', ['gf']);
			return;
		}

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var cameraTwn:FlxTween;
	public function moveCamera(isDad:Bool)
	{
		var elapsed:Float = FlxG.elapsed;
		if(isDad)
		{
			camFollow.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			camFollow.x += dad.cameraPosition[0] + opponentCameraOffset[0];
			camFollow.y += dad.cameraPosition[1] + opponentCameraOffset[1];
			tweenCamIn();

			switch (dad.curCharacter)
			{
				case "beast_chaotix":
					camFollow.x -= 30;
					camFollow.y -= 50;
				default:

			}
		}
		else
		{
			camFollow.set(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			camFollow.x -= boyfriend.cameraPosition[0] - boyfriendCameraOffset[0];
			camFollow.y += boyfriend.cameraPosition[1] + boyfriendCameraOffset[1];

			switch (boyfriend.curCharacter)
			{
				default:

			}

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1)
			{
				cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						cameraTwn = null;
					}
				});
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) {
			cameraTwn = FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut, onComplete:
				function (twn:FlxTween) {
					cameraTwn = null;
				}
			});
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	//Any way to do this without using a different function? kinda dumb
	private function onSongComplete()
	{
		finishSong(false);
	}
	public function finishSong(?ignoreNoteOffset:Bool = false):Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0 || ignoreNoteOffset) {
			finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				finishCallback();
			});
		}
	}


	public var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= 0.05 * healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}

		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:String = checkForAchievement(['week1_nomiss', 'week2_nomiss', 'week3_nomiss', 'week4_nomiss',
				'week5_nomiss', 'week6_nomiss', 'week7_nomiss', 'ur_bad',
				'ur_good', 'hype', 'two_keys', 'toastie', 'debugger']);

			if(achieve != null) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				#end
			}

			if (chartingMode)
			{
				openChartEditor();
				return;
			}

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					cancelMusicFadeTween();
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					MusicBeatState.switchState(new StoryMenuState());

					// if ()
					if(!ClientPrefs.getGameplaySetting('practice', false) && !ClientPrefs.getGameplaySetting('botplay', false)) {
						StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.flush();
					}
					changedDifficulty = false;
				}
				else
				{
					var difficulty:String = CoolUtil.getDifficultyFilePath();

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();

					if(winterHorrorlandNext) {
						new FlxTimer().start(1.5, function(tmr:FlxTimer) {
							cancelMusicFadeTween();
							LoadingState.loadAndSwitchState(new PlayState());
						});
					} else {
						cancelMusicFadeTween();
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelMusicFadeTween();
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}
				MusicBeatState.switchState(new FreeplayState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				changedDifficulty = false;
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:String) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	public var totalPlayed:Int = 0;
	public var totalNotesHit:Float = 0.0;

	public var showCombo:Bool = true;
	public var showRating:Bool = true;

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + ClientPrefs.ratingOffset);
		//trace(noteDiff, ' ' + Math.abs(note.strumTime - Conductor.songPosition));

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.35;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		//tryna do MS based judgment due to popular demand
		var daRating:String = Conductor.judgeNote(note, noteDiff);

		switch (daRating)
		{
			case "shit": // shit
				totalNotesHit += 0;
				note.ratingMod = 0;
				score = 50;
				if(fucklesMode)
					drainMisses++;
				if(!note.ratingDisabled) shits++;
			case "bad": // bad
				totalNotesHit += 0.5;
				note.ratingMod = 0.5;
				score = 100;
				if(!note.ratingDisabled) bads++;
			case "good": // good
				totalNotesHit += 0.75;
				note.ratingMod = 0.75;
				score = 200;
				if(fucklesMode)
					drainMisses -= 1/100;
				if(!note.ratingDisabled) goods++;
			case "sick": // sick
				totalNotesHit += 1;
				note.ratingMod = 1;
				if(fucklesMode)
					drainMisses -= 1/50;
				if(!note.ratingDisabled) sicks++;
		}
		note.rating = daRating;

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			spawnNoteSplashOnNote(note);
		}

		if(!practiceMode && !cpuControlled) {
			songScore += score;
			if(!note.ratingDisabled)
			{
				songHits++;
				totalPlayed++;
				RecalculateRating();
			}

			if(ClientPrefs.scoreZoom)
			{
				if(scoreTxtTween != null) {
					scoreTxtTween.cancel();
				}
				scoreTxt.scale.x = 1.075;
				scoreTxt.scale.y = 1.075;
				scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
					onComplete: function(twn:FlxTween) {
						scoreTxtTween = null;
					}
				});
			}
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart1 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.cameras = [camHUD];
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = (!ClientPrefs.hideHud && showRating);
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.cameras = [camHUD];
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = (!ClientPrefs.hideHud && showCombo);
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];


		comboSpr.velocity.x += FlxG.random.int(1, 10);
		insert(members.indexOf(strumLineNotes), rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.cameras = [camHUD];
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});


			daLoop++;
		}
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		//trace('Pressed: ' + eventKey);

		if (!cpuControlled && !paused && key > -1 && (FlxG.keys.checkStatus(eventKey, JUST_PRESSED) || ClientPrefs.controllerMode))
		{
			if(!boyfriend.stunned && generatedMusic && !endingSong)
			{
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss) {
					noteMissPress(key);
					callOnLuas('noteMissPress', [key]);
				}

				// I dunno what you need this for but here you go
				//									- Shubs

				// Shubs, this is for the "Just the Two of Us" achievement lol
				//									- Shadow Mario
				keysPressed[key] = true;

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			var spr:StrumNote = playerStrums.members[key];
			if(spr != null && spr.animation.curAnim.name != 'confirm')
			{
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyPress', [key]);
		}
		//trace('pressed: ' + controlArray);
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		if(!cpuControlled && !paused && key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
			callOnLuas('onKeyRelease', [key]);
		}
		//trace('released: ' + controlArray);
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	// Hold notes
	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if (controlHoldArray.contains(true) && !endingSong) {
				#if ACHIEVEMENTS_ALLOWED
				var achieve:String = checkForAchievement(['oversinging']);
				if (achieve != null) {
					startAchievement(achieve);
				}
				#end
			}
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
				//boyfriend.animation.curAnim.finish();
			}
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	function noteMiss(daNote:Note):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) {
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 1) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});
		combo = 0;

		if (!fucklesMode)
		{
			health -= daNote.missHealth * healthLoss;
		}
		if(instakillOnMiss)
		{
			vocals.volume = 0;
			doDeathCheck(true);
		}
		if(fucklesMode)
			drainMisses++;

		//For testing purposes
		//trace(daNote.missHealth);
		songMisses++;
		vocals.volume = 0;
		if(!practiceMode) songScore -= 10;

		totalPlayed++;
		RecalculateRating();

		var char:Character = boyfriend;
		if(daNote.gfNote) {
			char = gf;
		}

		switch (daNote.noteType)
		{
			default:
				if (!fucklesMode)
					health -= daNote.missHealth;
				else
					drainMisses++;
		}

		if(char != null && char.hasMissAnimations)
		{
			var daAlt = '';
			if(daNote.noteType == 'Alt Animation') daAlt = '-alt';

			var animToPlay:String = singAnimations[Std.int(Math.abs(daNote.noteData))] + 'miss' + daAlt;
			char.playAnim(animToPlay, true);
		}

		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned)
		{
			health -= 0.05 * healthLoss;
			if(instakillOnMiss)
			{
				vocals.volume = 0;
				doDeathCheck(true);
			}

			if(ClientPrefs.ghostTapping) return;

			if (combo > 5 && gf != null && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if(!practiceMode) songScore -= 10;
			if(!endingSong)
			{
				songMisses++;
				if (fucklesMode)
					drainMisses++;
			}
			totalPlayed++;
			RecalculateRating();

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			if(boyfriend.hasMissAnimations) {
				boyfriend.playAnim(singAnimations[Std.int(Math.abs(direction))] + 'miss', true);
			}
			vocals.volume = 0;
		}
	}

	function updateWires(){
		for(wireIdx in 0...barbedWires.members.length){
			var wire = barbedWires.members[wireIdx];
			wire.screenCenter();
			var flag:Bool = wire.extraInfo.get("inUse");
			if((wireIdx+1) <= hexes){
				if(!flag){
					if(wire.tweens.exists("disappear")){wire.tweens.get("disappear").cancel();wire.tweens.remove("disappear");}
					wire.alpha=1;
					wire.shake(0.01,0.05);
					wire.extraInfo.set("inUse",true);
				}
			}else{
				if(wire.tweens.exists("disappear")){wire.tweens.get("disappear").cancel();wire.tweens.remove("disappear");}
				if(flag){
					wire.extraInfo.set("inUse",false);
					wire.tweens.set("disappear", FlxTween.tween(wire, {
						alpha: 0,
						y: ((FlxG.height - wire.height)/2) + 75
					},0.2,{
						ease: FlxEase.quadIn,
						onComplete:function(tw:FlxTween){
							if(wire.tweens.get("disappear")==tw){
								wire.tweens.remove("disappear");
								wire.alpha=0;
							}
						}
					}));
				}

			}
		}
	}

	function opponentNoteHit(note:Note):Void
	{
		if (Paths.formatToSongPath(SONG.song) != 'tutorial')
			camZooming = true;

		if(note.noteType == 'Hey!' && dad.animOffsets.exists('hey')) {
			dad.playAnim('hey', true);
			dad.specialAnim = true;
			dad.heyTimer = 0.6;
		} else if(!note.noAnimation) {
			var altAnim:String = "";

			var curSection:Int = Math.floor(curStep / 16);
			if (SONG.notes[curSection] != null)
			{
				if (SONG.notes[curSection].altAnim || note.noteType == 'Alt Animation') {
					altAnim = '-alt';
				}
			}

			var char:Character = dad;
			var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))] + altAnim;
			if(note.gfNote) {
				char = gf;
			}

			if(char != null)
			{
				char.playAnim(animToPlay, true);
				char.holdTimer = 0;
				switch (char.curCharacter.toLowerCase())
				{
					case 'normal':
						if (soulGlassTime)
						{
							health -= 0.018;
							if (health <= 0.01)
							{
								health = 0.01;
							}
						}
				}

				if(!note.isSustainNote){
					if (camGlitchShader != null && char.curCharacter.startsWith('scorchedglitch'))
						camGlitchShader.amount += 0.075;
				}
			}


		}

		if (SONG.needsVoices)
			vocals.volume = 1;

		var time:Float = 0.15;
		if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
			time += 0.15;
		}
		StrumPlayAnim(true, Std.int(Math.abs(note.noteData)) % 4, time);
		note.hitByOpponent = true;



		callOnLuas('opponentNoteHit', [notes.members.indexOf(note), Math.abs(note.noteData), note.noteType, note.isSustainNote]);

		if (!note.isSustainNote)
		{
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (ClientPrefs.hitsoundVolume > 0 && !note.hitsoundDisabled)
			{
				FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
			}

			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) {
				noteMiss(note);
				if(!note.noteSplashDisabled && !note.isSustainNote) {
					spawnNoteSplashOnNote(note);
				}

				switch(note.noteType) {
					case 'Hex Note':
						hexes++;
						FlxG.sound.play(Paths.sound("hitWire"));
						camOther.flash(0xFFAA0000, 0.35, null, true);
						hexTimer=0;
						updateWires();
						if(hexes > barbedWires.members.length){
							trace("die.");
							health = -10000; // you are dead
						}

					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
				}

				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				popUpScore(note);
				if(combo > 9999) combo = 9999;
			}
			if (!fucklesMode)
				{
					health += note.hitHealth * healthGain;
				}

			if(!note.noAnimation) {
				var daAlt = '';
				if(note.noteType == 'Alt Animation') daAlt = '-alt';

				var animToPlay:String = singAnimations[Std.int(Math.abs(note.noteData))];

				if(note.gfNote)
				{
					if(gf != null)
					{
						gf.playAnim(animToPlay + daAlt, true);
						gf.holdTimer = 0;
					}
				}
				else
				{
					boyfriend.playAnim(animToPlay + daAlt, true);
					boyfriend.holdTimer = 0;
				}

				if(note.noteType == 'Hey!') {
					if(boyfriend.animOffsets.exists('hey')) {
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = 0.6;
					}

					if(gf != null && gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) {
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}
				StrumPlayAnim(false, Std.int(Math.abs(note.noteData)) % 4, time);
			} else {
				playerStrums.forEach(function(spr:StrumNote)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.playAnim('confirm', true);
					}
				});
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;
			callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note) {
		if(ClientPrefs.noteSplashes && note != null) {
			var strum:StrumNote = playerStrums.members[note.noteData];
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;

		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	private var preventLuaRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		for (i in 0...luaArray.length) {
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		luaArray = [];

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		super.destroy();
	}

	var glitchShaders:Array<GlitchShaderA> = [];

	function glitchKill(spr:FlxSprite,dontKill:Bool=false){
		var shader = new GlitchShaderA();
		shader.iResolution.value = [spr.width, spr.height];
		piss.push(FlxTween.tween(shader, {amount: 1.25}, 2, {
			ease: FlxEase.cubeInOut,
			onComplete: function(tw: FlxTween){
				glitchShaders.remove(shader);
				if(dontKill)
					spr.visible=false;
				else{
					remove(spr);
					spr.destroy();
				}
			}
		}));
		glitchShaders.push(shader);
		spr.shader = shader;
	}
	public static function cancelMusicFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if (curStep % 2 == 0 && pleaseStopZoomin)
			{
				FlxG.camera.zoom += 0.04;
				camHUD.zoom += 0.04;
			}

		if (curStep % 1 == 0 && ohGodTheZooms)
			{
				FlxG.camera.zoom += 0.02;
				camHUD.zoom += 0.02;
			}

			if (SONG.song.toLowerCase() == 'breakout')
				{
					switch (curStep)
					{
						case 384:
							wowZoomin = true;
						case 512:
							wowZoomin = false;
						case 522:
							FlxTween.tween(camHUD, {alpha: 0}, 1.3, {ease: FlxEase.cubeInOut});
							FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.25}, 4, {ease: FlxEase.cubeInOut});
						case 560:
							FlxTween.tween(theStatic, {alpha: 0.9}, 1.5, {ease: FlxEase.quadInOut});
						case 816:
							theStatic.alpha = 0;
							theStatic.visible = true;	
							FlxTween.tween(theStatic, {alpha: 0.9}, 1.5, {ease: FlxEase.quadInOut});
						case 569, 826:
							FlxFlicker.flicker(theStatic, 0.5, 0.02, true, false);
							new FlxTimer().start(0.5, function(tmr:FlxTimer) 
								{				
									theStatic.visible = false;		
									theStatic.alpha = 0;
								});
						case 576:
							FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut});
							camHUD.zoom += 2;
							holyFuckStopZoomin = true;
							camZooming = true;
						case 832:
							holyFuckStopZoomin = false;
							FlxTween.tween(camHUD, {alpha: 0.75}, 0.5, {ease: FlxEase.cubeInOut});
						case 928:
							FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.cubeInOut});
							holyFuckStopZoomin = true;
						case 1216:
							holyFuckStopZoomin = false;
							FlxTween.tween(camHUD, {alpha: 0}, 3, {ease: FlxEase.cubeInOut});
					}
				}

		if (SONG.song.toLowerCase() == 'my-horizon')
			{
				switch (curStep)
				{
					case 896:
						FlxTween.tween(camHUD, {alpha: 0}, 2.2);
					case 908:
						dad.playAnim('transformation', true);
						dad.specialAnim = true;
						camZooming = false;
					case 924:
						FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.5}, 12, {ease: FlxEase.cubeInOut});
						FlxTween.tween(whiteFuck, {alpha: 1}, 6, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
							{
								remove(fucklesFGPixel);
								remove(fucklesBGPixel);
								fucklesBGPixel.destroy();
								fucklesFGPixel.destroy();
								fucklesFuckedUpBg.visible = true;
								fucklesFuckedUpFg.visible = true;
							}
						});
					case 992:
						literallyMyHorizon();
					case 1120, 1248, 1376, 1632, 1888, 1952, 2048, 2054, 2060:
						fucklesHealthRandomize();
						camHUD.shake(0.005, 1);
					case 1121, 1760:
						wowZoomin = true;
					case 1503, 2015:
						wowZoomin = false;
					case 1504, 2080:
						holyFuckStopZoomin = true;
					case 1759, 2336:
						holyFuckStopZoomin = false;
					case 2208, 2222, 2240, 2254, 2320, 2324, 2328:
						fucklesFinale();
						camHUD.shake(0.003, 1);
					case 2337:
						camZooming = false;
				}
			}

			if (SONG.song.toLowerCase() == 'our-horizon')
				{
					switch (curStep)
					{
						case 765:
							FlxTween.tween(camHUD, {alpha: 0}, 1.2);
							dad.playAnim('transformation', true);
							dad.specialAnim = true;
							camZooming = false;
						case 800:
							FlxTween.tween(whiteFuck, {alpha: 1}, 6, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
								{
									removeShit(1);
								}
							});
							FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.5}, 12, {ease: FlxEase.cubeInOut});
						case 912:
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1.5, {ease: FlxEase.cubeInOut});
							iconP2.changeIcon(dad.healthIcon);
						case 920:
							FlxTween.tween(dad, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
							FlxTween.tween(boyfriend, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
							FlxTween.tween(gf, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});
						case 927:
							dad.specialAnim = false;
							FlxG.camera.zoom += 2;
						case 1000:
							snapCamFollowToPos(700, 900);
							defaultCamZoom = 0.7;
							dad.setPosition(200, 700);
							boyfriend.setPosition(900, 950);
							literallyOurHorizon();
							removeShit(2);
						case 2976:
							FlxTween.tween(camHUD, {alpha: 0}, 2);
						case 2992:
							var fuckinCamShit:FlxObject;
							fuckinCamShit = new FlxObject(700, 950, 1, 1);
							FlxG.camera.follow(fuckinCamShit, LOCKON, 0.06 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
							fireWorksDeluxe();
						case 3104:
							removeShit(3);
							FlxG.camera.flash(FlxColor.WHITE, 2);
					}
				}

			if (SONG.song.toLowerCase() == 'found you')
				{
					switch (curStep)
					{
						case 1: // do it jiggle?
							normalDoor.animation.play('idle');
						case 25, 48, 56:
							FlxG.camera.zoom += 0.15;
						case 2:
							defaultCamZoom = 1.35; //1.35
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1, {ease: FlxEase.quadInOut});
						case 64, 72:
							FlxG.camera.zoom += 0.05;
						case 76:
							FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.3}, 2, {ease: FlxEase.cubeInOut});
						case 93:
							dad.visible = true;
							camGame.shake(0.01, 1);
							defaultCamZoom = 1.35;
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1, {ease: FlxEase.quadInOut});
						case 94:
							FlxTween.tween(dad, {x: 100}, 0.5, {ease: FlxEase.quadOut});
						case 113:
							defaultCamZoom = 0.85;
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.35, {ease: FlxEase.quadOut});
						case 160:
							normalBool = true; 
							FlxG.camera.focusOn(dad.getPosition());
							camHUD.visible = true;
							camHUD.zoom += 2;
							FlxTween.tween(camHUD, {alpha: 1}, 1);
						case 416, 1184, 1696, 2720:
							wowZoomin = true;
						case 800, 1311, 1823, 2847:
							wowZoomin = false;
						case 928, 1312, 1824, 2080, 3361, 2336, 2848, 3782:
							holyFuckStopZoomin = true;
						case 1056, 1568, 2079, 2335, 3871, 2591, 3359, 4138:
							holyFuckStopZoomin = false;
						case 2592:
							iconP1.changeIcon(gf.healthIcon);
						case 3360:
							iconP1.changeIcon('duo');

						// shit for da uhhhhhhhhhhhhhhhhhhhhhhhh trails
						case 2081, 2719, 2848:
							chaotixGlass(1);
						case 2816, 2976:
							revivedIsPissed(1);
						case 2145:
							chaotixGlass(2);
						case 2334:
							revivedIsPissed(1);
							revivedIsPissed(2);
						case 3362:
							chaotixGlass(1);
							chaotixGlass(2);
						case 4135:
							revivedIsPissed(1);
							revivedIsPissed(2);
					}
				}
			if (SONG.song.toLowerCase() == 'malediction')
				{
					switch (curStep)
						{
							case 528, 725:
								FlxTween.tween(camHUD, {alpha: 0.5}, 0.3,{ease: FlxEase.cubeInOut});
							case 558, 735:
								FlxTween.tween(camHUD, {alpha: 1}, 0.3,{ease: FlxEase.cubeInOut});
							case 736:
								FlxG.camera.flash(FlxColor.PURPLE, 0.5);
								if(curseStatic!=null)curseStatic.visible = true;
								FlxTween.tween(curseStatic, {alpha: 1}, 2, {type: FlxTweenType.PINGPONG, ease: FlxEase.quadInOut, loopDelay: 0.1});
							case 991:
								FlxG.camera.flash(FlxColor.PURPLE, 1);
								if(curseStatic!=null){
									FlxTween.tween(curseStatic, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
										{
											curseStatic.visible=false;
										}
									});
								}
							case 1184:
								FlxTween.tween(camHUD, {alpha: 0}, 1,{ease: FlxEase.cubeInOut});
						}
				}
			if (SONG.song.toLowerCase() == 'manual-blast')
				{
					switch (curStep)
						{
							case 512:
								colorTweenHog();
								FlxTween.tween(camHUD, {alpha: 0}, 2, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
									{
										camHUD.visible = false;
										camHUD.alpha = 1;
									}
								});
								blackFuck = new FlxSprite().makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
								blackFuck.alpha = 0;
								blackFuck.cameras = [camOther];
								add(blackFuck);

								FlxTween.tween(blackFuck, {alpha: 1}, 1.5, {ease: FlxEase.cubeInOut});

							case 576, 582, 640, 646, 672, 678, 704, 710, 736, 742, 768, 774, 800, 806, 832, 838:
								FlxTween.tween(blackFuck, {alpha: 0}, 0.01, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
									{
										FlxTween.tween(blackFuck, {alpha: 1}, 0.4, {ease: FlxEase.cubeInOut});
									}
								});
							case 559:
								camZooming = false;
							case 848:
								FlxG.camera.flash(FlxColor.BLACK, 1);
								camZooming = true;
								hogOverlay.visible = false;
								FlxTween.tween(blackFuck, {alpha: 1}, 0.1, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
									{
										remove(blackFuck);
										blackFuck.destroy();
									}
								});
							case 864:
								FlxG.camera.flash(FlxColor.BLACK, 2.5);
								hyogStuff();
								camHUD.visible = true;
								camHUD.zoom += 2;
								if(ClientPrefs.flashing){
									camGame.setFilters([camGlitchFilter]);
									camHUD.setFilters([camGlitchFilter]);
								}

							case 4672:
								if(ClientPrefs.flashing){
									camGame.setFilters([camGlitchFilter, camFuckFilter]);
									camHUD.setFilters([camGlitchFilter, camFuckFilter]);
								}
								
								/*FlxFlicker.flicker(scorchedMotain, 1.5, 0.04, false, false, function(flick:FlxFlicker)
									{
										remove(scorchedMotain);
										scorchedMotain.destroy();
									});*/
									camFuckShader.amount = 0.01;
								glitchKill(scorchedMotain);
							case 4704:
								/*FlxFlicker.flicker(scorchedWaterFalls, 1.5, 0.04, false, false, function(flick:FlxFlicker)
									{
										remove(scorchedWaterFalls);
										scorchedWaterFalls.destroy();
									});*/
									camFuckShader.amount = 0.035;
								glitchKill(scorchedWaterFalls);
							case 4736:
								camFuckShader.amount = 0.075;
								glitchKill(scorchedHills);
								glitchKill(scorchedMonitor);
							case 4944:
								glitchKill(boyfriend, true);
								piss.push(FlxTween.tween(camFuckShader, {amount: 0.3}, 4, {
									ease: FlxEase.cubeInOut
								}));
							case 4960:
								glitchKill(scorchedTrees);
							case 4978:
								glitchKill(scorchedRocks);
							case 4992:
								glitchKill(scorchedFloor);
								glitchKill(scorchedBg);
							case 5000:
								glitchKill(dad, true);
							case 5030:
								camGame.alpha = 0;
								camHUD.alpha = 0;
								
								
								
								
								
						}
				}

		if(curStep == lastStepHit) {
			return;
		}

		lastStepHit = curStep;
		setOnLuas('curStep', curStep);
		callOnLuas('onStepHit', []);
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;

	override function beatHit()
	{
		super.beatHit();

		if(fcLabel!=null){
			if(fcLabel.animation.curAnim !=null){
				var frame = fcLabel.animation.curAnim.curFrame;
				frame += 1;
				frame %= 2;
				fcLabel.animation.curAnim.curFrame = frame;
			}
		}
		

		if (curBeat % 64 == 0 && normalBool)
			{
				var prevInt:Int = normalCharShit;
	
				normalCharShit = FlxG.random.int(1, 5, [normalCharShit]);
	
				switch(normalCharShit){
					case 1:
						normalChars.animation.play('chaotix');
					case 2:
						normalChars.animation.play('curse');
					case 3:
						normalChars.animation.play('rex');
					case 4:
						normalChars.animation.play('rodent');
					case 5:
						normalChars.animation.play('spoiled');
				}
			}

		if(lastBeatHit >= curBeat) {
			//trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			setOnLuas('altAnim', SONG.notes[Math.floor(curStep / 16)].altAnim);
			setOnLuas('gfSection', SONG.notes[Math.floor(curStep / 16)].gfSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}
		if (camZooming && FlxG.camera.zoom < 1.35 && ClientPrefs.camZooms && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(camGlitchShader!=null && dad.curCharacter.startsWith('scorchedglitch'))
				camGlitchShader.amount += 0.2;
		}

		if (curBeat % 2 == 0 && wowZoomin)
			{
				FlxG.camera.zoom += 0.04;
				camHUD.zoom += 0.06;
				if (camGlitchShader != null && dad.curCharacter.startsWith('scorchedglitch'))
					camGlitchShader.amount += 0.3;
			}

		if (curBeat % 1 == 0 && holyFuckStopZoomin)
		{
			FlxG.camera.zoom += 0.04;
			camHUD.zoom += 0.06;
			if (camGlitchShader != null && dad.curCharacter.startsWith('scorchedglitch'))
				camGlitchShader.amount += 0.3;
		}

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (gf != null && curBeat % Math.round(gfSpeed * gf.danceEveryNumBeats) == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing") && !gf.stunned)
		{
			gf.dance();
		}
		if (curBeat % boyfriend.danceEveryNumBeats == 0 && boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.stunned)
		{
			bfCamThing = [0, 0];
			boyfriend.dance();
		}
		if (curBeat % dad.danceEveryNumBeats == 0 && dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
		{
			dadCamThing = [0, 0];
			dad.dance();
		}

		switch (curStage)
		{
			case 'horizon':
				if (fucklesBeats)
					{
						fucklesEspioBg.animation.play('idle');
						fucklesMightyBg.animation.play('idle');
						fucklesCharmyBg.animation.play('idle');
						fucklesAmyBg.animation.play('idle');
						fucklesKnuxBg.animation.play('idle');
						fucklesVectorBg.animation.play('idle');
					}
				else
					{
						fucklesAmyBg.animation.play('fear');
						fucklesCharmyBg.animation.play('fear');
						fucklesMightyBg.animation.play('fear');
						fucklesEspioBg.animation.play('fear');
						fucklesKnuxBg.animation.play('fear');
						fucklesVectorBg.animation.play('fear');
					}
				if (SONG.song.toLowerCase() == 'our-horizon')
					{
						horizonAmy.animation.play('idle');
						horizonEspio.animation.play('idle');
						horizonKnuckles.animation.play('idle');
						horizonCharmy.animation.play('idle');
						horizonVector.animation.play('idle');
						horizonMighty.animation.play('idle');
					}
		}

		lastBeatHit = curBeat;

		setOnLuas('curBeat', curBeat); //DAWGG?????
		callOnLuas('onBeatHit', []);
	}

	function hyogStuff() 
		{
			hogBg.visible = false;
			hogMotain.visible = false;
			hogWaterFalls.visible = false;
			hogLoops.visible = false;
			hogTrees.visible = false;
			hogFloor.visible = false;
			hogRocks.visible = false;

		
			scorchedBg.visible = true;
			scorchedMotain.visible = true;
			scorchedWaterFalls.visible = true;
			scorchedHills.visible = true;
			scorchedMonitor.visible = true;
			scorchedTrees.visible = true;
			scorchedFloor.visible = true;
			scorchedRocks.visible = true;
		}

	function colorTweenHog()
		{	//blammed lights but its not shit lol.
			FlxTween.color(hogBg, 15, FlxColor.WHITE, 0xFF1f1f1f);
			FlxTween.color(hogMotain, 15, FlxColor.WHITE, 0xFF1f1f1f);
			FlxTween.color(hogWaterFalls, 15, FlxColor.WHITE, 0xFF1f1f1f);
			FlxTween.color(hogLoops, 15, FlxColor.WHITE, 0xFF1f1f1f);
			FlxTween.color(hogTrees, 15, FlxColor.WHITE, 0xFF1f1f1f);
			FlxTween.color(hogFloor, 15, FlxColor.WHITE, 0xFF1f1f1f);
			FlxTween.color(hogRocks, 15, FlxColor.WHITE, 0xFF1f1f1f);  
			FlxTween.color(hogOverlay, 15, FlxColor.WHITE, 0xFF1f1f1f);
		}

	function chaotixGlass(ass:Int)
		{
			switch (ass)
				{
					case 1:
						normalTrail = new FlxTrail(dad, null, 2, 12, 0.20, 0.05);
						add(normalTrail);
						soulGlassTime = true;
					case 2:
						metalTrail = new FlxTrail(boyfriend, null, 2, 12, 0.20, 0.05);
						add(metalTrail);
					case 3:
						amyTrail = new FlxTrail(gf, null, 2, 12, 0.20, 0.05);
						add(amyTrail);
				}
		}

	function revivedIsPissed(ass:Int)
		{
			{
				switch (ass)
					{
						case 1:
							soulGlassTime = false;
							remove(normalTrail);
						case 2:
							remove(metalTrail);
						case 3:
							remove(amyTrail);
					}
			}
		}
		
	function literallyMyHorizon()
		{
			dad.specialAnim = false;
			FlxG.camera.flash(FlxColor.BLACK, 1);
			dadGroup.remove(dad);
			var olddx = dad.x - 230;
			var olddy = dad.y - 170;
			dad = new Character(olddx, olddy, 'beast_chaotix');
			iconP2.changeIcon(dad.healthIcon);
			dadGroup.add(dad);
			camZooming = true;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1.5, {ease: FlxEase.cubeInOut});
			FlxTween.tween(camHUD, {alpha: 1}, 1.0);
			fucklesBeats = false;
			fucklesDeluxe();
			FlxTween.tween(whiteFuck, {alpha: 0}, 2, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
				{
					remove(whiteFuck);
					whiteFuck.destroy();
				}
			});

			camHUD.zoom += 2;

			//ee oo ee oo ay oo ay oo ee au ee ah
		}
	function literallyOurHorizon()
		{
			isPixelStage = false;
			camZooming = true;
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.35, {ease: FlxEase.quadOut});
			FlxTween.tween(camHUD, {alpha: 1}, 0.5);
			FlxTween.tween(dad, {alpha: 1}, 0.1, {ease: FlxEase.cubeInOut});
			FlxTween.tween(boyfriend, {alpha: 1}, 0.1, {ease: FlxEase.cubeInOut});
			FlxTween.tween(whiteFuck, {alpha: 0}, 1, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween)
				{
					remove(whiteFuck);
					whiteFuck.destroy();
					GameOverSubstate.characterName = 'bf-holding-gf-dead';
				}
			});

			fucklesBGPixel.visible = false;
			fucklesFGPixel.visible = false;

			horizonBg.visible = true;
			horizonFloor.visible = true;
			horizonTrees.visible = true;
			horizonTrees2.visible = true;

			horizonPurpur.visible = true;
			horizonYellow.visible = true;
			horizonRed.visible = true;

			horizonAmy.visible = true;
			horizonCharmy.visible = true;
			horizonEspio.visible = true;
			horizonMighty.visible = true;
			horizonKnuckles.visible = true;
			horizonVector.visible = true;

			playerStrums.forEach(function(spr:StrumNote)
			{
				spr.reloadNote();
			});
			
			opponentStrums.forEach(function(spr:FlxSprite)
			{
				spr.x += 10000;
			});
		}

		function removeShit(fuck:Int)
			{

				switch(fuck)
						{
							case 1:
								fucklesEspioBg.animation.stop();
								fucklesMightyBg.animation.stop();
								fucklesCharmyBg.animation.stop();
								fucklesAmyBg.animation.stop();
								fucklesKnuxBg.animation.stop();
								fucklesVectorBg.animation.stop();
							case 2:
								fucklesEspioBg.visible = false;
								fucklesMightyBg.visible = false;
								fucklesCharmyBg.visible = false;
								fucklesAmyBg.visible = false;
								fucklesKnuxBg.visible = false;
								fucklesVectorBg.visible = false;
							case 3:
								horizonBg.visible = false;
								horizonFloor.visible = false;
								horizonTrees.visible = false;
								horizonTrees2.visible = false;

								horizonPurpur.visible = false;
								horizonYellow.visible = false;
								horizonRed.visible = false;

								horizonAmy.visible = false;
								horizonCharmy.visible = false;
								horizonEspio.visible = false;
								horizonMighty.visible = false;
								horizonKnuckles.visible = false;
								horizonVector.visible = false;

								dadGroup.visible = false;
								boyfriendGroup.visible = false;
						}
			}

		function fucklesDeluxe()
			{
				health = 2;
				//songMisses = 0;
				fucklesMode = true;

				timeBarBG.visible = false;
				timeBar.visible = false;
				timeTxt.visible = false;
				scoreTxt.visible = false;

				opponentStrums.forEach(function(spr:FlxSprite)
					{
						spr.x += 10000;
					});
			}

			// ok might not do this lmao

			var fuckedMode:Bool = false;

			function fucklesFinale()
			{
				if (fucklesMode)
					fuckedMode = true;
				if (fuckedMode)
				{
					health -= 0.1;
					if (health <= 0.01)
					{
						health = 0.01;
						fuckedMode = false;
					}
				}
				trace('dont die lol');
			}

			function fucklesHealthRandomize()
			{
				if (fucklesMode)
					health = FlxG.random.float(0.5, 2);
				trace('fuck your health!');
				// randomly sets health between max and 0.5,
				// this im gonna use for stephits and basically
				// have it go fucking insane in some parts and disable the drain and reenable when needed
			}

	public var closeLuas:Array<FunkinLua> = [];
	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}

		for (i in 0...closeLuas.length) {
			luaArray.remove(closeLuas[i]);
			closeLuas[i].stop();
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(isDad:Bool, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = strumLineNotes.members[id];
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public var ratingName:String = '?';
	public var ratingPercent:Float;
	public var ratingFC:String;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop)
		{
			if(totalPlayed < 1) //Prevent divide by 0
				ratingName = '?';
			else
			{
				// Rating Percent
				ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
				//trace((totalNotesHit / totalPlayed) + ', Total: ' + totalPlayed + ', notes hit: ' + totalNotesHit);

				// Rating Name
				if(ratingPercent >= 1)
				{
					ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
				else
				{
					for (i in 0...ratingStuff.length-1)
					{
						if(ratingPercent < ratingStuff[i][1])
						{
							ratingName = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			// Rating FC
			ratingFC = "";
			if (sicks > 0) ratingFC = "SFC";
			if (goods > 0) ratingFC = "GFC";
			if (bads > 0 || shits > 0) ratingFC = "FC";
			if (songMisses > 0 && songMisses < 10) ratingFC = "SDCB";
			else if (songMisses >= 10) ratingFC = "Clear";

			if(fcLabel!=null){
				if(fcLabel.animation.curAnim!=null){
					if(fcLabel.animation.getByName(ratingFC)!=null && fcLabel.animation.curAnim.name!=ratingFC){
						var frame = fcLabel.animation.curAnim.curFrame;
						fcLabel.animation.play(ratingFC,true);
						fcLabel.animation.curAnim.curFrame = frame;
					}
				}else if(fcLabel.animation.getByName(ratingFC)!=null){
					fcLabel.animation.play(ratingFC,true);
				}
				fcLabel.visible=songMisses<10;
			}
		}
		setOnLuas('rating', ratingPercent);
		setOnLuas('ratingName', ratingName);
		setOnLuas('ratingFC', ratingFC);
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(achievesToCheck:Array<String> = null):String
	{
		if(chartingMode) return null;

		var usedPractice:Bool = (ClientPrefs.getGameplaySetting('practice', false) || ClientPrefs.getGameplaySetting('botplay', false));
		for (i in 0...achievesToCheck.length) {
			var achievementName:String = achievesToCheck[i];
			if(!Achievements.isAchievementUnlocked(achievementName) && !cpuControlled) {
				var unlock:Bool = false;
				switch(achievementName)
				{
					case 'week1_nomiss' | 'week2_nomiss' | 'week3_nomiss' | 'week4_nomiss' | 'week5_nomiss' | 'week6_nomiss' | 'week7_nomiss':
						if(isStoryMode && campaignMisses + songMisses < 1 && CoolUtil.difficultyString() == 'HARD' && storyPlaylist.length <= 1 && !changedDifficulty && !usedPractice)
						{
							var weekName:String = WeekData.getWeekFileName();
							switch(weekName) //I know this is a lot of duplicated code, but it's easier readable and you can add weeks with different names than the achievement tag
							{
								case 'week1':
									if(achievementName == 'week1_nomiss') unlock = true;
								case 'week2':
									if(achievementName == 'week2_nomiss') unlock = true;
								case 'week3':
									if(achievementName == 'week3_nomiss') unlock = true;
								case 'week4':
									if(achievementName == 'week4_nomiss') unlock = true;
								case 'week5':
									if(achievementName == 'week5_nomiss') unlock = true;
								case 'week6':
									if(achievementName == 'week6_nomiss') unlock = true;
								case 'week7':
									if(achievementName == 'week7_nomiss') unlock = true;
							}
						}
					case 'ur_bad':
						if(ratingPercent < 0.2 && !practiceMode) {
							unlock = true;
						}
					case 'ur_good':
						if(ratingPercent >= 1 && !usedPractice) {
							unlock = true;
						}
					case 'roadkill_enthusiast':
						if(Achievements.henchmenDeath >= 100) {
							unlock = true;
						}
					case 'oversinging':
						if(boyfriend.holdTimer >= 10 && !usedPractice) {
							unlock = true;
						}
					case 'hype':
						if(!boyfriendIdled && !usedPractice) {
							unlock = true;
						}
					case 'two_keys':
						if(!usedPractice) {
							var howManyPresses:Int = 0;
							for (j in 0...keysPressed.length) {
								if(keysPressed[j]) howManyPresses++;
							}

							if(howManyPresses <= 2) {
								unlock = true;
							}
						}
					case 'toastie':
						if(/*ClientPrefs.framerate <= 60 &&*/ ClientPrefs.lowQuality && !ClientPrefs.globalAntialiasing && !ClientPrefs.imagesPersist) {
							unlock = true;
						}
					case 'debugger':
						if(Paths.formatToSongPath(SONG.song) == 'test' && !usedPractice) {
							unlock = true;
						}
				}

				if(unlock) {
					Achievements.unlockAchievement(achievementName);
					return achievementName;
				}
			}
		}
		return null;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;
}

				/**%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&&8BB#%%%%WW%BaLccccccvccccccccccccccwbW%8
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8%%@Wb%B%88M@BbcccccccXb&ccccccccccccczdd%o%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&%@mdb@o8WBBpUcccccccwad8XccccccccccccObk@M%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%WW@*CqbM@M&%kUcccccccJbqcQMLcccccccccccXdba@8%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%W%Bpcwbb@@BMYcvcccccc0MXccJkqcccccccccccUbb*B8%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%WBBLcXdbhBWLccccccccckZzccczbbcccccccccccOddMB8%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%&%#YczpbhWwzccccccccUoQcvccczp#cccccccccczddb8&%%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%&%WcccCbo#JvccccccccC*zcccccccmMUcccccccccJbbdBM%%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%8BBCcccp%OcvcccccccuQocvvccccccUoqcccccccccObbk@*%%
				   %%%%%%%%%%%%%%W8%&%%%%%%%%M@Occc0aUccccccccccQaXccccccccczdocccccccccqbbhBM%%
				   %%%%%%%%%%%%%WB&B8W8B%%%%&@accccOzccccccccccQ#zcvcccccccccm#ccccccccYbbb#8%%%
				   %%%%%%%%%%%%%oBmb8@@o8%%%W8cccccccvcccccccczovccccccccccccQoUcccccccQdbb#B%%%
				   %%%%%%%%%%%%8&WzCphM@B%oW@dvccccccccccccccccccccccccccccccYhbcccccccwbbb&%%%%
				   %%%%%%%%%%%%%@acczQpk#&B@Wqcccccccccccccccccccccccccccccccvw%zccccccpbbb8&MMM
				   %%%%%%%%%%%%%BdcccccYZqpkahmcccccccccccccccccccccccccccccccJMCccccczdddd&%%%%
				   %%%%%%%%%%%%%BmcccccccczzzccccccccccccccccccccccccccccccccczbmccccczbdpLXXXXX
				   %%%%%%%%%%%%8%mcccccccccccccccccccccccccccccccccccccccccXCzcZ*ccccccQJccccccc
				   %%%%%%%%%%%%8%Qccccccccccccccccccccccccccccccccccccccccc*@pcv#Ccccccccccccccc
				   %%%%%%%%%%%%8%QcccccccccccccccccccccccccccccccccccccccccO@WCcObcccccccccccccc
				   %%%%%%%8o%BBB@QcccccccccccccccccccccccccccccccccccccccccczYaQcwcccccccccccccc
				   %%%8&8&@B8#oaWQccccccccccccccccccccccccccccccccccccccccccccYMJccccccccccccccc
				   %%W&@@&d00000kQcccccccccccccccccccccccccccccczzUL00JXcvcccccz8Xcccccccccccccc
				   #%B8bm0000000h0ccccccccccccccccccccccccccccYdokmZOOmh#pXccccvk*cccccccccccccc
				   @&k0000000000wmccccccccccccccccccccccccccYqkZCCJCCCCCJd#aqzccU@dccccccccccccc
				   *000000000000mmvcccccccccccccccccccccvccQWCCCCCCCCCCCLCLM&#CZ*BBUcccccccccccc
				   #000000000000ZdcccccccccccccccccccccczcpdLCCCCCCCCCCCJJCCWBhB@@BWcccccccccccc
				   WbZwpwZZOO0000dcccccccccccccccccccccczqdCCCCCCCCCCJCCCCCJL&@@@Bo&LcccccccccYw
				   W%#ooooaaobwmOoccccccccccccccccccccccL#JCJCCCCXcnnrruxcYCJm@@@@*ohccccccccCdd
				   W&B*ooooooooaa#cccccccccccczcccccccvwWCJJCJU)+<<<<<>>><<~(X*@@@#*&UccccccOdbb
				   &&&%Moooooooa&0ccccccccccccvvccczCZM%hCCY|[><><>>>>>>>>>>>>|@@@W*Maccccccpbbb
				   &&&&%Wooooooo#cccccccX0mmmO0MOk&*#M@@CUr~<<]xuxj-<<>>>>>>>>+8@@B8&WccccccJbbb
				   &WW&&8%ooo*8BJccccvcJWqCCCb8@@%@@@@@*X!>~+mZII:1*C+<<>><><>>O@@@**W0ccccccZbb
				   B&&&&&&%%%@@&ccccccwhLJCCCCCd@@@@@@@C+>i]h}::::;;-m1<>>>><<>)@@@&*oWzvccccYbb
				   *8%&&&W&BB&@qcccccQoCCCJCJCJJL#@@@@@u>><CI:[1[l::;iL(>>>>>>>+B@@@*o#qccccccpd
				   oo*%%&&BB*M%ccccXY*CCCCCUc(<<<]B@@@@?>>~Y,<Mho8f;::!b~<<>>>><%@@@W##8Cccccc0b
				   oooo*%@@#%B#cvCZwMdCJCU{+>><><<[B@@@-<>u|;aO0L0wb:::_U<<>>>>>M@@@%MW8#cccccJb
				   %8&#o*BBW%BMcYB8@BQCCf+>>><<<~>>f@B@_>>01:M00QQQwbI;;p[<>>>><#@@@B***WZcccccd
				   &W&BBBq8B&#@mhB@@%CY[<><<<<QWWm1>X@@-><qI:#0Qw0QQkt::;v>>>>>>d@@@@#o*oMcccccq
				   &W&&&Wmw@@&#@@B@@&U+>>><>>)*LL0Wt+@@-><C):#OQ%p000*:;IC<>>>>>d@@@@#o*oWUccccm
				   &W&W%mZZqBW&@@@$@8?>>>><><t0a/MO*jt@?>>c/;*O0O@ZQQk|:;Z+>>>>>d@@$@#*o**qccccm
				   M888&ZZZmd@&WB@@@B_>>>>>>>tO#;>&Ob<#n>><Y;XqQQ&hQQLU;:C_>>>>>*@@@@Mo***Bccccm
				   mZmpoBqmZk@&%a@@@@j>>>><<>]M#_:>pq/kn>><w:Id0Qq#QQQJ:;C_>>>><%@$@&&M**o%Ycccm
				   ZZZZZZmZ#@M8%%&@@@L<><><>>+Bmx::mO&]n<<<X<;d0QQZQQLJ:;O<<>>>?@@@@#*WW**8Ucccm
				   ZZZZZZqMBW&8%%8&$@#~>><<>>>wmQ;:?od]<><>]wIvpQQQ0QOu:+c>>>><d@@@Wo**8&*WJcccm
				   mZZwwk@BoB%%%%%&%@@r>>>>>>>_hd+;I#0)>>><<U?;k00Q0Qh_;h[>><>?@@@%***oo8&&Jcccw
				   &88MaB%8%%%%%%%%&%@*~<>>>>>>qwM!I#O)<><>><b]i&OQLorIO/<><><U@@8*ao*o**&%Jvccq
				   LLLCLk8&%%%%%%%%%W8@u<>>>>>>-hOokq0{<<>>>><Of>vLJt_0u>><>>)B8a*hqppa**o@Xcczd
				   LLLLCZ@M%%%%%%%%%%&@B]<>>>>>>(#ZQO#~f#Mm}><<Xb({)Jd[<><>>{d*0Q0&0QQQOboBXccJb
				   LLLLCLB8%%%%%%%%%%%W@mi<<>>><<+J8m+thQ0ObM}><<---<>><<<>wMOQQQQZo0Q000Z8cccOb
				   LLLLCC&8%%%%%%%%%%%%*@J>>><>>>><~>to00000Zd#Lf<<<><<>t0Mb00QQQQQ*qQL0Qmmcczpb
				   LLLLCLWW%%%%%%%%%%%&B8&v+><<>><>_nM000000000qMB&ZOO&&8%#h00QQ0QQL#O0QQpYccUdb
				   LLLLLLo&%%%%%%%%%%%#@paW%c-<~_-b%a00000000Q0O0qWB8*kbhkQMmQQ0L00Lp*QQLacvcmbd
				   CCLLLCo8BB%%%%%%%%W@M0Oq*8BWW&odm0000000000000QOOZO0m#0QOWQQQQQQQQhdLOkccUbbb
				   CCCCmpM%%&8%%%%%%%&BZ0000mbdwOO00000000000000000000wM0Q0QbbQQQQQQ00#mbCzcwbbb
				   0LUX@@@&&@%*M&%%%8%Ww000000000000000000000000000Q0wM0QQ0LQ#OQQQQQQQ0MhccQdbbb
				   h?+~k@@#+>nb@@@@@@@@*00000000000000000000O00O00Zh%hOQQQQQQOMQQQQQQ0QbmcUddbbb
				   ]<~<(@@$BapW$@$$$@@8O000000000000000000Oko##*ahhq0o0QQQ0QQQkpQQQQQQQ#XYddbdbd
				   O/(f*@@$$$$$$$$$@$%@p00000000000000OOq#MpWQQQQQQQQapQQQQQ0QO%OQQ0Q0O0XpbbbkhW
				   h@@@8W&@$$$$$$$$Bo&*@p0000000000000O8bCQQmbQQQQ0Q00#Q0Q0Q0QQQo0QLQQ8zqbbdM%ab
				   @*%%8%8&&W&&&&&W8%%&%BbOO00000000OwohQ0Q0Q#m0QQQQQQpa0QQ0QQQQhdQ0QbQpba8#abbb
				   &%%%%%%%%%%%%%%%%%%%W8BkO00000000Z&ZWZQQQQL#00QQQQ0QomQQQQQ0QQ*OQmMboW8Wbdbbb
				   8%%%%%%%%%%%%%%%%%%%%%*@8mOQ00000w00mW0QQQ0kaQQQ0QQQO80Q0QQ0QQwWL&oBMoWbbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%WBB*Z000000000qW0QQL0a0QQQ0Q0QpbQQQ0Q0Q0p8%#oo*8bbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%W8%@oq00000000d*000QO&OQQ0QQ0Q*wQ0QQQQ0oMWooo&adbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%&oBB%kZ00000OdaO0QQwkQLQQQ0QO#QQQQQQ&kbWoo##dbdbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%8&M&@%&*mO00Om&O0QL#q00QQQ0Qdk0QQw8&ado%8Mbdddbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#@##%M*ohkp8#O0Qo0QQQQQQQ*ZOh&oo8kbkhbbbbbbbbW
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8%B*adbk&#&&WWhmq*0QQQQQ0mW8*oao*Wbdddbbbbbk%@
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%o@@adbh#ooooo*W%WdLCCpo%W*aooooo%qzXpbbbbbbk%
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&@kbbB*aooooaoo##MMM#*ooooaoooo8LccXqbbbbbbk
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%BBbbdBoooooooooooooooooaoooooaw#LcccQbbbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%BdbbBoooooooooooooooooooooadO0MYcccYdbdbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Bbbb@oooooooooooooooooooadZ00OMcccvXbdbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%BBbbb%*ooooooooooooooaahpZ0O00qZcccccddbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8@bdbkMooooooooooaoahbZ000000OMXcccczdbbbbbb
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%M@adbb8oaoooooooaqmO00000000OhOcccccYbbbbbbd
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%8Bobbd#Mooooooooh00000000000qkccccccCbbbbba&
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&Bbddd&*oooooooZ0000000000mazccccccZ#kbdaB@
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%k@o#bba%*ooooooO000000000mWXccccccccZM8adbk
				   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%W&@%*hbbda&ooooooO00000000wazccccccccYddkoW*b**/


					// SECRET NORMAL INVASION!!!!!!
