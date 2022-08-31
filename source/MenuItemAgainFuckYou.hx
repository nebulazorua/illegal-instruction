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

class MenuItemAgainFuckYou extends FlxSprite
{
    public var newX:Float = 0;

    public function new(x:Float, y:Float, yeah:String){
        super(x, y);
        loadGraphic(Paths.image(yeah));
        antialiasing = ClientPrefs.globalAntialiasing;
    }

    override function update(elapsed:Float) // FOR SOME REASON NORMAL UPDATE BROKE SO IDFKKKKK
    //lol 'public function updateAgain' moment
    {
        x = FlxMath.lerp(x, (newX * 1300), CoolUtil.boundTo(elapsed * 10.2, 0, 1));
        super.update(elapsed);
    }
}