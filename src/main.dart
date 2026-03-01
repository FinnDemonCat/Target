// ignore: unused_import
import 'package:ffigen/ffigen.dart';
import '../libs/raylib/raylib.dart';
import 'haybale.dart';

class Button extends Widget
{
  NPatchInfo nPatchInfo;
  Texture2D texture;

  Button({
    required double width,
    required double height,
    required Texture2D texture,
    required NPatchInfo nInfo
  }) :
    this.texture = texture,
    this.nPatchInfo = nInfo,
    super(width: width, height: height);
  
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

void main()
{
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Frame.SetTargetFPS(30);

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
  }
} 
