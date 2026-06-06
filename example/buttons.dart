import 'package:target_engine/haybale/haybale.dart';

class Button extends IInteractible
{
  Texture? buttonTexture;
  late Rectangle buttonRect;
  TextBox text;

  Button({
    required super.sizing,
    this.buttonTexture,
    required this.text,
    super.OnPress,
    super.OnFocus,
    super.OnUnfocus,
    super.OnSelect,
    super.cursor
  }) {
    if (buttonTexture != null)
      buttonRect = Rectangle(0.0, 0.0, buttonTexture!.width.toDouble(), buttonTexture!.heigth.toDouble());
  }

  @override
  void Mount() {
    if (buttonTexture == null)
      buttonRect = Rectangle(0.0, 0.0, width, height);

    text.SetSizing(width, height);
    text.Mount();
    text.Set(x: x + (width - text.width) / 2, y: y + (height - text.fontSize) / 2);
    super.Mount();
  }

  @override
  void DrawWidget() {
    if (buttonTexture != null) {
      var src = Rectangle(0.0, 0.0, buttonTexture!.width.toDouble(), buttonTexture!.heigth.toDouble());
      Texture.DrawPro(buttonTexture!, src, interactArea);
      src.Free();
    }
    else {
      Shapes.DrawRectangleRounded(this, 0.1, 1, color: state == .Pressed ? .LIGHTGRAY : .GRAY);
    }
    text.DrawWidget();
    super.DrawWidget();
  }

  @override
  void Free() {
    text.Free();
    buttonRect.Free();
    buttonTexture?.Free();
    super.Free();
  }
}