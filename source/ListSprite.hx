package;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
class ListSprite extends FlxSprite {
    public var targetY:Int = 0;
    public var listGap(default, set):Float = 0;
    public var listTop(default, set):Float = 0;
    function set_listGap(val:Float){
        y = getY();
        return listGap = val;
    }

	function set_listTop(val:Float)
	{
        y = getY();
		return listTop = val;
	}

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):ListSprite
	{
		var sprite:ListSprite = cast super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		return sprite;
	}

    function getY(){
		return (targetY * listGap) + listTop;
    }

    override function update(elapsed:Float){
		super.update(elapsed);
		y = FlxMath.lerp(y, getY(), CoolUtil.boundTo(elapsed * 10.2, 0, 1));
    }
}