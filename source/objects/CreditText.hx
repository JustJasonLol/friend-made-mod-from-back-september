package objects;
import flixel.FlxBasic;
import flixel.group.FlxGroup;

enum Pos {
    LEFT;
    RIGHT;
}

class CreditText extends FlxTypedGroup<FlxBasic> 
{
    public var name:FlxText;
    public var desc:FlxText;
    public var iconSprite:FlxSprite;
    
    public var url:String = null;
    public var pos:Pos = LEFT;

    public function new(x:Float, y:Float, theName:String = 'Test', theDesc:String = 'test tst test', theIcon:String = 'missing_icon', ?posi:Pos = LEFT) {
        super();

        name = new FlxText((posi == LEFT ? FlxG.width * .25 : FlxG.width * .7) - x, y, 0, theName);
        name.setFormat(Paths.font('vcr.ttf'), 45, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        name.antialiasing = ClientPrefs.data.antialiasing;
        add(name);

        iconSprite = new FlxSprite(name.x + name.width - 15, name.y - 70, Paths.image('credits/$theIcon'));
        iconSprite.scale.set(.75, .75);
        iconSprite.antialiasing = ClientPrefs.data.antialiasing;
        add(iconSprite);

        desc = new FlxText(name.x - (name.width / 2), name.y + 50, 0, theDesc);
        desc.setFormat(Paths.font('vcr.ttf'), 28, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
        desc.antialiasing = ClientPrefs.data.antialiasing;
        add(desc);
    }

    public function setOffsets(icon:Array<Float>, descr:Array<Float>)
    {
        if (icon != null) iconSprite.offset.set(icon[0], icon[1]);
        if (descr != null) desc.offset.set(descr[0], descr[1]);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        for (poo in [name, desc, iconSprite])
        {
            name.color = !(FlxG.mouse.overlaps(name) || FlxG.mouse.overlaps(desc) || FlxG.mouse.overlaps(iconSprite)) ? FlxColor.WHITE : FlxColor.fromRGB(252, 227, 3);
            if (FlxG.mouse.overlaps(poo) && FlxG.mouse.justPressed)
            {
                if (url != null) FlxG.openURL(url);
                else FlxG.sound.play(Paths.sound('cancelMenu'));
            }
        }
    }
}