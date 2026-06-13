part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                  Rectangle
//------------------------------------------------------------------------------------

/// Rectangle, 4 components
class Rectangle extends NativeWrapper<_Rectangle> {
  _Rectangle get ref => pointer.ref;
  set ref(_Rectangle value) => pointer.ref = value;
  double get x => pointer.ref.x;
  double get y => pointer.ref.y;
  double get width => pointer.ref.width;
  double get height => pointer.ref.height;

  set x(double value) => pointer.ref.x = value;
  set y(double value) => pointer.ref.y = value;
  set width(double value)  => pointer.ref.width  = value;
  set height(double value) => pointer.ref.height = value;

  void Set({num? x, num? y, num? width, num? height}) {
    this.x = x?.toDouble() ?? this.x;
    this.y = y?.toDouble() ?? this.y;
    this.width = width?.toDouble() ?? this.width;
    this.height = height?.toDouble() ?? this.height;
  }

  // ignore: unused_element_parameter
  Rectangle._Encapsulate(super.pointer,{ super.length }) : super.fromAddress() {
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Rectangle._Recieve(_Rectangle result) : super(sizeOf<_Rectangle>()) {
    ref = result;
    _finalizer.attach(this, pointer, detach: this);
  }

  Rectangle([num x = 0.0, num y = 0.0, num width = 0.0, num height = 0.0, RaylibArena? arena]) : super(sizeOf<_Rectangle>(), arena: arena) {
    ref
      ..x = x.toDouble()
      ..y = y.toDouble()
      ..width = width.toDouble()
      ..height = height.toDouble();

    _finalizer.attach(this, pointer, detach: this);
  }

  Rectangle operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return Rectangle._Encapsulate(pointer + index);
  }

  void operator []=(Rectangle value, int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<NativeWrapper<_Rectangle>> get values sync* {
    for (int x = 0; x < length; x++)
      yield this[x];
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Rectangle>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}
