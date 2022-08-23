package;

#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
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
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class BallsFreeplay extends MusicBeatState
{
    var songs:Array<String> = ['breakout', 'soulless-endeavors', 'final-frontier', 'my-horizon', 'our-horizon', 'found-you', 'malediction', 'long-sky', 'hedge', 'manual-blast', 'endless',];
    private var curSelected:Int = 0;

    var selectorSprite:FlxSprite;
    var imageName:String;

    override function create()
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        for (i in 0...songs.length){
            imageName = 'freeplay/' + songs[i];
            selectorSprite = new FlxSprite(800 * i, 0).loadGraphic(Paths.image(imageName));
            add(selectorSprite);
        }
    }
}