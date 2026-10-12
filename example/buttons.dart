import 'dart:math' as math;
// ignore: avoid_relative_lib_imports
import '../lib/native_wrapper/native_wrapper.dart';
// ignore: avoid_relative_lib_imports
import '../lib/haybale/haybale.dart';

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
    NPatchConfig nPatchConfig = const NPatchConfig.none(),
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

/// A horizontal slider interactible widget with optional textures.
///
/// Slider can render an optional bar texture and an optional thumb (slider)
/// texture. It supports an arbitrary number of discrete [divisions] (1 means
/// continuous) and calls a provided callback when the value changes.
///
/// Untested update
class Slider extends IInteractible {
  /// Optional texture used as the slider bar background.
  late final Texture? barTexture;

  /// Rectangle representing the bar geometry.
  late final Rectangle barRect;

  /// Optional texture used for the slider thumb.
  late final Texture? sliderTexture;

  /// Rectangle representing the thumb geometry.
  late final Rectangle sliderRect;

  /// Number of discrete divisions. When `divisions == 1`, the slider is continuous.
  final int divisions;

  /// Callback invoked when the slider's value is set (typically during press).
  final void Function(double value) _OnSetValue;

  @override
  Rectangle get interactArea => sliderRect;

  double _value;

  /// Current slider value.
  ///
  /// - For a continuous slider (divisions == 1), `value` is clamped to [0.0, 1.0].
  /// - For discrete sliders (divisions > 1), the setter attempts to snap the
  ///   value to the nearest division along the bar width.
  double get value => _value;
  set value(double value) {
    if (divisions == 1) {
      _value = value.clamp(0.0, 1.0);
    } else {
      double division = barRect.width / divisions;
      var values = List.generate(divisions, (int index) => division * index);

      for (int x = 0; x < values.length; x++)
        values[x] = (values[x] -= value).abs();

      division = values.fold(0.0, (x, y) => x = math.min(x, y));

      _value = division;
    }
  }

  /// Creates a Slider.
  ///
  /// Parameters:
  /// - [sizing]: required sizing behavior for the slider (width/height control).
  /// - [OnSet]: optional callback invoked when the slider value changes.
  /// - [cursor]: pointer cursor while hovering the widget (defaults to `.POINTING_HAND`).
  /// - [barTexture]: optional texture used to draw the bar.
  /// - [sliderTexture]: optional texture used to draw the thumb.
  /// - [divisions]: number of discrete positions (1 = continuous).
  Slider({
    required super.sizing,
    void Function(double)? OnSet,
    super.cursor = .POINTING_HAND,
    this.barTexture,
    this.sliderTexture,
    this.divisions = 1,
  }) : _OnSetValue = OnSet ?? ((value) {}),
       _value = 0.0 {
    if (sliderTexture != null) {
      sliderRect = Rectangle(0, 0, sliderTexture!.width, sliderTexture!.height);
    }

    if (barTexture != null) {
      barRect = Rectangle(0, 0, barTexture!.width, barTexture!.height);
    }
  }

  @override
  void Mount() {
    if (sliderTexture == null) sliderRect = Rectangle(0, 0, 10.0, height);
    if (barTexture == null) barRect = Rectangle(0, 0, width, height);
  }

  @override
  void DrawWidget() {
    rayCompute((arena) {
      if (state == InteractState.Pressed) {
        value = (Mouse.GetX() - x) / barRect.width;
        _OnSetValue.call(value);
      }

      if (barTexture != null) {
        var src = Rectangle(0, 0, barTexture!.width, barTexture!.height, arena);
        Texture2D.DrawPro(barTexture!, src, barRect);
      } else {
        barRect.Set(x: x, y: y);
        Shapes.DrawRectanglePro(barRect, Vector2.Zero(arena), color: .DARKGRAY);
      }

      if (sliderTexture != null) {
        sliderRect.Set(
          y: y * state.index,
          width: sliderTexture!.width,
          height: sliderRect.height,
        );
        sliderRect.Set(
          x: x + (width * value),
          y: y + (sliderTexture!.height / 2),
        );
        Texture2D.DrawPro(sliderTexture!, sliderRect, sliderRect);
      } else {
        sliderRect.Set(x: x + (width * value) - 5, y: y);
        Shapes.DrawRectanglePro(
          sliderRect,
          Vector2.Zero(arena),
          color: switch (state) {
            .Idle => .GRAY,
            .Selected => .LIGHTGRAY,
            .Pressed => .SKYBLUE,
          },
        );
      }
    });
  }

  @override
  void Free() {
    // barTexture?.Free();
    // sliderTexture?.Free();
    sliderRect.Free();
    super.Free();
  }
}

/// A simple single-child container that forwards layout, mounting and drawing.
///
/// Area does not apply extra visuals by itself — it only delegates to its child
/// widget. Use it when you need to wrap a widget and control sizing/position.
class Area extends Widget {
  /// Optional child widget.
  Widget? widget;

  /// Creates a Box that wraps [child].
  Area({required super.sizing, Widget? child}) : this.widget = child;

  @override
  void DrawWidget() => widget?.DrawWidget();

  @override
  void Mount() {
    widget?.SetSizing(width, height);
    widget?.Set(x: x, y: y);
    widget?.Mount();
  }

  @override
  void Free() {
    widget?.Free();
    super.Free();
  }
}

/// Empty widget that blocks the Free chain from reching its child widget
class Locked extends Widget {
  final Widget widget;

  @override
  double get x => widget.x;
  @override
  double get y => widget.y;
  @override
  double get width => widget.width;
  @override
  double get height => widget.height;

  @override
  set x(num value) => widget.x = value;
  @override
  set y(num value) => widget.y = value;
  @override
  set width(num value) => widget.width = value;
  @override
  set height(num value) => widget.height = value;

  @override
  Iterable<Widget> get children => [widget];

  Locked(Widget child) : widget = child, super(sizing: .Expand());

  @override
  void SetSizing([double width = 0.0, double height = 0.0]) =>
      widget.SetSizing(width, height);

  @override
  void Set({num? x, num? y, num? width, num? height}) =>
      widget.Set(x: x, y: y, width: width, height: height);

  @override
  void DrawWidget() => widget.DrawWidget();

  @override
  void Mount() {
    widget.Set(x: x, y: y);
    widget.SetSizing(width, height);
    widget.Mount();
  }

  @override
  // ignore: unnecessary_overrides
  void Free() => super.Free();
}

/// A lightweight widget that renders a single texture in its allocated area.
///
/// Picture is a simple wrapper around a `Texture` and a matching source
/// rectangle. It does not manage a child widget, does not allocate additional
/// render resources during `Mount()`, and simply draws the full texture using
/// the current widget bounds.
class Picture extends Widget {
  final Texture texture;
  late final Rectangle _textureRect;
  late final NPatchInfo _nPatchInfo;

  late final bool _useNpatch;
  Picture({
    required this.texture,
    NPatchConfig nPatchConfig = const NPatchConfig.none(),
    NPatchLayout nPatchLayout = NPatchLayout.NPATCH_NINE_PATCH,
  }) : super(sizing: .Expand()) {
    _textureRect = Rectangle(0.0, 0.0, texture.width, texture.height);
    _nPatchInfo = NPatchInfo(
      source: _textureRect,
      left: nPatchConfig.left,
      top: nPatchConfig.top,
      right: nPatchConfig.right,
      bottom: nPatchConfig.bottom,
      layout: nPatchLayout,
    );

    _useNpatch = nPatchConfig.NoNPatch();
  }

  @override
  void DrawWidget() {
    if (!_useNpatch) {
      Texture.DrawNPatch(texture, _nPatchInfo, this);
    } else {
      Texture.DrawPro(texture, _textureRect, this);
    }
  }

  @override
  void Mount() {}

  @override
  void Free() {
    _textureRect.Free();
    super.Free();
  }
}
