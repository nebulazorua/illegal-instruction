package;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.text.FlxText;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;

class CollectionRoomState extends MusicBeatState
{
    var characterList:Array<String> = ['duke', 'chaotix', 'chotix', 'normalcd', 'curse'];
    var bgShits:FlxTypedGroup<FlxSprite>;
    var characterShit:FlxSprite;
    var charBio:FlxText;
    var charText:String;
    var descShit:FlxSprite;
    var disableInput:Bool = true;
    var sprSprite:FlxBackdrop;
    //ill add the scrolling later
    private static var curSelected:Int = 0;
    override function create()
        {
            FlxG.sound.playMusic(Paths.music('Collection_menu'), 0);
            FlxG.sound.music.fadeIn(4, 0, 0.7);
            
            transIn = FlxTransitionableState.defaultTransIn;
            transOut = FlxTransitionableState.defaultTransOut;
            //IM SO GOOD AT CODING HOLY FUCKLES
            //TRANS?!??!??!?!?!?!?! just like curse......

            bgShits = new FlxTypedGroup<FlxSprite>();

            for (i in 0...characterList.length)
                {
                    sprSprite = new FlxBackdrop(0, 0);
                    sprSprite.loadGraphic(Paths.image('collection/bg/' + characterList[i]));
                    sprSprite.ID = i;
                    if (sprSprite.ID != curSelected)
                        {
                            sprSprite.alpha = 0;
                        }
                    sprSprite.antialiasing = ClientPrefs.globalAntialiasing;
                    sprSprite.screenCenter();
                    bgShits.add(sprSprite);
                }
            add(bgShits);

            characterShit = new FlxSprite(0, 0).loadGraphic(Paths.image('collection/characters/' + characterList[curSelected]));
            characterShit.antialiasing = ClientPrefs.globalAntialiasing;
            characterShit.screenCenter();
            add(characterShit);

            descShit = new FlxSprite(0, 0).loadGraphic(Paths.image('collection/desc/' + characterList[curSelected]));
            descShit.antialiasing = ClientPrefs.globalAntialiasing;
            descShit.screenCenter();
            descShit.x += 350;
            // add(descShit);
            
            fixTheFunny();

            characterShit.alpha = 0;
            FlxTween.tween(characterShit, {alpha: 1}, 1, {ease: FlxEase.cubeOut});

            new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                   disableInput = false;
                }); 

            super.create();

            charBio = new FlxText();
            charBio.setFormat(Paths.font("knuckles-chaotix-nova.ttf"), 32, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.RED);
            charBio.screenCenter();
            charBio.visible = true;
            charBio.color = FlxColor.YELLOW;
            charBio.borderSize = 1.25;
            charBio.scale.x = 0.6;
            charBio.scale.y = 0.6;
            add(charBio);
        }

    var movedBack:Bool = false;
    var hitEnter:Bool = false;


    override function update(elapsed:Float)
        {
            if (controls.BACK && !movedBack && !hitEnter)
                {
                    movedBack = true;
                    new FlxTimer().start(0.4, function(tmr:FlxTimer)
                        {
                            MusicBeatState.switchState(new MainMenuState());
                        }); 
                }

            if (controls.UI_DOWN_P && !disableInput)
                {
                    disableInput = true;
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeCharacter(1);
                    doTheFunnyThing(characterShit);
                }
            if (controls.UI_UP_P && !disableInput)
                {
                    disableInput = true;
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    changeCharacter(-1);
                    doTheFunnyThing(characterShit);
                }

            charBio.text = charText;

            reloadText();
            fixTheFunny();
            super.update(elapsed);
        }

    function bgShit()
        {
            for (spr in bgShits) {
                FlxTween.cancelTweensOf(spr);
                if (spr.ID == curSelected) {
                    FlxTween.tween(spr, {alpha: 1}, 0.15, {
                        ease: FlxEase.linear
                        });
                } else {
                    FlxTween.tween(spr, {alpha: 0}, 0.15, {
                        ease: FlxEase.linear
                    });
                }
            }
        }


    function doTheFunnyThing(spr:FlxSprite)
        {
            spr.alpha = 0;
            FlxTween.tween(spr, {alpha: 1}, 0.2, {
                ease: FlxEase.cubeOut,
                onComplete: function(twn:FlxTween)
                    {
                        disableInput = false;
                    }
                });
            
            //god i LOVE TWEENS!!!
            //i hate you too <3 -jackie
        }

    function changeCharacter(change:Int = 0)
        {
            curSelected += change;

            if (curSelected >= characterList.length)
                curSelected = 0;
            else if (curSelected < 0)
                curSelected = characterList.length - 1;

            bgShit();
            fixTheFunny();
            reloadTheFunny();
            reloadText();
        }

    function reloadText() {
        charText = Assets.getText(Paths.txt('bio-text/' + characterList[curSelected]));
    }

    function reloadTheFunny()
        {
            characterShit.loadGraphic(Paths.image('collection/characters/' + characterList[curSelected]));
            descShit.loadGraphic(Paths.image('collection/desc/' + characterList[curSelected]));
        }

    function fixTheFunny()
        {
            switch (characterList[curSelected])
            {
                case 'duke':
                    characterShit.x = 150;
                    characterShit.y = 150;
                    characterShit.setGraphicSize(Std.int(characterShit.width * 1));
                case 'chaotix':
                    characterShit.x = 200;
                    characterShit.y = 180;
                    charBio.scale.x = 0.6;
                    charBio.scale.y = 0.6;
                    charBio.updateHitbox();
                    charBio.x = 455;
                    charBio.y = 109;
                    characterShit.setGraphicSize(Std.int(characterShit.width * 1));
                case 'chotix':
                    characterShit.x = 150;
                    characterShit.y = 300;
                    characterShit.setGraphicSize(Std.int(characterShit.width * 1));
                case 'normalcd':
                    characterShit.x = -600;
                    characterShit.y = -550; 
                    characterShit.setGraphicSize(Std.int(characterShit.width * 0.3));
                case 'curse':
                    characterShit.x = -160;
                    characterShit.y = -600;
                    charBio.scale.x = 0.5;
                    charBio.scale.y = 0.5;
                    charBio.updateHitbox();
                    charBio.x = 410;
                    charBio.y = 250;
                    characterShit.setGraphicSize(Std.int(characterShit.width * 0.3));
            }
        }

}