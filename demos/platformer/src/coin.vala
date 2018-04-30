using GL;
using SDL;
using COrange;
using COrange.data;
using COrange.assets;

[Compact, CCode (ref_function = "coin_retain", unref_function = "coin_release")]
public class Coin {
    public void retain() {}
    public void release() {}
    public extern void free();

    public Vec2 position;
    public static CObject create() {
        var coin = new Coin();
        coin.position = Vec2.zero();
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
