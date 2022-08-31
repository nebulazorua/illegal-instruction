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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
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
    var bg:FlxSprite;
    var selectorSprite:MenuItemAgainFuckYou;
    var imageName:String;

    override function create()
    {
        Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

        PlayState.isStoryMode = false;

        transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

        #if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Choosing their destiny.", null);
		#end

        bg = new FlxSprite(-80).loadGraphic(Paths.image('chaotixMenu/menu-bg'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
        bg.alpha = 0.5;
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = false;
		add(bg);

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
            selectorSprite.updateHitbox();
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
            FlxG.sound.play(Paths.sound('confirmMenu'));
            PlayState.SONG = Song.loadFromJson(songLowercase + '-hard', songLowercase);
			PlayState.isStoryMode = false;
            /* im sad this doesn't work :(((((
            FlxTween.tween(selectorSprite, {"scale.x": selectorSprite.scale.x + 1, "scale.y": selectorSprite.scale.y + 1}, 1, {ease: FlxEase.cubeInOut});
            FlxTween.tween(selectorSprite, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
            */
            FlxTween.tween(bg, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
            new FlxTimer().start(1, function(tmr:FlxTimer)
                {
                    LoadingState.loadAndSwitchState(new PlayState());
                });
        }
        if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                MusicBeatState.switchState(new MainMenuState());
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