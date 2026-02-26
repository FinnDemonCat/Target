// ignore: unused_import
import 'package:ffigen/ffigen.dart';
import '../libs/raylib/raylib.dart';
import 'haybale.dart';

int winWidth = 800;
int winHeight = 800;
Columm columm = Columm(0, 0, 800, 800);

class Button extends Widget
{
  Button([super.x, super.y, super.width, super.height]);
  @override
  void draw() => Shapes.DrawRectangleRounded(this, 0.25, 1);
}

bool ListenTerminal()
{
  if (Key.IsDown(Keyboard.KEY_LEFT_CONTROL) && Key.IsDown(Keyboard.KEY_R))
  {
    return true;
  }
  return false;
} 

void main()
{
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Frame.SetTargetFPS(30);

  columm.widgets.add(Button(0, 0, 200, 50));
  columm.widgets.add(Button(0, 0, 200, 50));
  columm.widgets.add(Button(0, 0, 200, 50));
  columm.widgets.add(Button(0, 0, 200, 50));

  columm.mount();

  while(!Window.ShouldClose())
  {
    Draw.RenderFrame(renderLogic: DrawScreen);
  }

  Window.Close();
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal()) {
    columm.mainAxis = HayYAxisAlign.LEFT;
    columm.horizontalAxis = HayXAxisAlign.CENTER;
    columm.width = 500;
    columm.height = 500;
    columm.x = (winWidth - 500) / 2;

    columm.mount();
  }

  columm.draw();
}
