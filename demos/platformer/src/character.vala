using GL;
using SDL;
using COrange;
using COrange.data;
using COrange.assets;


[Compact, CCode (ref_function = "character_retain", unref_function = "character_release")]
public class Character {
    public void retain() {}
    public void release() {}
    public extern void free();

    public Vec2 velocity;
    public Vec2 position;
    public float flapTimer;
    public bool facingLeft;

    public static CObject create() {
      var character = new Character();
      character.position = Vec2.zero();
      character.velocity = Vec2.zero();
      character.flapTimer = 0;
      character.facingLeft = false;
      return (CObject)character;
    }

    public void delete() {
      free();
    }

    public string to_string() {
      return "Character(%f,%f)".printf(velocity.x, velocity.y);
    }
    public void update() {
      velocity.x = clamp(velocity.x, -7.0f, 7.0f);
      position = position.add(velocity);
      
      if (flapTimer > 0.0) {
        flapTimer -= (float)frame_time();
      }
    }

    public void render(Vec2 camera) {
      glProlog(camera);
      
      /* Conditional as to if we render flap or normal icon */
      glBindTexture(GL_TEXTURE_2D, 
        flapTimer > 0.0 
          ? Texture.gl("./tiles/character_flap.dds")
          : Texture.gl("./tiles/character.dds"));

      /* Swaps the direction of the uvs when facing the opposite direction */
      if (facingLeft) {
      
        glBegin(GL_TRIANGLES);
          glTexCoord2f(1, 1); glVertex3f(position.x, position.y + 32, 0);
          glTexCoord2f(1, 0); glVertex3f(position.x, position.y, 0);
          glTexCoord2f(0, 0); glVertex3f(position.x + 32, position.y, 0);
          
          glTexCoord2f(1, 1); glVertex3f(position.x, position.y + 32, 0);
          glTexCoord2f(0, 1); glVertex3f(position.x + 32, position.y + 32, 0);
          glTexCoord2f(0, 0);glVertex3f(position.x + 32, position.y, 0);
        glEnd();
        
      } else {
      
        glBegin(GL_TRIANGLES);
          glTexCoord2f(0, 1); glVertex3f(position.x, position.y + 32, 0);
          glTexCoord2f(0, 0); glVertex3f(position.x, position.y, 0);
          glTexCoord2f(1, 0); glVertex3f(position.x + 32, position.y, 0);
          
          glTexCoord2f(0, 1); glVertex3f(position.x, position.y + 32, 0);
          glTexCoord2f(1, 1); glVertex3f(position.x + 32, position.y + 32, 0);
          glTexCoord2f(1, 0);glVertex3f(position.x + 32, position.y, 0);
        glEnd();
        
      }
      glEpilog();
    }
  }
  
