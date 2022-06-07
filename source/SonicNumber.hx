package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
using StringTools;

class SonicNumber extends FlxSprite {
  public var number(default, set):String = '0';
  public var style(default, set):String = '';
  public var blinking(default, set):Bool = false;

  public function set_style(val:String){
    var numbers = ["0","1","2","3","4","5","6","7","8","9","-"];
    switch(val){
      case 'chotix':
        numbers = ["0","1","2","3","4","5","6","7","8","9","-","sex"];
      default:
    }

    loadGraphic(Paths.image('sonicUI/${val}/numbers'));
    updateHitbox();
    trace(width, numbers.length, width / numbers.length);
    loadGraphic(Paths.image('sonicUI/${val}/numbers'), true, Std.int(width/numbers.length), Std.int(height/2));

    for(idx in 0...numbers.length){
      var anim = numbers[idx];
      animation.add(anim,[idx],0,false);
      animation.add('${anim}blink',[idx, idx + numbers.length],2);
    }
    return style = val;
  }

  public function new(x:Float, y:Float, initialValue:String = '0', ?initialStyle:String='chaotix'){
    super(x,y);
    style = initialStyle;

    antialiasing = false;
    number = initialValue;
  }

  function set_number(val:String){
    if(animation.getByName(val)==null)
      val = '0';

    if(blinking && animation.getByName(val + "blink")!=null)
      val += "blink";

    animation.play(val,true);
    return number=val;

  }

  function set_blinking(val:Bool){
    blinking = val;

    if(animation.getByName(number + "blink")!=null)
      animation.play(number + "blink",true);

    return blinking;
  }
}



class SonicNumberDisplay extends FlxSpriteGroup {
  public var blankCharacter:String = ''; // What to use for a blank space
  // so if this is '0', if you display 350 with a count of 7, it'll show 0000350
  // note that if its not a number or - it will default to nothing
  // its only a string so you can set it to blank, like ok i could've just made a "showBlanks" bool but whatever

  public var atleastShowZero:Bool = true; // If this is true, it will show a zero when the display is fully blank
  // Otherwise, it'll stay as fully whatever the blankCharacter is

  public var parent(default, set):Dynamic;
  public var parentVariable(default, set):String = '';
  // these vars are for auto-updating

  public var displayed(default, set):Int = 0; // maybe can make this a float and add a decimal to the number image
  // idk atm
  // not really needed so like

  public var blinking(default, set):Bool = false;

  public var style(default, set):String  = '';

  function set_style(val:String){
    for(i in 0...members.length){
      var spr = members[i];
      var num:SonicNumber = cast spr;
      num.style = val;
    }
    return style=val;
  }

  function set_blinking(val:Bool){
    for(spr in members){
      var num:SonicNumber = cast spr;
      num.blinking = val;
    }
    return blinking=val;
  }

  public function new(x:Float, y:Float, count:Int=3, scale:Float = 1, initialValue:Int=0, initialStyle:String = 'chaotix', ?parentRef:Dynamic, variable:String = ''){
    super(x, y);
    style = initialStyle;
    for(i in 0...count){
      var number:SonicNumber = new SonicNumber(0, 0, '0', initialStyle);
      var offset:Float = ((8 * (number.frameWidth / 7)) * scale) * i;
      number.x = offset;
      number.setGraphicSize(Std.int(number.width * scale));
      number.updateHitbox();
      add(number);
    }
    if(parentRef!=null){
      parentVariable = variable;
      parent = parentRef;
    }else{
      displayed = initialValue;
    }
  }

  function set_parentVariable(value:String){
    parentVariable = value;
    updateFromParent();
    return parentVariable;
  }

  function set_parent(value:Dynamic){
    parent = value;
    updateFromParent();
    return parent;
  }

  function updateFromParent():Void
  {
    if(parent!=null && parentVariable!='')
      displayed = Std.int(Reflect.getProperty(parent, parentVariable));

  }


  public function set_displayed(newNumber:Int = 0){
    var seperated:Array<String> = Std.string(newNumber).split('');
    if(seperated.length < members.length){
      for(idx in seperated.length...members.length)
        seperated.unshift(blankCharacter);
    }


    if(seperated.length>members.length){
      seperated=[];
      for(i in 0...members.length)
        seperated.push('9');

    }

    if(style == 'chotix'){
      if(Std.string(newNumber).contains("69")){
        seperated=[];
        for(i in 0...members.length)
          seperated.push('sex');
      }
    }


    for(idx in 0...seperated.length){
      var raw = seperated[idx];
      var val = Std.parseInt(raw);
      var member:SonicNumber = cast members[idx];
      if(Math.isNaN(val) && raw!='-')raw = '';
      if(raw!='' || idx==members.length-1 && atleastShowZero){
        member.number = raw;
        member.visible=true;
      }else
        member.visible=false;

    }
    return displayed=newNumber;
  }

  override public function update(elapsed:Float){
    if(parent!=null){
      if(Reflect.getProperty(parent, parentVariable) != displayed)
        updateFromParent();
    }
    super.update(elapsed);
  }
}
