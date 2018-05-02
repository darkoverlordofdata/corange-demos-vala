[indent=4]
uses GL
uses SDL
uses Corange
uses Corange.data
uses Corange.assets


[Compact, CCode (ref_function = "", unref_function = "")]
class Character
    velocity        : Vec2
    position        : Vec2
    flapTimer       : float
    facingLeft      : bool
    
    def extern free()

    def static create() : CObject
        var character = new Character()
        character.position = Vec2.Zero()
        character.velocity = Vec2.Zero()
        character.flapTimer = 0
        character.facingLeft = false
        return (CObject)character

    def delete() 
        free()
    
    def toString() : string
        return "Character(%f,%f)".printf(velocity.x, velocity.y)

    def update()
        velocity.x = clamp(velocity.x, -7.0f, 7.0f)
        position = position.add(velocity)
        
        if flapTimer > 0.0
          flapTimer -= (float)Loop.time()

    def render(camera : Vec2)
        glProlog(camera)
      
        /* Conditional as to if we render flap or normal icon */
        glBindTexture(GL_TEXTURE_2D, 
            flapTimer > 0.0 
                ? Texture.gl("./tiles/character_flap.dds")
                 :  Texture.gl("./tiles/character.dds"))

        /* Swaps the direction of the uvs when facing the opposite direction */
        if (facingLeft) 
        
            glBegin(GL_TRIANGLES)
            glTexCoord2f(1, 1); glVertex3f(position.x, position.y + 32, 0)
            glTexCoord2f(1, 0); glVertex3f(position.x, position.y, 0)
            glTexCoord2f(0, 0); glVertex3f(position.x + 32, position.y, 0)
            
            glTexCoord2f(1, 1); glVertex3f(position.x, position.y + 32, 0)
            glTexCoord2f(0, 1); glVertex3f(position.x + 32, position.y + 32, 0)
            glTexCoord2f(0, 0); glVertex3f(position.x + 32, position.y, 0)
            glEnd()
          
        else 
        
            glBegin(GL_TRIANGLES)
            glTexCoord2f(0, 1); glVertex3f(position.x, position.y + 32, 0)
            glTexCoord2f(0, 0); glVertex3f(position.x, position.y, 0)
            glTexCoord2f(1, 0); glVertex3f(position.x + 32, position.y, 0)
            
            glTexCoord2f(0, 1); glVertex3f(position.x, position.y + 32, 0)
            glTexCoord2f(1, 1); glVertex3f(position.x + 32, position.y + 32, 0)
            glTexCoord2f(1, 0); glVertex3f(position.x + 32, position.y, 0)
            glEnd()
          
        glEpilog()
  
