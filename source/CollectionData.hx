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

class CollectionData
{
    //all of this is unused lol
    public static var charString:String;

    public static function getCurrentBio(characterName)
    {
        switch(characterName){
            case "chaotix":
                charString = "Chaotix\nThe result of Tails' data being left over in a prototype of\nKnuckles Chaotix.\nHe only wishes to become whole again, by any means necessary.\nSongs: My Horizon, Our Horizon\nCharacter owned by averyavary.";
            case "curse":
                charString = "Curse\nCurse is described as a little ball of sunshine who just needs a break from the world.\nHe has a heart of gold and \nwants nothing more but to see those around him happy and chipper.\nWhile still dealing with his own inner demons, he still makes time for those around him and makes sure they're happy.\nDespite this, he's still a bit stubborn when it comes to his own wellbeing,\nhe doesn't like being worried for, he loathes it due to hyper independence.";
            default:
                charString = "i aint got no bio!!!";
        }
        trace(characterName);
    }
}