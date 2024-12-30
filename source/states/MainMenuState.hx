package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import states.editors.MasterEditorMenu;
import options.OptionsState;
import backend.Highscore;
import backend.Song;

enum MainMenuColumn {
	LEFT;
	CENTER;
	RIGHT;
}

class MainMenuState extends flixel.FlxState
{
	public static var psychEngineVersion:String = '1.0b'; // This is also used for Discord RPC
	public static var curSelected:Int = 0;
	public static var curColumn:MainMenuColumn = CENTER;
	var allowMouse:Bool = true; //Turn this off to block mouse movement in menus

	var menuItems:FlxTypedGroup<FlxSprite>;
	var leftItem:FlxSprite;
	var rightItem:FlxSprite;

	//Centered/Text options
	var optionShit:Array<String> = [
		'play',
		'credits',
		'options'
	];

	var leftOption:String = #if ACHIEVEMENTS_ALLOWED 'achievements' #else null #end;
	var rightOption:String = 'options';

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = 0.25;
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

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (num => option in optionShit)
		{
			var item:FlxSprite = createMenuItem(option, 0, 1000);
			item.screenCenter(X);
			FlxTween.tween(item, {y: ((num * 200) + 0) + ((4 - optionShit.length) * 70)}, .8, {ease: FlxEase.expoOut});
		}
		changeItem();

		super.create();
	}

	function createMenuItem(name:String, x:Float, y:Float):FlxSprite
	{
		var menuItem:FlxSprite = new FlxSprite(x, y);
		menuItem.loadGraphic(Paths.image('mainmenu/$name'));
		menuItem.scale.set(.7, .7);
		menuItem.updateHitbox();
		
		menuItem.antialiasing = ClientPrefs.data.antialiasing;
		menuItem.scrollFactor.set();
		menuItems.add(menuItem);
		return menuItem;
	}

	var selectedSomethin:Bool = false;

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		menuItems.members[0].setGraphicSize(menuItems.members[0].width * (curSelected == 0 ? .8 : .7));
		menuItems.members[1].setGraphicSize(menuItems.members[1].width * (curSelected == 1 ? .8 : .7));
		menuItems.members[2].setGraphicSize(menuItems.members[2].width * (curSelected == 2 ? .8 : .7));

		if (!selectedSomethin)
		{
			if (Controls.instance.UI_UP_P)
				changeItem(-1);

			if (Controls.instance.UI_DOWN_P)
				changeItem(1);

			var allowMouse:Bool = allowMouse;
			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				allowMouse = false;
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				var selectedItem:FlxSprite;
				switch(curColumn)
				{
					case CENTER:
						selectedItem = menuItems.members[curSelected];
					case LEFT:
						selectedItem = leftItem;
					case RIGHT:
						selectedItem = rightItem;
				}

				if(leftItem != null && FlxG.mouse.overlaps(leftItem))
				{
					allowMouse = true;
					if(selectedItem != leftItem)
					{
						curColumn = LEFT;
						changeItem();
					}
				}
				else if(rightItem != null && FlxG.mouse.overlaps(rightItem))
				{
					allowMouse = true;
					if(selectedItem != rightItem)
					{
						curColumn = RIGHT;
						changeItem();
					}
				}
				else
				{
					var dist:Float = -1;
					var distItem:Int = -1;
					for (i in 0...optionShit.length)
					{
						var memb:FlxSprite = menuItems.members[i];
						if(FlxG.mouse.overlaps(memb))
						{
							var distance:Float = Math.sqrt(Math.pow(memb.getGraphicMidpoint().x - FlxG.mouse.screenX, 2) + Math.pow(memb.getGraphicMidpoint().y - FlxG.mouse.screenY, 2));
							if (dist < 0 || distance < dist)
							{
								dist = distance;
								distItem = i;
								allowMouse = true;
							}
						}
					}

					if(distItem != -1 && selectedItem != menuItems.members[distItem])
					{
						curColumn = CENTER;
						curSelected = distItem;
						changeItem();
					}
				}
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			switch(curColumn)
			{
				case CENTER:
					if(FlxG.keys.justPressed.F12 && leftOption != null)
					{
						curColumn = LEFT;
						changeItem();
					}
					else if(FlxG.keys.justPressed.F12 && rightOption != null)
					{
						curColumn = RIGHT;
						changeItem();
					}

				case LEFT:
					if(FlxG.keys.justPressed.F12)
					{
						curColumn = CENTER;
						changeItem();
					}

				case RIGHT:
					if(FlxG.keys.justPressed.F12)
					{
						curColumn = CENTER;
						changeItem();
					}
			}

			if (Controls.instance.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				FlxG.sound.play(Paths.sound('confirmMenu')).pitch = 1.3;
				if (optionShit[curSelected] != 'donate')
				{
					selectedSomethin = true;
					FlxG.mouse.visible = false;

					var item:FlxSprite;
					var option:String;
					switch(curColumn)
					{
						case CENTER:
							option = optionShit[curSelected];
							item = menuItems.members[curSelected];

						case LEFT:
							option = leftOption;
							item = leftItem;

						case RIGHT:
							option = rightOption;
							item = rightItem;
					}

					if (option == 'play')
					{
						FlxG.camera.fade(0x000000, 1.5);
						FlxG.sound.music.fadeOut();
					}

					FlxFlicker.flicker(item, option == 'play' ? 2 : 1.2, 0.06, false, false, function(flick:FlxFlicker)
					{
						switch (option)
						{
							case 'play':
								persistentUpdate = false;
								var songLowercase:String = Paths.formatToSongPath('Sleepness');
								var poop:String = Highscore.formatSong(songLowercase, 0);

								try
								{
									Song.loadFromJson(poop, songLowercase);
									PlayState.isStoryMode = false;
									PlayState.storyDifficulty = 0;
								}
								catch(e:haxe.Exception)
								{
									trace('ERROR! ${e.message}');
					
									var errorStr:String = e.message;
									if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
									else errorStr += '\n\n' + e.stack;
									FlxG.sound.play(Paths.sound('cancelMenu'));
									return;
								}
					
								MusicBeatState.switchState(new DialogueState());

								/*LoadingState.prepareToSong();
								LoadingState.loadAndSwitchState(new PlayState());*/
								#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
							case 'credits':
								FlxG.switchState(new CreditsMenu());
							case 'options':
								FlxG.switchState(new states.OptionState());
								OptionsState.onPlayState = false;
								if (PlayState.SONG != null)
								{
									PlayState.SONG.arrowSkin = null;
									PlayState.SONG.splashSkin = null;
									PlayState.stageUI = 'normal';
								}
						}
					});
					
					for (memb in menuItems)
					{
						if(memb == item && option != 'credits')
							continue;

						FlxTween.tween(memb, {alpha: 0}, option != 'credits' ? 0.4 : 1, {ease: FlxEase.quadOut});
					}
				}
				else CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
			}
		}

		if (FlxG.keys.justPressed.TWO)
			FlxG.switchState(new MasterEditorMenu());

		super.update(elapsed);
	}

	function changeItem(change:Int = 0)
	{
		if(change != 0) curColumn = CENTER;
		curSelected = FlxMath.wrap(curSelected + change, 0, optionShit.length - 1);
		if(change != 0) FlxG.sound.play(Paths.sound('scrollMenu')).pitch = 1.3;

		for (item in menuItems)
		{
			item.animation.play('idle');
			item.centerOffsets();
		}

		var selectedItem:FlxSprite;
		switch(curColumn)
		{
			case CENTER:
				selectedItem = menuItems.members[curSelected];
			case LEFT:
				selectedItem = leftItem;
			case RIGHT:
				selectedItem = rightItem;
		}
		selectedItem.animation.play('selected');
		selectedItem.centerOffsets();
		camFollow.y = selectedItem.getGraphicMidpoint().y;
	}
}
