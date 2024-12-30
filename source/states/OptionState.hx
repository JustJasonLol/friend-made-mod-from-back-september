package states;

import states.MainMenuState;
import backend.StageData;

class OptionState extends flixel.FlxState
{
	var options:Array<String> = [
		'Note Colors',
		'Controls',
		'Delay & Combo',
		'Graphics',
		'Visuals',
		'Gameplay'
	];
	private var grpOptions:FlxTypedGroup<FlxText>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var onPlayState:Bool = false;

	function openSelectedSubstate(label:String) {
		switch(label)
		{
			case 'Note Colors':
				openSubState(new options.NotesSubState());
			case 'Controls':
				openSubState(new options.ControlsSubState());
			case 'Graphics':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals':
				openSubState(new options.VisualsSettingsSubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Delay & Combo':
				MusicBeatState.switchState(new options.NoteOffsetState());
			case 'Language':
				openSubState(new options.LanguageSubState());
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
    var bg:FlxSprite;
    var moon:FlxSprite;

	override function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end

		bg = new FlxSprite();
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.loadGraphic(Paths.image('titleScreen/bg'));
		bg.setGraphicSize(Std.int(bg.width * 0.9));
		bg.screenCenter();
		add(bg);

		moon = new FlxSprite();
		moon.antialiasing = ClientPrefs.data.antialiasing;
		moon.loadGraphic(Paths.image('titleScreen/moon'));
		moon.setGraphicSize(Std.int(moon.width * 0.9));
		moon.screenCenter();
		add(moon);

        for (st in [bg, moon]) FlxTween.color(st, onPlayState ? .0001 : 1, FlxColor.WHITE, FlxColor.fromRGB(190, 176, 214));

		grpOptions = new FlxTypedGroup<FlxText>();
		add(grpOptions);

		for (num => option in options)
		{
			var optionText:FlxText = new FlxText(30, FlxG.width * 2, 0, Language.getPhrase('options_$option', option), true);
			//optionText.screenCenter(X).x -= 100;
            optionText.setFormat(Paths.font('Lonely Cake.ttf'), 44, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
            FlxTween.tween(optionText, {y: ((FlxG.height - optionText.height) / 2) + ((92 * (num - (options.length / 2))) + 45)}, 1, {ease: FlxEase.expoOut});
			//optionText.y += (92 * (num - (options.length / 2))) + 45;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
        selectorLeft.visible = false;
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
        selectorRight.visible = false;
		add(selectorRight);

		changeSelection();
		ClientPrefs.saveSettings();

		var sfhdj:FlxText = new FlxText(12, FlxG.height - 24, 0, 'coding was rushed sorry for the lack of unique options menu :[', 12);
		sfhdj.scrollFactor.set();
		sfhdj.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sfhdj);

		super.create();
	}

	override function closeSubState()
	{
		super.closeSubState();
		ClientPrefs.saveSettings();
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("Options Menu", null);
		#end
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.instance.UI_UP_P)
			changeSelection(-1);
		if (Controls.instance.UI_DOWN_P)
			changeSelection(1);

		if (Controls.instance.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(onPlayState)
			{
				StageData.loadDirectory(PlayState.SONG);
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.volume = 0;
			}
			else {
                for (st in [bg, moon]) 
                {
                    for (i in 0...grpOptions.members.length) FlxTween.tween(grpOptions.members[i], {y: -500}, 1, {ease: FlxEase.expoOut});
                    FlxTween.color(st, 1, FlxColor.fromRGB(190, 176, 214), FlxColor.WHITE, {onComplete: d -> FlxG.switchState(new MainMenuState())});
                }
            }
		}
		else if (Controls.instance.ACCEPT) openSelectedSubstate(options[curSelected]);
	}
	
	function changeSelection(change:Int = 0)
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, options.length - 1);

		for (i in 0...grpOptions.members.length)
		{
			grpOptions.members[i].alpha = 0.6;
			grpOptions.members[curSelected].alpha = 1;
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	override function destroy()
	{
		ClientPrefs.loadPrefs();
		super.destroy();
	}
}