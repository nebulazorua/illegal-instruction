package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	public static var firstStart:Bool = true;
	
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		'collection',
		'options'
	];

	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 3)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('chaotix/menu-bg'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var upperShit:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chaotix/topThing'));
		upperShit.scrollFactor.set(0, 0);
		upperShit.scale.set(2, 2);
		upperShit.updateHitbox();
		upperShit.screenCenter(X);
		upperShit.antialiasing = false;
		add(upperShit);

		var circleShit:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chaotix/circle'));
		circleShit.scrollFactor.set(0, 0);
		circleShit.scale.set(4, 4);
		circleShit.updateHitbox();
		circleShit.screenCenter();
		circleShit.antialiasing = false;
		add(circleShit);

		var arrowOne:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chaotix/arrow'));
		arrowOne.scrollFactor.set(0, 0);
		arrowOne.scale.set(4, 4);
		arrowOne.updateHitbox();
		arrowOne.screenCenter(X);
		arrowOne.antialiasing = false;
		add(arrowOne);

		var arrowTwo:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('chaotix/arrow'));
		arrowTwo.scrollFactor.set(0, 0);
		arrowTwo.scale.set(4, 4);
		arrowTwo.updateHitbox();
		arrowTwo.screenCenter(X);
		arrowTwo.antialiasing = false;
		add(arrowTwo);

		arrowOne.x -= 480;
		arrowOne.y += 175;

		arrowTwo.x += 500;
		arrowTwo.y += 175;


		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1.5;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		//(i * 200)  + offset2

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 150;
			var offset2:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-300, (i * 200)  + offset);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 3) * 0.135;
			if(optionShit.length < 3) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.y += -200;
			menuItem.updateHitbox();

			switch (i)
			{
			    case 0:
					menuItem.x = -300;
					menuItem.y = 0;
					menuItem.scrollFactor.set(1, 1);
				case 1:
					menuItem.x = 0;
					menuItem.y = 0;
					menuItem.scrollFactor.set(1, 1);
				case 2:
					menuItem.x = 300;
					menuItem.y = 0;
					menuItem.scrollFactor.set(1, 1);
				case 3:
					menuItem.x = 600;
					menuItem.y = 0;
					menuItem.scrollFactor.set(1, 1);
				case 4:
					menuItem.x = 900;
					menuItem.y = 0;
					menuItem.scrollFactor.set(1, 1);
			}
				menuItem.x = 300 + (i * 250);
				menuItem.y = 60 + (i * 250);

			
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();
		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					var daChoice:String = optionShit[curSelected];

					switch (daChoice)
					{
						case 'story_mode':
							MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());
						case 'collection':
							MusicBeatState.switchState(new FreeplayState());
						case 'credits':
							MusicBeatState.switchState(new CreditsState());
						case 'options':
							LoadingState.loadAndSwitchState(new options.OptionsState());
					}
				}
			});
		
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.centerOffsets();
			}
			
		});
	}
}
