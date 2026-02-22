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
  double get width => _memory!.pointer.ref.width;
  double get height => _memory!.pointer.ref.height;
  double get x => _memory!.pointer.ref.x;
  double get y => _memory!.pointer.ref.y;

  set width(double value)  => _memory!.pointer.ref.width  = value.abs().roundToDouble();
  set height(double value) => _memory!.pointer.ref.height = value.abs().roundToDouble();
  set x(double value) => _memory!.pointer.ref.x = value.abs().roundToDouble();
  set y(double value) => _memory!.pointer.ref.y = value.abs().roundToDouble();

  // ignore: unused_element
  void _setMemory(_Rectangle result)
  {
    if (_memory != null) _memory!.dispose();

    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  // ignore: unused_element
  Rectangle._internal(Pointer<_Rectangle> pointer,{ bool owner = true, int length = 1 }) : _length = length
  {
    if (_memory != null) dispose();

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
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}
