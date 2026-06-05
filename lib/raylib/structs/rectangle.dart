part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                  Rectangle
//------------------------------------------------------------------------------------

/// Rectangle, 4 components
class Rectangle extends NativeWrapper<_Rectangle>
{
  // NativeWrapper<_Rectangle>? _memory;

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

  void Set({double? x, double? y, double? width, double? height}) {
    this.x = x ?? this.x;
    this.y = y ?? this.y;
    this.width = width ?? this.width;
    this.height = height ?? this.height;
  }

  // ignore: unused_element
  /* void _setMemory(_Rectangle result)
  {
    if (_memory != null) _memory!.Free();

    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeWrapper<_Rectangle>(pointer);
  } */

  // ignore: unused_element_parameter
  Rectangle._Encapsulate(super.pointer,{ super.length }) : super.fromAddress() {
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Rectangle._Recieve(_Rectangle result) : super(sizeOf<_Rectangle>()) {
    ref = result;
    _finalizer.attach(this, pointer, detach: this);
  }

  Rectangle([double x = 0.0, double y = 0.0, double width = 0.0, double height = 0.0]) : super(sizeOf<_Rectangle>()) {
    ref
      ..x = x
      ..y = y
      ..width = width
      ..height = height;

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
