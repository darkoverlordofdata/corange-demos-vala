[indent=4]
uses GL
uses SDL
uses Corange
uses Corange.data
uses Corange.assets

enum TileType 
    NONE
    AIR
    DIRT
    DIRT_ROCK
    DIRT_OVERHANG
    SURFACE
    GRASS
    GRASS_ROCK1
    GRASS_ROCK2
    GRASS_TREE
    TREE
    TREE_TOP
    TREE_TOP_LEFT
    TREE_TOP_RIGHT
    TREE_TOPEST
    TREE_BOT_LEFT
    TREE_BOT_RIGHT
    TREE_JUNC_LEFT
    TREE_JUNC_RIGHT
    TREE_TURN_LEFT
    TREE_TURN_RIGHT
    TREE_SIDE
    HOUSE_TOP_LEFT
    HOUSE_TOP_RIGHT
    HOUSE_BOT_LEFT
    HOUSE_BOT_RIGHT
  
    def toTexture():Texture 
        return (Texture)asset_get(FPath(toString()))
    


    /* These vast when statements are basically a nasty way of assigning properties to the tile types */
    def toString():string 
        case this 
            when NONE
                return "./tiles/tile_sky.dds"
            when AIR
                return "./tiles/tile_sky.dds"
            when DIRT
                return "./tiles/tile_dirt.dds"
            when DIRT_ROCK
                return "./tiles/tile_dirt_rock.dds"
            when DIRT_OVERHANG
                return "./tiles/tile_dirt_overhang.dds"
            when SURFACE
                return "./tiles/tile_surface.dds"
            when GRASS
                return "./tiles/tile_grass.dds"
            when GRASS_ROCK1
                return "./tiles/tile_grass_rock1.dds"
            when GRASS_ROCK2
                return "./tiles/tile_grass_rock2.dds"
            when GRASS_TREE
                return "./tiles/tile_grass_tree.dds"
            when TREE
                return "./tiles/tile_tree.dds"
            when TREE_TOP
                return "./tiles/tile_tree_top.dds"
            when TREE_TOP_LEFT
                return "./tiles/tile_tree_top_left.dds"
            when TREE_TOP_RIGHT
                return "./tiles/tile_tree_top_right.dds"
            when TREE_TOPEST
                return "./tiles/tile_tree_topest.dds"
            when TREE_BOT_LEFT
                return "./tiles/tile_tree_bot_left.dds"
            when TREE_BOT_RIGHT
                return "./tiles/tile_tree_bot_right.dds"
            when TREE_JUNC_LEFT
                return "./tiles/tile_tree_junc_left.dds"
            when TREE_JUNC_RIGHT
                return "./tiles/tile_tree_junc_right.dds"
            when TREE_TURN_LEFT
                return "./tiles/tile_tree_turn_left.dds"
            when TREE_TURN_RIGHT
                return "./tiles/tile_tree_turn_right.dds"
            when TREE_SIDE
                return "./tiles/tile_tree_side.dds"
            when HOUSE_BOT_LEFT
                return "./tiles/tile_house_bot_left.dds"
            when HOUSE_BOT_RIGHT
                return "./tiles/tile_house_bot_right.dds"
            when HOUSE_TOP_LEFT
                return "./tiles/tile_house_top_left.dds"
            when HOUSE_TOP_RIGHT
                return "./tiles/tile_house_top_right.dds"
            default 
                assert_not_reached()
      
      

    static TileType[] all() 
      return { NONE, AIR, DIRT, DIRT_ROCK, DIRT_OVERHANG,
          SURFACE, GRASS, GRASS_ROCK1, GRASS_ROCK2, GRASS_TREE,
          TREE, TREE_TOP, TREE_TOP_LEFT, TREE_TOP_RIGHT, TREE_TOPEST,
          TREE_BOT_LEFT, TREE_BOT_RIGHT, TREE_JUNC_LEFT, TREE_JUNC_RIGHT,
          TREE_TURN_LEFT, TREE_TURN_RIGHT, TREE_SIDE, HOUSE_TOP_LEFT, 
          HOUSE_TOP_RIGHT, HOUSE_BOT_LEFT, HOUSE_BOT_RIGHT }
        
    
  
    static bool hasCollision(int tiletype) 
        case(tiletype) 
            when DIRT
                return true
            when DIRT_ROCK
                return true
            when DIRT_OVERHANG
                return true
            when SURFACE
                return true
            when GRASS_ROCK1
                return true
            when HOUSE_BOT_LEFT
                return true
            when HOUSE_BOT_RIGHT
                return true
            when HOUSE_TOP_LEFT
                return true
            when HOUSE_TOP_RIGHT
                return true
            default
                return false
        
      

    /* Levels are basically stored in an ascii file, with these being the tile type characters. */
    def static TileType fromChar(c:char) 
  
        case(c) 
            when '\r'
                return NONE 
            when '\n'
                return NONE 
            when ' '
                return NONE
            when '`'
                return AIR
            when '#'
                return DIRT
            when 'R': return DIRT_ROCK
            when '"': return DIRT_OVERHANG
            when '~': return SURFACE
            when '_': return GRASS
            when '@': return GRASS_ROCK1
            when '.': return GRASS_ROCK2
            when '!': return GRASS_TREE
            when '|': return TREE
            when '\'': return TREE_TOP
            when '': return TREE_TOP_LEFT
            when '': return TREE_TOP_RIGHT
            when '^': return TREE_TOPEST
            when '(': return TREE_BOT_LEFT
            when ')': return TREE_BOT_RIGHT
            when '+': return TREE_JUNC_RIGHT
            when '*': return TREE_JUNC_LEFT
            when '/': return TREE_TURN_RIGHT
            when '\\': return TREE_TURN_LEFT
            when '-': return TREE_SIDE
            when 'h': return HOUSE_BOT_LEFT
            when 'u': return HOUSE_BOT_RIGHT
            when 'd': return HOUSE_TOP_LEFT
            when 'b': return HOUSE_TOP_RIGHT
            default
                print "Unknown tile type character: '%c', %d\n", c, (int)c
                return NONE
      
    

  