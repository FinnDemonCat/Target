// ignore: unused_import
import 'package:ffigen/ffigen.dart';
import '../libs/raylib/raylib.dart';
import 'haybale.dart';

class Button extends Widget
{
  late NPatchInfo nPatchInfo;
  Texture2D texture;

  Button({
    required HaySize sizing,
    required this.texture,
    required int bottom,
    required int top,
    required int left,
    required int right,
    required NPatchLayout ninfo
  }) : 
    super(sizing: sizing) {
      final rect = Rectangle(0, 0, texture.width.toDouble(), texture.heigth.toDouble());

      this.nPatchInfo = NPatchInfo(
        source: rect,
        bottom: bottom, top: top,
        left: left, right: right,
        layout: ninfo.index
      );

      rect.dispose();
    }
  
  @override
  void draw() => Texture2D.DrawNPatch(texture, nPatchInfo, this);

  @override
  void dispose() {
    nPatchInfo.dispose();
    texture.dispose();
    super.dispose();
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

Button button = Button(
  sizing: HaySize.FullWidth(height: 50),
  texture: Texture2D("c:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_light.png"),
  bottom: 4,
  top: 4,
  left: 4,
  right: 4,
  ninfo: NPatchLayout.NPATCH_NINE_PATCH
);

Button button1 = Button(
  sizing: HaySize.FullWidth(height: 50),
  texture: Texture2D("c:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_light.png"),
  bottom: 4,
  top: 4,
  left: 4,
  right: 4,
  ninfo: NPatchLayout.NPATCH_NINE_PATCH
);

Button button2 = Button(
  sizing: HaySize.FullWidth(height: 50),
  texture: Texture2D("c:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_light.png"),
  bottom: 4,
  top: 4,
  left: 4,
  right: 4,
  ninfo: NPatchLayout.NPATCH_NINE_PATCH
);

Button button3 = Button(
  sizing: HaySize.FullWidth(height: 50),
  texture: Texture2D("c:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_light.png"),
  bottom: 4,
  top: 4,
  left: 4,
  right: 4,
  ninfo: NPatchLayout.NPATCH_NINE_PATCH
);

Widget MainPage()
{
  return Row(
    sizing: HaySize.Grow(),
    children: [
      Column(
        sizing: HaySize.FullHeight(width: 400),
        children: [
          button,
          button1,
          button2,
          button3
        ],
        spacing: 10.0,
        main: HayYAxisAlign.CENTER,
        cross: HayXAxisAlign.CENTER
      ),/* 
      Column(
        sizing: HaySize.FullHeight(width: 400),
        children: [
          // button,
          // button,
          // button,
          // button
        ],
        spacing: 10.0,
        main: HayYAxisAlign.CENTER,
        cross: HayXAxisAlign.CENTER
      ) */
    ]
  );
}

Container page = Container(
  sizing: HaySize.Grow(),
  child: MainPage()
);

void main()
{
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Window.SetState(WinFlags.WINDOW_RESIZABLE);
  Frame.SetTargetFPS(30);

  page.width = winWidth.toDouble();
  page.height = winHeight.toDouble();
  page.mount();

  while(!Window.ShouldClose())
  {
    Draw.RenderFrame(renderLogic: DrawScreen);
  }

  page.dispose();
  Window.Close();
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    page.width = Window.Width().toDouble();
    page.height = Window.Height().toDouble();
    page.mount();
  }

  page.draw();
} 
