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
    var descShit:FlxSprite;
    var disableInput:Bool = true;
    
    private static var curSelected:Int = 0;
    override function create()
        {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
            //IM SO GOOD AT CODING HOLY FUCKLES

            bgShits = new FlxTypedGroup<FlxSprite>();

            for (i in 0...characterList.length)
                {
                    var spr:FlxSprite = new FlxSprite(0, 0);
                    spr.loadGraphic(Paths.image('collection/bg/' + characterList[i]));
                    spr.ID = i;
                    if (spr.ID != curSelected)
                        {
                            spr.alpha = 0;
                        }
                    spr.antialiasing = ClientPrefs.globalAntialiasing;
                    spr.screenCenter();
                    bgShits.add(spr);
                }
            add(bgShits);

            characterShit = new FlxSprite(0, 0).loadGraphic(Paths.image('collection/characters/' + characterList[curSelected]));
            characterShit.antialiasing = ClientPrefs.globalAntialiasing;
            add(characterShit);

            descShit = new FlxSprite(0, 0).loadGraphic(Paths.image('collection/desc/' + characterList[curSelected]));
            descShit.antialiasing = ClientPrefs.globalAntialiasing;
            add(descShit);

            characterShit.x += 400;
            FlxTween.tween(characterShit, {x: characterShit.x - 400}, 1.5, {
                ease: FlxEase.cubeOut,
                onComplete: function(twn:FlxTween)
                    {
                        disableInput = false;
                    }
                });

            fixTheFunny();

            super.create();
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
            spr.x -= 100;
		    spr.alpha = 0;
            FlxTween.tween(spr, {x: spr.x + 100, alpha: 1}, 0.2, {
                ease: FlxEase.cubeOut,
                onComplete: function(twn:FlxTween)
                    {
                        disableInput = false;
                    }
                });
 
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
                    characterShit.x = 30;
                    characterShit.y = 50;
                    characterShit.scale.x = 0.9;
                    characterShit.scale.y = 0.9;
                case 'chaotix':
                    characterShit.x = 30;
                    characterShit.y = 50;
                case 'chotix':
                    characterShit.x = 30;
                    characterShit.y = 50;
                    characterShit.scale.x = 1.2;
                    characterShit.scale.y = 1.2;
                case 'normalcd':
                    characterShit.x = -600;
                    characterShit.y = -550; 
                    characterShit.scale.x = 0.3;
                    characterShit.scale.y = 0.3;
                case 'curse':
                    characterShit.x = 30;
                    characterShit.y = 50;
                    characterShit.scale.x = 1.2;
                    characterShit.scale.y = 1.2;
            }
        }

}