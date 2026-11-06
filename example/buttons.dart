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
  final Widget? widget;
  final Texture? texture;
  final NPatchConfig _nPatchConfig;
  final NPatchLayout _nPatchLayout;
  final bool stateful;
  late final int _heightSlice;
  // late final NPatchInfo? _nPatchInfo;

  final double _borderRadius;
  late final List<Color> _stateColors;

  Button({
    required super.sizing,
    this.texture,
    this.stateful = true,
    NPatchConfig nPatchConfig = const .none(),
    NPatchLayout nPatchLayout = .NPATCH_NINE_PATCH,
    Color? idleColor,
    Color? selectColor,
    Color? pressColor,
    double borderRadius = 0.0,
    super.OnPress,
    super.OnSelect,
    super.OnUnfocus,
    super.OnFocus,
    Widget? child,
  }) : widget = child,
       _borderRadius = borderRadius,
       _nPatchConfig = nPatchConfig,
       _nPatchLayout = nPatchLayout {
    _stateColors = [
      idleColor ?? Color.GRAY,
      selectColor ?? Color.LIGHTGRAY,
      pressColor ?? Color.SKYBLUE,
    ];

    if (texture == null) {
      _heightSlice = 0;
      // _nPatchInfo = null;
    } else {
      _heightSlice = (texture!.height % 3 == 0 && stateful)
          ? (texture!.height / 3).toInt()
          : texture!.height;
      /* 
      rayCompute((arena) {
        _nPatchInfo = NPatchInfo(
          source: Rectangle(0.0, 0.0, texture!.width, _heightSlice, arena),
          left: nPatchConfig.left,
          top: nPatchConfig.top,
          right: nPatchConfig.right,
          bottom: nPatchConfig.bottom,
          layout: nPatchLayout,
        );
      });
      */
    }
  }

  @override
  void Mount() {
    widget?.Set(x: x, y: y);
    widget?.SetSizing(width, height);
    widget?.Mount();
    super.Mount();
  }

  @override
  void Draw() {
    if (texture case Texture buttonTexture) {
      rayCompute((arena) {
        var npatchInfo = NPatchInfo(
          source: Rectangle(
            0.0,
            stateful ? state.index * _heightSlice : 0.0,
            buttonTexture.width,
            _heightSlice,
            arena,
          ),
          left: _nPatchConfig.left,
          top: _nPatchConfig.top,
          right: _nPatchConfig.right,
          bottom: _nPatchConfig.bottom,
          layout: _nPatchLayout,
          arena: arena,
        );

        Texture.DrawNPatch(buttonTexture, npatchInfo, this);
      });
    } else {
      Shapes.DrawRectangleRounded(
        this,
        _borderRadius,
        4,
        color: _stateColors[state.index],
      );
    }

    widget?.Draw();
  }

  @override
  void Free() {
    widget?.Free();
    // texture?.Free();
    // for (var color in _stateColors) color.Free();
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
    void Function(double value)? OnSet,
    super.cursor = .POINTING_HAND,
    this.barTexture,
    this.sliderTexture,
    this.divisions = 1,
  }) : _OnSetValue = OnSet ?? ((value) {}),
       _value = 0.0 {
    if (sliderTexture != null) {
      sliderRect = Rectangle(0, 0, sliderTexture!.width, sliderTexture!.height);
    } else {
      sliderRect = Rectangle(0, 0, 10.0, height);
    }

    if (barTexture != null) {
      barRect = Rectangle(0, 0, barTexture!.width, barTexture!.height);
    } else {
      barRect = Rectangle(0, 0, width, height);
    }
  }

  @override
  void Mount() {
    if (sliderTexture == null) {
      sliderRect.Set(x: 0, y: 0, width: 10.0, height: height);
    }
    if (barTexture == null) {
      barRect.Set(x: 0, y: 0, width: width, height: height);
    }
  }

  @override
  void Draw() {
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
        Shapes.DrawRectanglePro(barRect, Vector2.Zero(), color: .DARKGRAY);
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
          Vector2.Zero(),
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
  void Draw() => widget?.Draw();

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
  void Draw() => widget.Draw();

  @override
  void Mount() {
    widget
      ..Set(x: x, y: y)
      ..SetSizing(width, height)
      ..Mount();
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
  void Draw() {
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
