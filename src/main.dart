// ignore: unused_import
import 'package:ffigen/ffigen.dart';
import '../libs/raylib/raylib.dart';
import 'haybale.dart';

class Button extends Interactible
{
  late NPatchInfo nPatchInfo;
  Texture2D texture;
  TextBox text;

  Button({
    required HaySize sizing,
    required this.texture,
    required int bottom,
    required int top,
    required int left,
    required int right,
    required NPatchLayout ninfo,
    required this.text,
  }) :
    super(sizing: sizing){
      final rect = Rectangle(0, 0, texture.width.toDouble(), texture.heigth.toDouble());

      this.nPatchInfo = NPatchInfo(
        source: rect,
        bottom: bottom, top: top,
        left: left, right: right,
        layout: ninfo.index
      );

      OnPress = () {};
      rect.Dispose();
  }
  
  @override
  void DrawWidget() {
    super.DrawWidget();

    Texture2D.DrawNPatch(texture, nPatchInfo, this);
    text.DrawWidget();
  }

  @override
  void Mount() {
    if (text.sizing.width == -1) text.width = super.width;
    if (text.sizing.height == -1) text.height = super.height;
    text.x = this.x;
    text.y = this.y;
    text.Mount();

    super.Mount();
  }

  @override
  void Dispose() {
    nPatchInfo.Dispose();
    texture.Dispose();
    super.Dispose();
  }
}

bool ListenTerminal()
{
  if (Key.IsDown(Keyboard.KEY_LEFT_CONTROL) && Key.IsDown(Keyboard.KEY_R))
  {
    return true;
  }
  return false;
} 

int winWidth = 800;
int winHeight = 800;
// AI generated test string
String text = "Welcome back to Let's Game It Out, where today we are playing 'Super-Ultra-Mega-Industrial-Boring-Machine-Simulator-2026'. Now, the developers said I should probably build a small, efficient drill to start my mining empire. But you know me... why build one tiny drill when I can stack five thousand conveyors in a single floating pile of madness that eventually consumes the entire map and collapses the frame rate into a single, painful image? Ive spent the last twelve hours manually placing every individual piece of ore into a giant bucket just to see if the game engine would scream in agony. Spoiler alert: it did! Now lets see if we can make this physics engine actually achieve escape velocity. Its not a bug, its a feature, and that feature is beautiful, beautiful chaos.";

Widget MainPage()
{
  return Button(
    sizing: HaySize.FullWidth(height: 200),
    texture: Texture2D("c:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_light.png"),
    bottom: 4,
    top: 4,
    left: 4,
    right: 4,
    ninfo: NPatchLayout.NPATCH_NINE_PATCH,
    text: TextBox(
      font: Font("c:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\Salmon Typewriter 9 Regular.ttf"),
      text: TextCodepoint.fromString(text),
      textAlign: HayXAxisAlign.LEFT,
      fontSize: 32,
      spacing: 0,
      color: .BLACK
    )
  );
}

late Container page;

void main()
{
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Window.SetState(WinFlags.WINDOW_RESIZABLE);
  Frame.SetTargetFPS(30);

  page = Container(
    sizing: HaySize.Grow(),
    padding: HayPadding.All(10),
    child: MainPage()
  );

  page.width = winWidth.toDouble();
  page.height = winHeight.toDouble();
  page.Mount();

  while(!Window.ShouldClose())
  {
    Draw.RenderFrame(renderLogic: DrawScreen);
  }

  page.Dispose();
  Window.Close();
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    page.width = Window.Width().toDouble();
    page.height = Window.Height().toDouble();

    page.Mount();
  }

  Interactible.SetMousePosition(Mouse.GetX(), Mouse.GetY());
  page.DrawWidget();
} 
