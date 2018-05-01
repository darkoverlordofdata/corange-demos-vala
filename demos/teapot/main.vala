using GL;
using SDL;
using COrange;
using COrange.ui;
using COrange.data;
using COrange.assets;

public static int main (string[] args) {
    stdout.printf("Hello World\n");
    new Teapot();
    return 1;
}

public class Teapot : GLib.Object {

    public Teapot() {
        corange("../../../COrange/assets_core");

        Graphics.viewportSetTitle("Teapot");
        Graphics.viewportSetPosition(120, 30);
        Graphics.viewportSetSize(800, 560);
            

        var cam  = Camera.create();
        cam.position = Vec3(5, 5, 5);
        cam.target =  Vec3(0, 0, 0);
      
        var teapotShader = AssetHandle.Load(FPath("./assets/teapot.mat"));
        var teapotObject = AssetHandle.Load(FPath("./assets/teapot.obj"));

        var running = true;
        Event e;
        
        while(running) {
          
            COrange.Frame.begin();
            while(Event.poll(out e) != 0) {
                switch(e.type) {
                case EventType.KEYDOWN:
                case EventType.KEYUP:
                    if (e.key.keysym.sym == Input.Keycode.ESCAPE) { running = false; }
                    if (e.key.keysym.sym == Input.Keycode.PRINTSCREEN) { Graphics.viewportScreenshot(); }
                    if (e.key.keysym.sym == Input.Keycode.r &&
                        e.key.keysym.mod == Input.Keymod.LCTRL) {
                        Asset.reloadAll();
                    }
                    break;
                case EventType.QUIT:
                    running = false;
                    break;
                }
                cam.controlOrbit(e);
                uiEvent(e);
            }
            uiUpdate();
        
            glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glEnable(GL_DEPTH_TEST);

            var shader = Material.firstProgram(AssetHandle.ptr(ref teapotShader));
            shader.enable();
            shader.setMat4("world", Mat4.Identity());
            shader.setMat4("view", cam.viewMatrix());
            shader.setMat4("proj", cam.projMatrix());
                  
            shader.setTexture("cube_beach", 0, AssetHandle.Load(FPath("$CORANGE/water/cube_sea.dds")));
            shader.setVec3("camera_direction", cam.direction());
            
            Renderable* r = AssetHandle.RenderablePtr(ref teapotObject);

            for (int i=0; i < r->numSurfaces; i++) {

                RenderableSurface* s = r->surfaces[i];
                
                int mentryId = (int)Math.fminf(i, AssetHandle.MaterialPtr(ref r->material).numEntries-1);
                var me = AssetHandle.MaterialPtr(ref r->material).getEntry(mentryId);
      
                glBindBuffer(GL_ARRAY_BUFFER, s->vertexVbo);

                shader.enableAttribute("vPosition",  3, 18, (void*)0);
                shader.enableAttribute("vNormal",    3, 18, (void*)(sizeof(float) * 3));

                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, s->triangleVbo);
                glDrawElements(GL_TRIANGLES, s->numTriangles * 3, GL_UNSIGNED_INT, (void*)0);
              
                shader.disableAttribute("vPosition");
                shader.disableAttribute("vNormal");
                        
                glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
                glBindBuffer(GL_ARRAY_BUFFER, 0);
            }
            shader.disable();
    
            glDisable(GL_DEPTH_TEST);
            uiRender();
            
            Graphics.swap();
            
            COrange.Frame.end();
        }
          
        finish();
                                
    }
}

