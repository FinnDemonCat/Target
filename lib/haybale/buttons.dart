import 'package:target_engine/raylib/raylib.dart';
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
    text.SetSizing(width, height);
    text.Mount();
    text.Set(x: x + (width - text.width) / 2, y: y + (height - text.fontSize) / 2);
    super.Mount();
  }

  @override
  void DrawWidget() {
    Shapes.DrawRectangleRounded(this, 0.1, 1, color: state == .Pressed ? .LIGHTGRAY : .GRAY);
    // Shapes.DrawRectangleLinesEx(text, 1);
    text.DrawWidget();
    super.DrawWidget();
  }
}