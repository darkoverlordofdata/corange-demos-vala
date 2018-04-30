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
  public static int Character { get { return type_find("Character", sizeof(Character)); } }
  public static int Coin { get { return type_find("Coin", sizeof(Coin)); } }
  public static int Level { get { return type_find("Level", sizeof(Level)); } }
}

