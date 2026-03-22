import '../libs/raylib/raylib.dart';
import 'haybale.dart';
import 'custom_widgets.dart';

bool ListenTerminal() {
  if (Key.IsDown(Keyboard.KEY_LEFT_CONTROL))
    if (Key.IsPressed(Keyboard.KEY_R))
      return true;
  else;
    return false;
} 

int winWidth = 800;
int winHeight = 800;

Widget PageOne() {
  return Canvas(
    children: [
      Column(
        sizing: .Grow(),
        mainAxis: .CENTER,
        crossAxis: .CENTER,
        children: [
          Column(
            sizing: HaySize(width: 400, height: 100),
            spacing: 10.0,
            children: [
              Button(
                sizing: .FullWidth(height: 75.0),
                OnPress: () {
                  page.PutPage('home/');
                },
              ),
              TextBox(
                font: Font.Default(),
                text: TextCodepoint.fromString("This is Page 1"),
                textAlign: .LEFT,
                fontSize: 32.0,
                spacing: 0.0
              ),
            ]
          )
        ]
      )
    ]
  );
}

Widget PageTwo() {
  return Canvas(
    children: [
      Column(
        sizing: .Grow(),
        mainAxis: .CENTER,
        crossAxis: .CENTER,
        children: [
          Column(
            sizing: HaySize(width: 400, height: 100),
            spacing: 10.0,
            children: [
              Button(
                sizing: .FullWidth(height: 75.0),
                OnPress: () {
                  page.PutPage('home/');
                },
              ),
              TextBox(
                font: Font.Default(),
                text: TextCodepoint.fromString("This is Page 2"),
                textAlign: .LEFT,
                fontSize: 32.0,
                spacing: 0.0
              ),
            ]
          )
        ]
      )
    ]
  );
}

Widget Main() {
  return Canvas(
    children: [
      ListView(
        sizing: .Grow(),
        spacing: 5.0,
        sensitivity: 10.0,
        padding: .All(10.0),
        // cellSize: Vector2(75, 75),
        children: [
          Button(
            sizing: .FullWidth(height: 75.0),
            OnPress: () {
              page.PutPage("Page1/");
            },
          ),
          Button(
            sizing: .FullWidth(height: 75.0),
            OnPress: () {
              page.PutPage("Page2/");
            },
          ),
        ],  
      )
    ]
  );
}

Page page = Page(page: Main);

void main()
{
  Window.SetFlags(resizable: true);
  Window.Init(width: winWidth, height: winHeight, title: "Dart Test");
  Frame.SetTargetFPS(30);

  // canvas.Mount();
  page.routes["Page1/"] = PageOne;
  page.routes["Page2/"] = PageTwo;
  page.Mount();

  while(!Window.ShouldClose())
  {
    Draw.RenderFrame(renderLogic: DrawScreen);
  }

  // canvas.Dispose();
  Button.texture.Dispose();
  Window.Close();
}

void DrawScreen()
{
  Draw.ClearBackground(Color.GOLD);
  if (ListenTerminal() || Window.IsResized()) {
    page.Mount();
    // canvas.Mount();
  }

  page.DrawWidget();
  // canvas.DrawWidget();
} 
