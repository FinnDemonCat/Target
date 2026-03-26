import '../libs/raylib/raylib.dart';
import 'haybale.dart';

class Button extends Interactible
{
  TextBox text;
  
  Button({
    required super.sizing,
    required this.text,
    super.OnPress,
  });

  @override
  void Mount() {
    text.Mount();
    text.Set(x: (width - text.width) / 2, y: (height - text.height) / 2);
    super.Mount();
  }

  @override
  void DrawWidget() {
    text.DrawWidget();
    Shapes.DrawRectangleRounded(this, 0.125, 1, color: state == .Pressed ? .LIGHTGRAY : .GRAY);
    super.DrawWidget();
  }
}