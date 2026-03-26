import '../libs/raylib/raylib.dart';
import 'haybale.dart';
import 'buttons.dart';

bool ListenTerminal() {
  if (Key.IsDown(Keyboard.KEY_LEFT_CONTROL))
    if (Key.IsPressed(Keyboard.KEY_R))
      return true;
  else;
    return false;
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    
  }

} 

void main()
{
  Window.SetFlags(resizable: true);
  Window.Init(width: 1280, height: 720, title: "Haybale Test");
  Frame.SetTargetFPS(30);

  while(!Window.ShouldClose())
  {
    Draw.WithDefault(renderLogic: DrawScreen);
  }

  // canvas.Dispose();
  Window.Close();
}
