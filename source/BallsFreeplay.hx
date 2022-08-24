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
    private var grpImages:FlxTypedGroup<MenuItemAgainFuckYou>;

    var selectorSprite:MenuItemAgainFuckYou;
    var imageName:String;

    override function create()
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        grpImages = new FlxTypedGroup<MenuItemAgainFuckYou>();
		add(grpImages);

        for (i in 0...songs.length){
            imageName = 'freeplay/' + songs[i];
            if(songs[i] == 'manual-blast' || songs[i] == 'hedge'){
                imageName = 'freeplay/placeholder';
            }

            selectorSprite = new MenuItemAgainFuckYou(1300 * i, 0, imageName);
            //selectorSprite.x += ((selectorSprite.x + 1500) * i); //eh????
            selectorSprite.newX = i;
            selectorSprite.screenCenter();
            selectorSprite.ID = i;
            grpImages.add(selectorSprite);
        }
    }
    override function update(elapsed:Float)
    {
        var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

        selectorSprite.update(elapsed);

        if(controls.UI_RIGHT_P)
            changeSelection(1);
        if(controls.UI_LEFT_P)
            changeSelection(-1);
        if(accepted){
            var songLowercase:String = Paths.formatToSongPath(songs[curSelected]);

            PlayState.SONG = Song.loadFromJson(songLowercase + '-hard', songLowercase);
			PlayState.isStoryMode = false;

            LoadingState.loadAndSwitchState(new PlayState());
        }
        super.update(elapsed);
    }
    function changeSelection(change:Int){
        curSelected += change;

        if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var bullShit:Int = 0;

        for (item in grpImages.members)
            {
                item.newX = bullShit - curSelected;
                if (item.ID == curSelected)
                    item.alpha = 1;
                else
                    item.alpha = 0.5;
                bullShit++;
            }
    }
}