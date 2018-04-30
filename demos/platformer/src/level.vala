using GL;
using SDL;
using COrange;
using COrange.data;
using COrange.assets;


public const int TILE_SIZE = 32;

public struct TileSet {
  public int numTiles;
  public GLuint positionsBuffer;
  public GLuint texcoordsBuffer;
  public AssetHandle mat;
}


[Compact, CCode (ref_function = "level_retain", unref_function = "level_release")]
public class Level {
  public void retain() {}
  public void release() {}
  public extern void free();

  public const int MAX_WIDTH = 512;
  public const int MAX_HEIGHT = 512;
  public int numTileSets;
  public int* tileMap;
  public TileSet[] tileSets;
  public static int tileTypes;
  public static int[] tileCounts;

  public static CObject create(string filename) {

      tileTypes = TileType.all().length;
      tileCounts = new int[tileTypes]; 
      for (int i = 0; i < tileTypes; i++) {
        tileCounts[i] = 0;
      }
      
      Level level = new Level();

      level.numTileSets = tileTypes;
      level.tileSets = new TileSet[tileTypes];
      level.tileMap = new int[MAX_WIDTH * MAX_HEIGHT];
      
      char line[MAX_WIDTH];
      
      int y = 0;
      int x = 0;
      RWops file = new RWops.FromFile(filename, "r");
      while (file.read_line(line, 1024) != 0) {
        
        for (x = 0; x < line.length; x++) {
          char c = line[x];
          if (c != 0) {
            //  int type = tileForChar(c);
            int type = TileType.fromChar(c);
            level.tileMap[x + y * MAX_WIDTH] = type;
            tileCounts[type]++;
          }
        }
        
        y++;
      }

      /* Start from 1, type 0 is none! */
      for (int t = 1; t < tileTypes; t++) {
        
        int numTiles = tileCounts[t];
        
        float[] positionData = new float[3 * 4 * numTiles];
        float[] uvData = new float[2 * 4 * numTiles];

        int i  = 0;
        int j = 0;
        
        for (x = 0; x < MAX_WIDTH; x++) {
          for (y = 0; y < MAX_HEIGHT; y++) {
            int type = level.tileMap[x + y * MAX_WIDTH];
            if( type == t ) {
            
              positionData[i++] = x * TILE_SIZE;
              positionData[i++] = y * TILE_SIZE;
              positionData[i++] = 0;
              
              positionData[i++] = (x+1) * TILE_SIZE;
              positionData[i++] = y * TILE_SIZE;
              positionData[i++] = 0;
              
              positionData[i++] = (x+1) * TILE_SIZE;
              positionData[i++] = (y+1) * TILE_SIZE;
              positionData[i++] = 0;
              
              positionData[i++] = x * TILE_SIZE;
              positionData[i++] = (y+1) * TILE_SIZE;
              positionData[i++] = 0;
              
              uvData[j++] = 0;
              uvData[j++] = 0;
              
              uvData[j++] = 1;
              uvData[j++] = 0;
              
              uvData[j++] = 1;
              uvData[j++] = 1;
              
              uvData[j++] = 0;
              uvData[j++] = 1;
            }  
          }
        }
        
        level.tileSets[t].numTiles = numTiles;
        
        glGenBuffers(1, &level.tileSets[t].positionsBuffer);
        glGenBuffers(1, &level.tileSets[t].texcoordsBuffer);
        
        glBindBuffer(GL_ARRAY_BUFFER, level.tileSets[t].positionsBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 3 * 4 * numTiles, positionData, GL_STATIC_DRAW);
        
        glBindBuffer(GL_ARRAY_BUFFER, level.tileSets[t].texcoordsBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 2 * 4 * numTiles, uvData, GL_STATIC_DRAW);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
      }
        
      return (CObject)level;
    }

    public void delete() {
      /* Start from 1 as 0 is none tile set */
      for (int i = 1; i < numTileSets; i++) {
        glDeleteBuffers(1 , &tileSets[i].positionsBuffer);
        glDeleteBuffers(1 , &tileSets[i].texcoordsBuffer);
      }
      free();
    }
    
    public void renderBackground() {

      glProlog();
      glBindTexture(GL_TEXTURE_2D, Texture.gl("./backgrounds/bluesky.dds"));
      glBegin(GL_QUADS);
        
        glVertex3f(0, Graphics.viewport_height(), 0.0f);
        glTexCoord2f(1, 0);
        glVertex3f(Graphics.viewport_width(), Graphics.viewport_height(), 0.0f);
        glTexCoord2f(1, 1);
        glVertex3f(Graphics.viewport_width(), 0, 0.0f);
        glTexCoord2f(0, 1);
        glVertex3f(0, 0, 0.0f);
        glTexCoord2f(0, 0);
        
      glEnd();
      glEpilog();
    }

    /* Renders each tileset in one go. Uses vertex buffers. */
    public void renderTiles(Vec2 camera) {

      glProlog(camera);
      /* Start from 1, 0 is no tiles! */
      
      for (int i = 1; i < numTileSets; i++) {

        var tile_tex = ((TileType)i).toTexture();

        glBindTexture(GL_TEXTURE_2D, tile_tex.handle());
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, (GLint)GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, (GLint)GL_CLAMP_TO_EDGE);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
        glBindBuffer(GL_ARRAY_BUFFER, tileSets[i].positionsBuffer);
        glVertexPointer(3, GL_FLOAT, 0, null);
        
        glBindBuffer(GL_ARRAY_BUFFER, tileSets[i].texcoordsBuffer);
        glTexCoordPointer(2, GL_FLOAT, 0, null);
        
        glDrawArrays(GL_QUADS, 0, tileSets[i].numTiles * 4);
        
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);  
        glDisableClientState(GL_VERTEX_ARRAY);
        
      }
      glEpilog();
    }

    public int tileAt(Vec2 position) {
      int x = (int)Math.floor( position.x / TILE_SIZE );
      int y = (int)Math.floor( position.y / TILE_SIZE );
      
      assert(x >= 0);
      assert(y >= 0);
      assert(x < MAX_WIDTH);
      assert(y < MAX_HEIGHT);
      
      return tileMap[x + y * MAX_WIDTH];
    
    }

    public Vec2 tilePosition(int x, int y) {
      return Vec2(x * TILE_SIZE, y * TILE_SIZE);
    }

}


  
