using GL;
using SDL;
using COrange;
using COrange.ui;
using COrange.data;

public static int main (string[] args) {
  new Platformer();
  return 1;
}

/** Register entity classes with COrange */
[Compact] 
public class EntityType  {
  public static int Character { get { return typeFind("Character", sizeof(Character)); } }
  public static int Coin { get { return typeFind("Coin", sizeof(Coin)); } }
  public static int Level { get { return typeFind("Level", sizeof(Level)); } }
}

