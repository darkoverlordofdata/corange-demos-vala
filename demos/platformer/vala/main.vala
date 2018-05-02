using GL;
using SDL;
using Corange;
using Corange.ui;
using Corange.data;

public static int main (string[] args) {
  new Platformer();
  return 1;
}


/** Register entity classes with Corange */
[Compact] 
public class EntityType  {
  public static int Character { get { return typeFind("Character", sizeof(Character)); } }
  public static int Coin      { get { return typeFind("Coin",      sizeof(Coin)); } }
  public static int Level     { get { return typeFind("Level",     sizeof(Level)); } }
}

