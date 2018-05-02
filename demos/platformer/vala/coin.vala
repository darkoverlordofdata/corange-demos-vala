using GL;
using SDL;
using Corange;
using Corange.data;
using Corange.assets;

[Compact, CCode (ref_function = "", unref_function = "")]
public class Coin {
    public extern void free();

    public Vec2 position;
    public static CObject create() {
        var coin = new Coin();
        coin.position = Vec2.Zero();
        return (CObject)coin;
    }

    public void delete() {
      free();
    }

    public void render(Vec2 camera) {
      glProlog(camera, 0);
      glBindTexture(GL_TEXTURE_2D, Texture.gl("./tiles/coin.dds"));
      glBegin(GL_QUADS);
        
        glTexCoord2f(0, 1); glVertex3f(position.x, position.y + 32, 0);
        glTexCoord2f(1, 1); glVertex3f(position.x + 32, position.y + 32, 0);
        glTexCoord2f(1, 0); glVertex3f(position.x + 32, position.y, 0);
        glTexCoord2f(0, 0); glVertex3f(position.x, position.y, 0);
        
      glEnd();
      glEpilog();
    }
}
