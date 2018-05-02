using GL;
using SDL;
using Corange;
using Corange.data;
using Corange.assets;


[Compact, CCode (ref_function = "", unref_function = "")]
public class Character {
    public extern void free();

    public Vec2 velocity;
    public Vec2 position;
    public float flapTimer;
    public bool facingLeft;

    public static CObject create() {
      var character = new Character();
      character.position = Vec2.Zero();
      character.velocity = Vec2.Zero();
      character.flapTimer = 0;
      character.facingLeft = false;
      return (CObject)character;
    }

    public void delete() {
      free();
    }

    public string toString() {
      return "Character(%f,%f)".printf(velocity.x, velocity.y);
    }
    public void update() {
      velocity.x = clamp(velocity.x, -7.0f, 7.0f);
      position = position.add(velocity);
      
      if (flapTimer > 0.0) {
        flapTimer -= (float)Corange.Frame.time();
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
  
