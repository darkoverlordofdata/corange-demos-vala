[indent=4]
uses GL
uses SDL
uses Corange
uses Corange.ui
uses Corange.data

def main (args : array of string) : int
    new Platformer()
    return 1

/** Register entity classes with Corange */
[Compact] 
class EntityType  
    prop static Character : int
        get
            return typeFind("Character", sizeof(Character))

    prop static Coin : int
        get
            return typeFind("Coin",      sizeof(Coin))

    prop static Level : int
        get
            return typeFind("Level",     sizeof(Level))


