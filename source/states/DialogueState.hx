package states;

import flixel.addons.text.FlxTypeText;
import cutscenes.DialogueBox;
import cutscenes.DialogueBoxPsych;

class DialogueState extends MusicBeatState 
{
    var curDialogue:Int = 0;
    var curTureD:Int = 0;
    var nText:FlxTypeText;

    var cam:FlxCamera;
    var hud:FlxCamera;

    var skipText:FlxText;
    var bg:FlxSprite;

    var skips = false;

    var shit = true;

    // n narrator & d psych dialog
    var acceptType:String = 'n';

    var narratorDialog:Array<String> = [
        'It was a peaceful night, the couple was returning home after having a big party with their friends in the suburb',
        'They happily ran into that guy ,who sit in the pavement, to ask for help'
    ];

    override function create() {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('dialogue/background/0'));
        bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.alpha = 0;
        FlxTween.tween(bg, {alpha: 1}, 1);
        bg.screenCenter();
        add(bg);

        nText = new FlxTypeText(175, 540, 900, '');
        nText.setFormat(Paths.font('vcr.ttf'), 34, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        nText.borderSize = 2;
       // nText.cameras = [hud];
        nText.resetText(narratorDialog[0]);
        nText.sounds = [FlxG.sound.load(Paths.sound('dialogue'))];
        nText.antialiasing = ClientPrefs.data.antialiasing;
        //nText.screenCenter();
        add(nText);

        skipText = new FlxText(FlxG.width - 320, FlxG.height - 30, 300, Language.getPhrase('dialogue_skip', 'Press BACK to Skip'), 16);
		skipText.setFormat(null, 16, FlxColor.WHITE, RIGHT, OUTLINE_FAST, FlxColor.BLACK);
		skipText.borderSize = 2;
    //    skipText.cameras = [hud];
        skipText.antialiasing = ClientPrefs.data.antialiasing;
		add(skipText);

        new FlxTimer().start(1, fd -> startNarrator(0));
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (controls.ACCEPT)
        {
            startNarrator(1);
        }        

        if (controls.BACK)
            MusicBeatState.switchState(new PlayState());
    }

    function startNarrator(count:Int)
    {
        if (acceptType == 'n') curDialogue += count;
        trace('curDialogue: ' + curDialogue);

        switch (curDialogue)
        {
            case 0:
                nText.revive();
                nText.resetText(narratorDialog[0]);
                nText.start(0.05, true);
                nText.alpha = 1;

            case 1:
                nText.alpha = 0;
                nText.kill();
                acceptType = 'd';
                startPsychDialogue(DialogueBoxPsych.parseDialogue(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/dialogue_1')), true);
            
            case 2:
                bg.loadGraphic(Paths.image('dialogue/background/2'));
                bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
                bg.alpha = 0;
                FlxTween.tween(bg, {alpha: 1}, .5);
                shit = false;

            case 3:
                startPsychDialogue(DialogueBoxPsych.parseDialogue(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/dialogue_2')), true, false);

            case 5:
                bg.loadGraphic(Paths.image('dialogue/background/3'));
                bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
                bg.alpha = 0;
                FlxTween.tween(bg, {alpha: 1}, .5);

                nText.revive();
                nText.resetText(narratorDialog[1]);
                nText.start(0.05, true);
                nText.alpha = 1;
            
            case 7:
                nText.alpha = 0;
                nText.kill();
                acceptType = 'd';
                startPsychDialogue(DialogueBoxPsych.parseDialogue(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/dialogue_3')), true, true);

        }
    }

    var dialogueCount:Int = 0;
	public var psychDialogue:DialogueBoxPsych;
    //startPsychDialogue(DialogueBoxPsych.parseDialogue(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/dialogue')));
	//You don't have to add a song, just saying. You can just do "startDialogue(DialogueBoxPsych.parseDialogue(Paths.json(songName + '/dialogue')))" and it should load dialogue.json
	public function startPsychDialogue(dialogueFile:DialogueFile, skips:Bool = false, gotoplaystate:Bool = false):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			psychDialogue = new DialogueBoxPsych(dialogueFile);
			psychDialogue.scrollFactor.set();
            this.skips = skips; 
				psychDialogue.finishThing = function() {
					psychDialogue = null;
					if (gotoplaystate) MusicBeatState.switchState(new PlayState());
                    else {
                        acceptType = 'n';
                        if (shit) startNarrator(1);
                    }
				}
			}
			psychDialogue.nextDialogueThing = startNextDialogue;
			psychDialogue.skipDialogueThing = skipDialogue;
			//psychDialogue.cameras = [hud];
			add(psychDialogue);
	}

    public function startNextDialogue() {
		dialogueCount++;
        trace('current in game dialogue: ' + psychDialogue.currentText);

        if (psychDialogue.currentText == 6 && curDialogue == 1)
        {
            bg.loadGraphic(Paths.image('dialogue/background/1'));
            bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
            bg.alpha = 0;
            FlxTween.tween(bg, {alpha: 1}, .5);
        }

        if (psychDialogue.currentText == 3 && curDialogue == 3)
        {
            bg.loadGraphic(Paths.image('dialogue/background/3'));
            bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
            bg.alpha = 0;
            FlxTween.tween(bg, {alpha: 1}, .5);
        }

        if (psychDialogue.currentText == 14 && (curDialogue == 8 || curDialogue == 7))
        {
            bg.loadGraphic(Paths.image('dialogue/background/4'));
            bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
            bg.alpha = 0;
            FlxTween.tween(bg, {alpha: 1}, .5);
        }
	}

	public function skipDialogue() {

    }
}