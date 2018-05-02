[indent=4]
uses GL
uses SDL
uses Corange
uses Corange.ui
uses Corange.data

[Compact] 
class Platformer 
    instance        : static unowned Platformer
    currentLevel    : Level
    player          : Character
    framerate       : UIButton
    score           : UIButton
    time            : UIButton
    victory         : UIButton
    newGame         : UIButton
    coinPositions   : array of Vec2
    camera          : Vec2 = Vec2.Zero()
    levelScore      : int = 0
    levelTime       : float = 0
    leftHeld        : bool = false
    rightHeld       : bool = false

    const buffer    : float = 4
    const bounce    : float = 0.5f
    const gravity   : float = 0.2f
      
    construct() 
        instance = this
        coinPositions = {
            Vec2(16, 23), Vec2(33, 28), Vec2(41, 22), Vec2(20, 19), Vec2(18, 28),
            Vec2(36, 20), Vec2(20, 30), Vec2(31, 18), Vec2(45, 23), Vec2(49, 26),
            Vec2(25, 18), Vec2(20, 37), Vec2(44, 32), Vec2(66, 20), Vec2(52, 20),
            Vec2(63, 11), Vec2(52, 12), Vec2(39, 13), Vec2(27, 11), Vec2(73, 20),
            Vec2(65, 29), Vec2(72, 29), Vec2(78, 30), Vec2(78, 20), Vec2(83, 22),
            Vec2(87, 22), Vec2(90, 24), Vec2(94, 19), Vec2(99, 18), Vec2(82, 13),
            Vec2(79, 14), Vec2(106, 22), Vec2(102, 30), Vec2(100, 35), Vec2(93, 27),
            Vec2(88, 34), Vec2(98, 40), Vec2(96, 40), Vec2(94, 40), Vec2(86, 40),
            Vec2(81, 37), Vec2(77, 38), Vec2(72, 34), Vec2(65, 38), Vec2(71, 37)
        }

        corange("../../../Corange/assets_core")
        Graphics.viewportSetIcon(FPath("./logo.bmp"))
        Graphics.viewportSetTitle("d16a")
        Graphics.viewportSetPosition(120, 30)
        Graphics.viewportSetSize(800, 560)

        init()

        /* Set the game running, create SDL_Event struct to monitor events */
        var running = true
        evt : Event
        
        while running
            Loop.begin()
            while Event.poll(out evt) != 0
                case evt.type 
                    when EventType.QUIT
                        running = false

                event(evt)
                uiEvent(evt)
            
            update()
            uiUpdate()
            render()
            uiRender()
            Graphics.swap() 
            Loop.end()
            
        finish()
    

    def resetGame() 
        /* Set the starting level to demo.level */
        currentLevel = (Level)Asset.get(FPath("./levels/demo.level"))
        levelScore = 0
        levelTime = 0.0f
        player.position = Vec2(20, 20).mul(TILE_SIZE)
        player.velocity = Vec2.Zero()

        /* We can create multiple entities uses a name format string like printf */
        Entities.create("coin_id_%i", coinPositions.length, EntityType.Coin)
        /* Get an array of pointers to all coin entities */
        coins : array of Coin = new array of Coin[coinPositions.length]
        Entities.get(coins, null, EntityType.Coin)

        /* Set all the coin initial positions */
        for var i = 0 to (coinPositions.length-1)
            coins[i].position = coinPositions[i].mul(TILE_SIZE)
        
        /* Deactivate victory and new game UI elements */
        victory.active = false
        newGame.active = false
    

    def event(evt : Event) 
        case evt.type 
            when EventType.KEYDOWN
                if evt.key.keysym.sym == Input.Keycode.LEFT  
                    leftHeld = true 
                if evt.key.keysym.sym == Input.Keycode.RIGHT  
                    rightHeld = true 
                
                /* Up key used to "jump". Just adds to up velocity and flaps wings of icon */
                if evt.key.keysym.sym == Input.Keycode.UP 
                    player.velocity.y -= 5.0f
                    player.flapTimer = 0.15f
                
            when EventType.KEYUP
                if evt.key.keysym.sym == Input.Keycode.LEFT  
                    leftHeld = false 
                if evt.key.keysym.sym == Input.Keycode.RIGHT
                    rightHeld = false 

    def collisionDetection() 
        /*
          Collision is fairly simplistic and looks something like this.
          
          @-----@    We check for collision in those points here which
          @       @   are @ signs. If any are colliding with a solid tile
          |       |   then we shift the player so that they are no longer
          @       @   colliding with it. Also invert the velocity.
          @-----@ 
        */
        
        diff : Vec2
        
        /* Bottom Collision */
        
        diff = player.position.fmod(TILE_SIZE)
        
        var bottom1 = player.position.add(Vec2(buffer, TILE_SIZE))
        var bottom2 = player.position.add(Vec2(TILE_SIZE - buffer, TILE_SIZE))
        
        var bottom1Col = TileType.hasCollision(currentLevel.tileAt(bottom1))
        var bottom2Col = TileType.hasCollision(currentLevel.tileAt(bottom2))
        
        if bottom1Col || bottom2Col
            player.position = player.position.add(Vec2(0,-diff.y))
            player.velocity.y *= -bounce
        
        
        /* Top Collision */
        
        diff = player.position.fmod(TILE_SIZE)
        
        var top1 = player.position.add(Vec2(buffer, 0))
        var top2 = player.position.add(Vec2(TILE_SIZE - buffer, 0))
        
        var top1Col = TileType.hasCollision(currentLevel.tileAt(top1))
        var top2Col = TileType.hasCollision(currentLevel.tileAt(top2))
        
        if top1Col || top2Col
            player.position = player.position.add(Vec2(0, TILE_SIZE - diff.y))
            player.velocity.y *= -bounce
        
        
        /* Left Collision */
        
        diff = player.position.fmod(TILE_SIZE)
        
        var left1 = player.position.add(Vec2(0, buffer))
        var left2 = player.position.add(Vec2(0, TILE_SIZE - buffer))
        
        var left1Col = TileType.hasCollision(currentLevel.tileAt(left1))
        var left2Col = TileType.hasCollision(currentLevel.tileAt(left2))
        
        if left1Col || left2Col
            player.position = player.position.add(Vec2(TILE_SIZE - diff.x,0))
            player.velocity.x *= -bounce
        
        
        /* Right Collision */
        
        diff = player.position.fmod(TILE_SIZE)
        
        var right1 = player.position.add(Vec2(TILE_SIZE, buffer))
        var right2 = player.position.add(Vec2(TILE_SIZE, TILE_SIZE - buffer))
        
        var right1Col = TileType.hasCollision(currentLevel.tileAt(right1))
        var right2Col = TileType.hasCollision(currentLevel.tileAt(right2))
        
        if right1Col || right2Col
            player.position = player.position.add(Vec2(-diff.x,0))
            player.velocity.x *= -bounce
      
      
    

    def collisionDetectionCoins() 
        /* We simply check if the player intersects with the coins */
        
        var topLeft = player.position.add(Vec2(-TILE_SIZE, -TILE_SIZE))
        var bottomRight = player.position.add(Vec2(TILE_SIZE, TILE_SIZE))
        
        /* Again we collect pointers to all the coin type entities */
        var numCoins = 0
        coins : array of Coin = new array of Coin[coinPositions.length]
        Entities.get(coins, out numCoins, EntityType.Coin) 
        
        for var i = 0 to (numCoins-1)
            /* Check if they are within the main char bounding box */
            if (coins[i].position.x > topLeft.x
            &&  coins[i].position.x < bottomRight.x 
            &&  coins[i].position.y > topLeft.y 
            &&  coins[i].position.y < bottomRight.y) 
                /* Remove them from the entity manager and delete */
                var coin_name = Entity.name(coins[i])
                Entity.delete(coin_name)

                /* Play a nice twinkle sound */
                Sound.play(Asset.get(FPath("./sounds/coin.wav")))
                
                /* Add some score! */
                levelScore += 10
                
                /* Update the ui text */
                score.label.text = "Score %06i".printf(levelScore)
                score.label.draw()
        
        /* if all the coins are gone and the victory rectangle isn't disaplayed then show it */
        if Entity.count(EntityType.Coin) == 0 && !victory.active
            victory.active = true
            newGame.active = true
      
    def update() 
        if leftHeld
            player.velocity.x -= 0.1f
            player.facingLeft = true
        else if rightHeld
            player.velocity.x += 0.1f
            player.facingLeft = false
        else 
            player.velocity.x *= 0.95f
      
    
        /* Give the player some gravity speed */
        player.velocity.y += gravity
        
        /* Update moves position based on velocity */
        player.update()
        
        /* Two phases of collision detection */
        collisionDetection()
        collisionDetectionCoins()
        /* Camera follows main character */
        camera = Vec2(player.position.x, -player.position.y)
        
        /* Update the framerate text */
        framerate.setLabel(Loop.rate().to_string())
        
        /* Update the time text */
        if !victory.active 
            levelTime += (float)Loop.time()
            time.label.text = "Time %06i".printf((int)levelTime)
            time.label.draw()
      
    

    def render() 
        /* Clear the screen to a single color */
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)
        
        currentLevel.renderBackground()
        player.render(camera)
        
        /* Get pointers to all the coins for rendering */
        coins : array of Coin = new array of Coin[coinPositions.length]
        var numCoins = 0
        Entities.get(coins, out numCoins, EntityType.Coin) 
        
        for var i = 0 to (numCoins-1)
            coins[i].render(camera)
        
        
        currentLevel.renderTiles(camera)
    

    def init() 
        /* Register functions for loading/unloading files with the
        extension .level */
        Asset.handler(EntityType.Level, "level", Level.create, Level.delete)

        /* Register some handlers for creating and destroying entity types */
        Entity.handler(EntityType.Character, Character.create, Character.delete)
        Entity.handler(EntityType.Coin, Coin.create, Coin.delete)

        /* Load Assets */
        Folder.load(FPath("./tiles/"))
        Folder.load(FPath("./backgrounds/"))
        Folder.load(FPath("./sounds/"))
        Folder.load(FPath("./levels/"))

        player = (Character)Entity("player", EntityType.Character)

        /* Add some UI elements */
        framerate = UIButton.create("framerate")
        framerate.move(Vec2(10, 10))
        framerate.resize(Vec2(30, 25))
        framerate.setLabel(" ")
        framerate.disable()

        score = UIButton.create("score")
        score.move(Vec2(50, 10))
        score.resize(Vec2(120, 25))
        score.setLabel("Score 000000")
        score.disable()
          
        time = UIButton.create("time")
        time.move(Vec2(180, 10))
        time.resize(Vec2(110, 25))
        time.setLabel("Time 000000")
        time.disable()
          
        victory = UIButton.create("victory")
        victory.move(Vec2(365, 200))
        victory.resize(Vec2(70, 25))
        victory.setLabel("Victory!")
        victory.disable()

        newGame = UIButton.create("new_game")
        newGame.move(Vec2(365, 230))
        newGame.resize(Vec2(70, 25))
        newGame.setLabel("New Game")
        newGame.setOnclick(newGameOnClick)
        resetGame()

def newGameOnClick(button : UIButton, data : CObject)
    Platformer.instance.resetGame()
          
      


