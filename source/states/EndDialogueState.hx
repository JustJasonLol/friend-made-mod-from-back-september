package states;

import lime.app.Application;
import flixel.addons.text.FlxTypeText;
import cutscenes.DialogueBox;
import cutscenes.DialogueBoxPsych;

class EndDialogueState extends MusicBeatState 
{
    var curDialogue:Int = 0;
    var curTureD:Int = 0;
    var nText:FlxTypeText;

    var cam:FlxCamera;
    var hud:FlxCamera;

    var skipText:FlxText;
    var bg:FlxSprite;

    var skips = false;

    // n narrator & d psych dialog
    var acceptType:String = 'd';

    var narratorDialog:Array<String> = [
        'BF and GF were happily on the way to their home.',
        'While Kei, after watching them go...',
        'he smiled, fell asleep and completely slept on the pavement.',
        'What a surprise! He slept very well after being sleepless for a whole week. Well, glad to see him sleep like that. Good night lil boy...'
    ];

    override function create() {
        super.create();

        bg = new FlxSprite().loadGraphic(Paths.image('dialogue/bgend/0'));
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
        {
            FlxG.camera.fade();
            FlxTween.tween(Application.current.window, {y: openfl.Lib.application.window.display.bounds.height * 2}, 5, {ease: FlxEase.sineInOut, onComplete: s->Sys.exit(0)});
        }
    }

    function startNarrator(count:Int)
    {
        if (acceptType == 'n') curDialogue += count;
        trace('curDialogue: ' + curDialogue);

        switch (curDialogue)
        {
            case 0:
                startPsychDialogue(DialogueBoxPsych.parseDialogue(Paths.json(Paths.formatToSongPath(PlayState.SONG.song) + '/dialogue_end')), true);
        
            case 1:
                acceptType= 'n';
                nText.revive();
                nText.resetText(narratorDialog[0]);
                nText.start(0.05, true);
                nText.alpha = 1;

            case 2:
                bg.loadGraphic(Paths.image('dialogue/bgend/2'));
                bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
                bg.alpha = 0;
                FlxTween.tween(bg, {alpha: 1}, .5);

                nText.revive();
                nText.resetText(narratorDialog[1]);
                nText.start(0.05, true);
                nText.alpha = 1;
                
            case 3:
                bg.loadGraphic(Paths.image('dialogue/bgend/3'));
                bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
                bg.alpha = 0;
                FlxTween.tween(bg, {alpha: 1}, .5);

                nText.revive();
                nText.resetText(narratorDialog[2]);
                nText.start(0.05, true);
                nText.alpha = 1;

            case 4:
                bg.loadGraphic(Paths.image('dialogue/bgend/4'));
                bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
                bg.alpha = 0;
                FlxTween.tween(bg, {alpha: 1}, .5);

                nText.revive();
                nText.resetText(narratorDialog[3]);
                nText.start(0.05, true);
                nText.alpha = 1;

            case 5:
                FlxG.camera.fade();
                FlxTween.tween(Application.current.window, {y: openfl.Lib.application.window.display.bounds.height * 2}, 5, {onComplete: s->Sys.exit(0)});
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
                    curDialogue = 1;
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

        if (psychDialogue.currentText == 6)
        {
            bg.loadGraphic(Paths.image('dialogue/bgend/1'));
            bg.setGraphicSize((1980 / 1.546618) - 2127, (1080 / 1.5));
            bg.alpha = 0;
            FlxTween.tween(bg, {alpha: 1}, .5);
        }
	}

	public function skipDialogue() {

    }
}