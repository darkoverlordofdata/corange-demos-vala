[indent=4]
uses GL
uses SDL
uses Corange
uses Corange.data
uses Corange.assets

[Compact, CCode (ref_function = "", unref_function = "")]
class Coin 
    position        : Vec2
    def extern free()
    
    def static create() : CObject 
        var coin = new Coin()
        coin.position = Vec2.Zero()
        return (CObject)coin

    def delete() 
        free()

    def render(camera : Vec2) 
        glProlog(camera, 0)
        glBindTexture(GL_TEXTURE_2D, Texture.gl("./tiles/coin.dds"))
        glBegin(GL_QUADS)
        
        glTexCoord2f(0, 1); glVertex3f(position.x, position.y + 32, 0)
        glTexCoord2f(1, 1); glVertex3f(position.x + 32, position.y + 32, 0)
        glTexCoord2f(1, 0); glVertex3f(position.x + 32, position.y, 0)
        glTexCoord2f(0, 0); glVertex3f(position.x, position.y, 0)
        
        glEnd()
        glEpilog()
    

