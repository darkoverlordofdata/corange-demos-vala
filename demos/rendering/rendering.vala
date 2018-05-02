using GL;
using SDL;
using Corange;
using Corange.ui;
using Corange.data;
using Corange.assets;
using Corange.entities;
using Corange.rendering;

/** Register entity classes with Corange */
[Compact] 
public class EntityType  {
  public static int StaticObject   { get { return typeFind("static_object",   sizeof(StaticObject)); } }
  public static int AnimatedObject { get { return typeFind("animated_object", sizeof(AnimatedObject)); } }
}

static int objectId = 0;
static Renderer? dr = null;

void renderingInit() {
  
    Graphics.viewportSetTitle("Renderers");
    Graphics.viewportSetSize(800, 540);

    Folder.load(FPath("./assets/podium/"));
    Folder.load(FPath("./assets/cello/"));
    Folder.load(FPath("./assets/piano/"));
    Folder.load(FPath("./assets/imrod/"));
    Folder.load(FPath("./assets/dino/"));
  
    var sPodium = (StaticObject)Entity("podium", EntityType.StaticObject);

    sPodium.renderable = AssetHandle(FPath("./assets/podium/podium.bmf"));

    var sCello = (StaticObject)Entity("cello", EntityType.StaticObject);
    sCello.renderable = AssetHandle(FPath("./assets/cello/cello.bmf"));
    sCello.position = Vec3(0, 3, 0);
    sCello.rotation = Quat.RotationX(-1.7f);
    sCello.scale = Vec3(0.75f, 0.75f, 0.75f);

    var sPiano = (StaticObject)Entity("piano", EntityType.StaticObject);
    sPiano.renderable = AssetHandle(FPath("./assets/piano/piano.bmf"));
    sPiano.position = Vec3(1, 5, 0);

    var sDino = (StaticObject)Entity("dino", EntityType.StaticObject);
    sDino.renderable = AssetHandle(FPath("./assets/dino/dino.bmf"));
    sDino.scale = Vec3(4 ,4, 4);
  
    var aImrod = (AnimatedObject)Entity("imrod", EntityType.AnimatedObject);
    aImrod.loadSkeleton(AssetHandle(FPath("./assets/imrod/imrod.skl")));

    aImrod.renderable = AssetHandle(FPath("./assets/imrod/imrod.bmf"));
    aImrod.animation = AssetHandle(FPath("./assets/imrod/imrod.ani"));
    aImrod.rotation = Quat.RotationY(1.57f);
    aImrod.scale = Vec3(1.25f, 1.25f, 1.25f);
        
    /* Put some text on the screen */
    
    var framerate = UIButton.create("framerate");
    framerate.move(Vec2(10,10));
    framerate.resize(Vec2(30,25));
    framerate.setLabel("FRAMERATE");
    framerate.disable();

    var object = UIButton.create("object");
    object.move(Vec2(10, Graphics.viewportHeight() - 70));
    object.resize(Vec2(60,25));
    object.setLabel("Object");
    object.disable();

    var piano = UIButton.create("piano");
    piano.move(Vec2(80, Graphics.viewportHeight() - 70));
    piano.resize(Vec2(50,25));
    piano.setLabel("Piano");
      
    var cello = UIButton.create("cello");
    cello.move(Vec2(140, Graphics.viewportHeight() - 70));
    cello.resize(Vec2(50,25));
    cello.setLabel("Cello");

    var imrod = UIButton.create("imrod");
    imrod.move(Vec2(200, Graphics.viewportHeight() - 70));
    imrod.resize(Vec2(50,25));
    imrod.setLabel("Imrod");
    
    var dino = UIButton.create("dino");
    dino.move(Vec2(260, Graphics.viewportHeight() - 70));
    dino.resize(Vec2(40,25));
    dino.setLabel("Dino");

    piano.setOnclick((button, data) => { objectId = 0; });
    cello.setOnclick((button, data) => { objectId = 1; });
    imrod.setOnclick((button, data) => { objectId = 2; });
    dino.setOnclick((button, data)  => { objectId = 3; });

    /* New Camera and light */
    
    var cam  = Camera.create();
    cam.position = Vec3(25.0f, 25.0f, 10.0f);
    cam.target =  Vec3(0, 7, 0);

    /* Renderer Setup */
    
    dr = new Renderer(AssetHandle.load(FPath("./assets/graphics.cfg")));
    dr.setCamera(cam);
    dr.setTod(0.15f, 0);
    dr.setSkydomeEnabled(false);
  
}

static void renderingEvent(Event event) {
    var cam = (Camera)Entity.get("camera");
    cam.controlOrbit(event);
}

static void renderingUpdate() {
    var cam = (Camera)Entity.get("camera");
    
    cam.controlJoyorbit((float)Loop.time());
  
    var framerate = UIButton.get("framerate");
    framerate.setLabel(Loop.rate().to_string());
    
    var imrod = (AnimatedObject)Entity.get("imrod");
    imrod.update((float)Loop.time() * 0.25f);
    
}

static void renderingRender() {
  
    dr.add(RenderObject.static((StaticObject)Entity.get("podium")));
  
    switch (objectId) {
      case 0: dr.add(RenderObject.static((StaticObject)Entity.get("piano"))); break;
      case 1: dr.add(RenderObject.static((StaticObject)Entity.get("cello"))); break;
      case 2: dr.add(RenderObject.animated((AnimatedObject)Entity.get("imrod"))); break;
      case 3: dr.add(RenderObject.static((StaticObject)Entity.get("dino"))); break;
    }
    
    dr.render();
    
}
  
static void renderingFinish() {
    dr.delete();
}
    
public static int main (string[] args) {

    corange("../../../Corange/assets_core");
    renderingInit();
  
    var running = true;
    Event event;
    
    while (running) {
      
      Loop.begin();
      
      while (Event.poll(out event) != 0) {
        switch(event.type) {
        case EventType.KEYDOWN: break;
        case EventType.KEYUP:
          if (event.key.keysym.sym == Input.Keycode.ESCAPE) { running = false; }
          if (event.key.keysym.sym == Input.Keycode.PRINTSCREEN) { Graphics.viewportScreenshot(); }
          if ((event.key.keysym.sym == Input.Keycode.r) &&
              (event.key.keysym.mod == Input.Keymod.LCTRL)) {
                Asset.reloadAll();
            }
          break;
        case EventType.QUIT:
          running = false;
          break;
        }
        renderingEvent(event);
        uiEvent(event);
      }
      
      renderingUpdate();
      uiUpdate();
      
      renderingRender();
      uiRender();
      Graphics.swap(); 
      Loop.end();
    }
    
    renderingFinish();
    
    finish();
    
    return 0;
  }