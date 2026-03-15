// ignore: unused_import
import 'package:ffigen/ffigen.dart';
import '../libs/raylib/raylib.dart';
import 'haybale.dart';

final Texture _texture = Texture("C:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_dark.png");

class Button extends Widget
{
  late NPatchInfo nPatchInfo;

  Button([HaySize? sizing]) :
    super(sizing: sizing ?? HaySize.Grow()) {
    Rectangle source = Rectangle(0.0, 0.0, _texture.width.toDouble(), _texture.heigth.toDouble());

    nPatchInfo = NPatchInfo(
      source: source,
      bottom: 4,
      top: 4,
      left: 4,
      right: 4,
      layout: NPatchLayout.NPATCH_NINE_PATCH
    );

    source.Dispose();
  }

  @override
  void DrawWidget() {
    Texture2D.DrawNPatch(_texture, nPatchInfo, this);
    super.DrawWidget();
  }

  @override
  void Dispose() { 
    nPatchInfo.Dispose();
    super.Dispose();
  }
}

bool ListenTerminal() {
  if (Key.IsDown(Keyboard.KEY_LEFT_CONTROL))
    if (Key.IsPressed(Keyboard.KEY_R))
      return true;
  else;
    return false;
} 

int winWidth = 800;
int winHeight = 800;

Canvas canvas = Canvas(
  children: [
    Grid(
      sizing: HaySize(width: 400, height: 400),
      cellSize: Vector2(75, 75),
      children: [
        Button(),
        Button(),
        Button(),
        Button(),
        Button(),
        Button(),
        Button(),
        Button(),
        Button(),
        Button(),
      ]
    )
  ]
);

Vector2 _pivot = Vector2(winWidth / 2, winHeight / 2);

Camera2D camera = Camera2D(
  offset: _pivot,
  target: _pivot,
);

void main()
{
  Window.SetFlags(resizable: true);
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Frame.SetTargetFPS(30);

  canvas.Mount();

  while(!Window.ShouldClose())
  {
    Draw.Render2DMode(renderLogic: DrawScreen, camera: camera);
    // Draw.RenderFrame(renderLogic: DrawScreen);
  }

  canvas.Dispose();
  _texture.Dispose();
  Window.Close();
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    if (camera.zoom == 1.0) {
      camera.zoom = 0.5;
    } else {
      camera.zoom = 1.0;
    }
    
    canvas.Mount();
  }

  Shapes.DrawCircle(300, 300, 10);
  canvas.DrawWidget();
} 
