import '../libs/raylib.dart';

void main()
{
  Window.Init(width: 800, height: 800, title: "Dart Test");
  Frame.SetTargetFPS(30);
  Window.SetState(WinFlags.WINDOW_TOPMOST);  

  while(!Window.ShouldClose())
  {
    Update();
  }
}

void Update()
{
  Draw.Begin();
  Draw.ClearBackground(Color.GREEN);
  Draw.End();
}
