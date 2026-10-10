// ignore: avoid_relative_lib_imports
import '../lib/haybale/haybale.dart';
/* 
class Button extends IInteractible {
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
    super.cursor,
  }) {
    if (buttonTexture != null)
      buttonRect = Rectangle(
        0.0,
        0.0,
        buttonTexture!.width.toDouble(),
        buttonTexture!.height.toDouble(),
      );
  }

  @override
  void Mount() {
    if (buttonTexture == null) buttonRect = Rectangle(0.0, 0.0, width, height);

    text.SetSizing(width, height);
    text.Mount();
    text.Set(
      x: x + (width - text.width) / 2,
      y: y + (height - text.fontSize) / 2,
    );
    super.Mount();
  }

  @override
  void DrawWidget() {
    if (buttonTexture != null) {
      var src = Rectangle(
        0.0,
        0.0,
        buttonTexture!.width.toDouble(),
        buttonTexture!.height.toDouble(),
      );
      Texture.DrawPro(buttonTexture!, src, interactArea);
      src.Free();
    } else {
      Shapes.DrawRectangleRounded(
        this,
        0.1,
        1,
        color: state == .Pressed ? .LIGHTGRAY : .GRAY,
      );
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
*/

/// Defines the border sizes used by a nine-patch button texture.
typedef NPatchConfig = ({int top, int left, int right, int bottom});

/// An interactive button that can display a widget and a state texture.
///
/// A [buttonTexture] is expected to contain three vertically stacked images:
/// the normal, selected, and pressed appearances, in that order.
class Button extends IInteractible {
  /// The optional widget displayed inside this button.
  final Widget? widget;

  /// The optional texture used to draw the button's interaction states.
  final Texture? buttonTexture;

  /// Nine-patch settings for [buttonTexture], when the texture is valid.
  late final NPatchInfo nPatchInfo;

  final int? heightSlice;

  /// Creates a button with the given interaction [sizing].
  ///
  /// [widget] is positioned and sized to the button when it is mounted.
  /// [nPatchConfig] and [nPatchLayout] configure the nine-patch settings.
  Button({
    required super.sizing,
    super.OnPress,
    super.OnFocus,
    super.OnUnfocus,
    super.OnSelect,
    super.cursor,
    this.buttonTexture,
    this.heightSlice,
    required Widget child,
    NPatchConfig nPatchConfig = (top: 0, left: 0, right: 0, bottom: 0),
    NPatchLayout nPatchLayout = .NPATCH_NINE_PATCH,
  }) : this.widget = child {
    if (buttonTexture != null &&
        heightSlice != null &&
        buttonTexture!.height % heightSlice! == 0) {
      var source = Rectangle(0.0, 0.0, buttonTexture!.width, heightSlice!);

      nPatchInfo = NPatchInfo(
        source: source,
        left: nPatchConfig.left,
        top: nPatchConfig.top,
        right: nPatchConfig.right,
        bottom: nPatchConfig.bottom,
        layout: nPatchLayout,
      );

      source.Free();
    }
  }

  @override
  void Mount() {
    widget?.Set(x: x, y: y);
    widget?.SetSizing(width, height);
    widget?.Mount();
  }

  @override
  void DrawWidget() {
    if (buttonTexture != null && heightSlice != null) {
      var source = Rectangle(0.0, 0.0, buttonTexture!.width, heightSlice!);

      switch (state) {
        case InteractState.Selected:
          source.y = heightSlice!;
          break;
        case InteractState.Pressed:
          source.y = heightSlice! * 2;
          break;
        default:
          break;
      }

      Texture.DrawPro(buttonTexture!, source, this);

      source.Free();
    }

    widget?.DrawWidget();
  }

  @override
  void Free() {
    widget?.Free();
    buttonTexture?.Free();
    super.Free();
  }
}
