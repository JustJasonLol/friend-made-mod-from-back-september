package states.stages;

class Thing extends BaseStage {
    override function create()
    {
        var bg = new BGSprite('sigma');
        bg.scale.set(.8, .8);
		bg.updateHitbox();
        add(bg);
    }

    override function createPost()
    {
        var bg = new BGSprite('sigmaAgain');
        bg.scale.set(.85, .85);
        bg.updateHitbox();
        bg.scrollFactor.set(1.1, 1.1);
        add(bg);
    }

    override function beatHit()
    {
        if (curBeat == 348)
        {
            PlayState.instance.camOther.fade(FlxColor.BLACK, 3);
            //PlayState.instance.triggerEvent("Camera Follow Pos", '1500', '100', 0);
            @:privateAccess PlayState.instance.isCameraOnForcedPos = true;
            FlxTween.tween(PlayState.instance.camFollow, {x: 1500, y: 300}, 9);
            PlayState.instance.cameraSpeed = 1;
        }
    }
}