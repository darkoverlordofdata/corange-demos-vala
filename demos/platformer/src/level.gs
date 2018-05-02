[indent=4]
uses GL
uses SDL
uses Corange
uses Corange.data
uses Corange.assets


const TILE_SIZE : int = 32

struct TileSet 
    numTiles        : int
    positionsBuffer : GLuint
    texcoordsBuffer : GLuint
    mat             : AssetHandle

[Compact, CCode (ref_function = "", unref_function = "")]
class Level 
    const MAX_WIDTH : int = 512
    const MAX_HEIGHT : int = 512
    numTileSets : int
    tileMap : int*
    tileSets : array of TileSet
    tileTypes : static int 
    tileCounts : static array of int
    def extern free()

    def static create(filename : string) : CObject 

        tileTypes = TileType.all().length
        tileCounts = new array of int[tileTypes] 
        for var i = 0 to (tileTypes-1)
            tileCounts[i] = 0
        
        
        level : Level = new Level()

        level.numTileSets = tileTypes
        level.tileSets = new array of TileSet[tileTypes]
        level.tileMap = new array of int[MAX_WIDTH * MAX_HEIGHT]
        
        line : array of char = new array of char[MAX_WIDTH]
        
        var y = 0
        var x = 0
        file : RWops = new RWops.FromFile(filename, "r")
        while (file.readLine(line, 1024) != 0) 
          
            for x = 0 to (line.length-1)
                var c = line[x]
                if c != 0
                    var type = TileType.fromChar(c)
                    level.tileMap[x + y * MAX_WIDTH] = type
                    tileCounts[type]++
            
          
          
            y++
        

        /* Start from 1, type 0 is none! */
        for var t = 1 to (tileTypes-1)
          
            var numTiles = tileCounts[t]
          
            positionData : array of float = new array of float[3 * 4 * numTiles]
            uvData : array of float = new array of float[2 * 4 * numTiles]

            var i = 0
            var j = 0
            
            for x = 0 to (MAX_WIDTH-1)
                for y = 0 to (MAX_HEIGHT-1)
                    var type = level.tileMap[x + y * MAX_WIDTH]
                    if type == t
                    
                        positionData[i++] = x * TILE_SIZE
                        positionData[i++] = y * TILE_SIZE
                        positionData[i++] = 0
                        
                        positionData[i++] = (x+1) * TILE_SIZE
                        positionData[i++] = y * TILE_SIZE
                        positionData[i++] = 0
                        
                        positionData[i++] = (x+1) * TILE_SIZE
                        positionData[i++] = (y+1) * TILE_SIZE
                        positionData[i++] = 0
                        
                        positionData[i++] = x * TILE_SIZE
                        positionData[i++] = (y+1) * TILE_SIZE
                        positionData[i++] = 0
                        
                        uvData[j++] = 0
                        uvData[j++] = 0
                        
                        uvData[j++] = 1
                        uvData[j++] = 0
                        
                        uvData[j++] = 1
                        uvData[j++] = 1
                        
                        uvData[j++] = 0
                        uvData[j++] = 1
                    
            
          
            
            level.tileSets[t].numTiles = numTiles
            
            glGenBuffers(1, &level.tileSets[t].positionsBuffer)
            glGenBuffers(1, &level.tileSets[t].texcoordsBuffer)
            
            glBindBuffer(GL_ARRAY_BUFFER, level.tileSets[t].positionsBuffer)
            glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 3 * 4 * numTiles, positionData, GL_STATIC_DRAW)
            
            glBindBuffer(GL_ARRAY_BUFFER, level.tileSets[t].texcoordsBuffer)
            glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 2 * 4 * numTiles, uvData, GL_STATIC_DRAW)
            
            glBindBuffer(GL_ARRAY_BUFFER, 0)
            
            
            
        return (CObject)level
    

    def delete() 
        /* Start from 1 as 0 is none tile set */
        for var i = 1 to (numTileSets-1)
            glDeleteBuffers(1, &tileSets[i].positionsBuffer)
            glDeleteBuffers(1, &tileSets[i].texcoordsBuffer)
        
        free()
    
    
    def renderBackground() 

        glProlog()
        glBindTexture(GL_TEXTURE_2D, Texture.gl("./backgrounds/bluesky.dds"))
        glBegin(GL_QUADS)
        
        glVertex3f(0, Graphics.viewportHeight(), 0.0f)
        glTexCoord2f(1, 0)
        glVertex3f(Graphics.viewportWidth(), Graphics.viewportHeight(), 0.0f)
        glTexCoord2f(1, 1)
        glVertex3f(Graphics.viewportWidth(), 0, 0.0f)
        glTexCoord2f(0, 1)
        glVertex3f(0, 0, 0.0f)
        glTexCoord2f(0, 0)
        
        glEnd()
        glEpilog()
      

    /* Renders each tileset in one go. Uses vertex buffers. */
    def renderTiles(camera : Vec2) 

        glProlog(camera)
        /* Start from 1, 0 is no tiles! */
        
        for var i = 1 to (numTileSets-1) 

            var tileTex = ((TileType)i).toTexture()

            glBindTexture(GL_TEXTURE_2D, tileTex.handle())
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (GLint)GL_CLAMP_TO_EDGE)
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (GLint)GL_CLAMP_TO_EDGE)
            
            glEnableClientState(GL_VERTEX_ARRAY)
            glEnableClientState(GL_TEXTURE_COORD_ARRAY)
        
            glBindBuffer(GL_ARRAY_BUFFER, tileSets[i].positionsBuffer)
            glVertexPointer(3, GL_FLOAT, 0, null)
            
            glBindBuffer(GL_ARRAY_BUFFER, tileSets[i].texcoordsBuffer)
            glTexCoordPointer(2, GL_FLOAT, 0, null)
            
            glDrawArrays(GL_QUADS, 0, tileSets[i].numTiles * 4)
            
            glBindBuffer(GL_ARRAY_BUFFER, 0)
            glDisableClientState(GL_TEXTURE_COORD_ARRAY)  
            glDisableClientState(GL_VERTEX_ARRAY)
        
      
        glEpilog()
    

    def tileAt(position : Vec2) : int 
        var x = (int)Math.floor( position.x / TILE_SIZE )
        var y = (int)Math.floor( position.y / TILE_SIZE )
        
        assert(x >= 0)
        assert(y >= 0)
        assert(x < MAX_WIDTH)
        assert(y < MAX_HEIGHT)
        
        return tileMap[x + y * MAX_WIDTH]
    
    

    def tilePosition(x : int, y : int) : Vec2 
        return Vec2(x * TILE_SIZE, y * TILE_SIZE)
    




  
