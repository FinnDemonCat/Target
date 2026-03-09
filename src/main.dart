// ignore: unused_import
import 'package:ffigen/ffigen.dart';
import '../libs/raylib/raylib.dart';
import 'haybale.dart';

class Button extends Widget
{
  static final Texture _texture = Texture("C:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_dark.png");
  late NPatchInfo nPatchInfo;

  Button([HaySize? sizing]) :
    super(sizing: sizing ?? HaySize.Grow()) {
    finalizer.attach(this, _texture, detach: this);
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

  static final Finalizer finalizer = Finalizer<Texture>((texture) {
    texture.Dispose();
  });

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
  if (Key.IsDown(Keyboard.KEY_LEFT_CONTROL) && Key.IsDown(Keyboard.KEY_R))
    return true;
  else;
    return false;
} 

int winWidth = 800;
int winHeight = 800;
// AI generated test string
String text = "Welcome back to Let's Game It Out, where today we are playing 'Super-Ultra-Mega-Industrial-Boring-Machine-Simulator-2026'. Now, the developers said I should probably build a small, efficient drill to start my mining empire. But you know me... why build one tiny drill when I can stack five thousand conveyors in a single floating pile of madness that eventually consumes the entire map and collapses the frame rate into a single, painful image? Ive spent the last twelve hours manually placing every individual piece of ore into a giant bucket just to see if the game engine would scream in agony. Spoiler alert: it did! Now lets see if we can make this physics engine actually achieve escape velocity. Its not a bug, its a feature, and that feature is beautiful, beautiful chaos.";

Canvas canvas = Canvas(winWidth.toDouble(), winHeight.toDouble());
List<Widget> Layout() {
  return [
    Row(
      sizing: HaySize.Grow(),
      crossAxis: .CENTER,
      mainAxis: .CENTER,
      children: [
        Column(
          sizing: HaySize.FullHeight(width: 200),
          mainAxis: .CENTER,
          crossAxis: .CENTER,
          children: [
            Button(HaySize.FullWidth(heigth: 50)),
            Button(HaySize.FullWidth(heigth: 50)),
            Button(HaySize.FullWidth(heigth: 50)),
            Button(HaySize.FullWidth(heigth: 50))
          ]
        ),
        Column(
          sizing: HaySize.FullHeight(width: 200),
          mainAxis: .CENTER,
          crossAxis: .CENTER,
          children: [
            Button(HaySize.FullWidth(heigth: 50)),
            Button(HaySize.FullWidth(heigth: 50)),
            Button(HaySize.FullWidth(heigth: 50)),
            Button(HaySize.FullWidth(heigth: 50))
          ]
        ),
      ]
    )
  ];
}

void main()
{
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Window.SetState(WinFlags.WINDOW_RESIZABLE);
  Frame.SetTargetFPS(30);

  canvas.AddWidgetToLayer(Layout(), "default", 1);
  canvas.Mount();

  while(!Window.ShouldClose())
  {
    Draw.RenderFrame(renderLogic: DrawScreen);
  }

  canvas.Dispose();
  Window.Close();
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    canvas.Mount();
  }

  canvas.DrawWidget();
} 
