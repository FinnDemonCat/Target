import 'dart:math' as math;
import 'package:target_engine/haybale/haybale.dart';

class Slider extends IInteractible
{
  Texture? barTexture;
  late Rectangle barRect;
  Texture? sliderTexture;
  late Rectangle sliderRect;
  int divisions;

  final void Function(double value) _OnSet;

  double _value;
  double get value => _value;
  set value (double value) {
    if (divisions == 1) {
      _value = value.clamp(0.0, 1.0);
    }
    else {
      double division = barRect.width / divisions;
      var values = List.generate(divisions, (int index) => division * index);

      for (int x = 0; x < values.length; x++)
        values[x] = (values[x] -= value).abs();
      
      division = values.fold(0.0, (x, y) => x = math.min(x, y));

      _value = division;
    }
  }

  @override Rectangle get interactArea => sliderRect;

  Slider({
    required super.sizing,
    void Function(double)? OnSet,
    super.cursor = .POINTING_HAND,
    Texture? barTexture,
    Texture? sliderTexture,
    this.divisions = 1
  }) : 
    _OnSet = OnSet ?? ((value) {}),
    _value = 0.0
  {
    if (sliderTexture != null) {
      sliderRect = Rectangle(
        0, 0,
        sliderTexture.width.toDouble(),
        sliderTexture.heigth.toDouble()
      );
    }

    if (barTexture != null) {
      barRect = Rectangle(
        0, 0,
        barTexture.width.toDouble(),
        barTexture.heigth.toDouble()
      );
    }
  }
  
  @override
  void Mount() {
    if (sliderTexture == null)
      sliderRect = Rectangle(0, 0, 10.0, height);
    if (barTexture == null)
      barRect = Rectangle(0, 0, width, height);
  }

  @override
  void DrawWidget() {
    if (state == InteractState.Pressed) {
      value = (Mouse.GetX() - x) / barRect.width;
      _OnSet.call(value);
    }
    
    if (barTexture != null) {
      var src = Rectangle(0, 0, barTexture!.width.toDouble(), barTexture!.heigth.toDouble());
      Texture2D.DrawPro(barTexture!, src, barRect);
    }
    else {
      barRect.Set(x: x, y: y);
      Shapes.DrawRectanglePro(barRect, Vector2.Zero(), color: .DARKGRAY);
    }

    if (sliderTexture != null) {
      sliderRect.Set(y: y * switch (state) { .Selected => 2, .Pressed => 3, _ => 1 }, width: sliderTexture!.width.toDouble(), height: sliderRect.height.toDouble());
      sliderRect.Set(x: x + (width * value), y: y + (sliderTexture!.heigth / 2));
      Texture2D.DrawPro(sliderTexture!, sliderRect, sliderRect);
    }
    else {
      sliderRect.Set(x: x + (width * value) - 5, y: y);
      Shapes.DrawRectanglePro(sliderRect, Vector2.Zero(), color: switch (state) { .Idle => .GRAY, .Selected => .LIGHTGRAY, .Pressed => .SKYBLUE });
    }
  }

  @override
  void Free() {
    barTexture?.Free();
    sliderTexture?.Free();
    sliderRect.Free();
    super.Free();
  }
}