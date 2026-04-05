// ignore_for_file: unused_import

import 'package:target_engine/raylib/raylib.dart';
import 'package:target_engine/haybale/haybale.dart';
import 'package:target_engine/haybale/buttons.dart';

bool ListenTerminal() {
  if (Keyboard.IsDown(Key.LEFT_CONTROL))
    if (Keyboard.IsPressed(Key.R))
      return true;
  
  return false;
}

Widget PageOne() {
  return Canvas(
    sizing: .Grow(),
    child: Center(
      sizing: .Grow(),
      widget: Column(
        sizing: .FullHeight(width: 400),
        spacing: 5.0,
        mainAxis: .CENTER,
        crossAxis: .CENTER,
        children: [
          Button(
            sizing: .FullWidth(height: 75.0),
            text: TextBox(
              text: "This is Page 1",
              fontSize: 48.0,
              textAlign: .CENTER,
            )
          ),
          Button(
            sizing: .FullWidth(height: 75.0),
            text: TextBox(
              text: "Return",
              fontSize: 48.0,
              textAlign: .CENTER,
            ),
            OnPress: () => Router.PopPage(),
          )
        ]
      ),
    )
  );
}

Widget PageTwo() {
  return Canvas(
    sizing: .Grow(),
    child: Center(
      sizing: .Grow(),
      widget: Column(
        sizing: .FullHeight(width: 400),
        spacing: 5.0,
        mainAxis: .CENTER,
        crossAxis: .CENTER,
        children: [
          Button(
            sizing: .FullWidth(height: 75.0),
            text: TextBox(
              text: "This is Page 2",
              fontSize: 48.0,
              textAlign: .CENTER,
            )
          ),
          Button(
            sizing: .FullWidth(height: 75.0),
            text: TextBox(
              text: "Return",
              fontSize: 48.0,
              textAlign: .CENTER,
            ),
            OnPress: () => Router.PopPage(),
          )
        ]
      ),
    )
  );
}

Widget HomePage() {
  return Canvas(
    sizing: .Grow(),
    child: Center(
      sizing: .Grow(),
      widget: Column(
        sizing: .FullHeight(width: 400),
        spacing: 5.0,
        mainAxis: .CENTER,
        crossAxis: .CENTER,
        children: [
          Button(
            sizing: .FullWidth(height: 75.0),
            text: TextBox(
              text: "Go To Page 1",
              fontSize: 48.0,
              textAlign: .CENTER,
            ),
            OnPress: () => Router.PushPage('Page1/'),
          ),
          Button(
            sizing: .FullWidth(height: 75.0),
            text: TextBox(
              text: "Go To Page 2",
              fontSize: 48.0,
              textAlign: .CENTER,
            ),
            OnPress: () => Router.PushPage('Page2/'),
          )
        ]
      )
    )
  );
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    
    Router.Update();
  }

  Router.DrawPage();
}

// Canvas Should be a single child widget which only manages the intermidiate draw buffer
// Page widget should have static members to allow push/pop method calls from anywhere on the code

void main()
{
  Window.SetFlags(resizable: true);
  Window.Init(width: 1280, height: 720, title: "Haybale Test");
  Frame.SetTargetFPS(30);

  Router.Init(
    HomePage, {
      'Page1/': PageOne,
      'Page2/': PageTwo
    }
  );

  while(!Window.ShouldClose())
  {
    Draw.WithDefault(renderLogic: DrawScreen);
  }

  // canvas.Dispose();
  Router.Release();
  Window.Close();
}
