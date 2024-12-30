package states;

import objects.CreditText;

class CreditsMenu extends flixel.FlxState
{
    var testGroup:FlxTypedGroup<CreditText>;

    override function create()
    {
        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.loadGraphic(Paths.image('titleScreen/bg'));
		bg.setGraphicSize(Std.int(bg.width * 0.9));
		bg.screenCenter();
		// bg.updateHitbox();
		add(bg);

		var moon:FlxSprite = new FlxSprite();
		moon.antialiasing = ClientPrefs.data.antialiasing;
		moon.loadGraphic(Paths.image('titleScreen/moon'));
		moon.setGraphicSize(Std.int(moon.width * 0.9));
		moon.screenCenter();
		add(moon);

        add(testGroup = new FlxTypedGroup<CreditText>());

        // DEAR GOD IT'S ALL K
        var kei = new CreditText(50, 100, 'KeiMarfin', 'Director / Arist / Animator', 'kei');
        kei.setOffsets([0, 10], [-25, 0]);
        kei.url = 'https://youtube.com/@stupid_kei';
        testGroup.add(kei);

        var kai = new CreditText(60, 250, 'Kai4rtist', 'Co-Director / Arist / Animator', 'kai');
        kai.url = 'https://x.com/Kai_daArtist';
        testGroup.add(kai);

        var kat = new CreditText(130, 400, 'Katsuki Tokima', 'Charter / PlayTester', 'katsuki');
        kat.setOffsets([0, -10], [-230, 0]);
        kat.url = 'https://www.youtube.com/@KatsukiTokima';
        testGroup.add(kat);

        var noah = new CreditText(75, 550, 'NoahGani1', 'Chromatics', 'noah');
        noah.setOffsets([0, -10], [-150, 0]);
        noah.url = 'https://www.youtube.com/channel/UCFZxiYP6M4pQwi3btUiGH7g';
        testGroup.add(noah);

        // me hi :]]
        var jason = new CreditText(150, 150, 'JustJasonLol', 'Programmer', 'jason', RIGHT);
        jason.setOffsets([0, -10], [-240, 0]);
        jason.url = 'https://x.com/JustJasonLol_';
        testGroup.add(jason);

        var nega = new CreditText(40, 300, 'nega', 'Composer', 'nega', RIGHT);
        nega.setOffsets([0, -10], [-42, 0]);
        testGroup.add(nega);

        var raul = new CreditText(150, 450, 'Raul Gamundi', '""Programmer""', 'raui', RIGHT);
        raul.setOffsets([0, -10], [-250, 0]);
        raul.url = 'https://www.youtube.com/@raulg836';
        testGroup.add(raul);

        for (shit in [kei, kai, kat, noah, jason, nega, raul])
        {
            shit.iconSprite.alpha = 0;
            shit.name.alpha = 0;
            shit.desc.alpha = 0;
            FlxTween.tween(shit, {"iconSprite.alpha": 1, "name.alpha": 1, "desc.alpha": 1}, .5);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.instance.BACK)
        {
            for (hmm in testGroup)
            {
                FlxTween.cancelTweensOf(hmm);
                FlxTween.tween(hmm, {"iconSprite.alpha": 0, "name.alpha": 0, "desc.alpha": 0}, .5, {onComplete: f -> FlxG.switchState(new MainMenuState())});
            }
        }
    }
}