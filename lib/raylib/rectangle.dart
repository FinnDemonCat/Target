part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                  Rectangle
//------------------------------------------------------------------------------------

/// Rectangle, 4 components
class Rectangle implements Disposeable
{
  NativeResource<_Rectangle>? _memory;
  final int _length;
  int get length => _length;

  _Rectangle get ref => _memory!.pointer.ref;
  double get x => _memory!.pointer.ref.x;
  double get y => _memory!.pointer.ref.y;
  double get width => _memory!.pointer.ref.width;
  double get height => _memory!.pointer.ref.height;

  set x(double value) => _memory!.pointer.ref.x = value;
  set y(double value) => _memory!.pointer.ref.y = value;
  set width(double value)  => _memory!.pointer.ref.width  = value;
  set height(double value) => _memory!.pointer.ref.height = value;

  void Set({double? x, double? y, double? width, double? height})
  {
    this.x = x ?? this.x;
    this.y = y ?? this.y;
    this.width = width ?? this.width;
    this.height = height ?? this.height;
  }

  // ignore: unused_element
  void _setMemory(_Rectangle result)
  {
    if (_memory != null) _memory!.Dispose();

    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  // ignore: unused_element
  Rectangle._internal(Pointer<_Rectangle> pointer,{ bool owner = true, int length = 1 }) : _length = length
  {
    if (pointer.IsNull()) throw ArgumentError("[Target]: The loaded Rectangle is NULL!");
    if (_memory != null) Dispose();

    _memory = NativeResource<_Rectangle>(pointer, IsOwner: owner);
    if (owner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Rectangle._recieve(_Rectangle result) : _length = 1
  {
    _setMemory(result);
  }

  Rectangle([double x = 0.0, double y = 0.0, double width = 0.0, double height = 0.0]) : _length = 1
  {
    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref
    ..x = x
    ..y = y
    ..width = width
    ..height = height;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  Rectangle operator [](int index)
  {
    if (index < 0 || index >= _length) throw RangeError(index);
    return Rectangle._internal(_memory!.pointer + index, owner: false);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Rectangle>>((pointer)
  {
    malloc.free(pointer);
  });
  
  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.Dispose();
    }
  }
}
