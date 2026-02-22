part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                 BoundingBox
//------------------------------------------------------------------------------------

class BoundingBox implements Disposeable
{
  NativeResource<_BoundingBox>? _memory;

  _BoundingBox get ref => _memory!.pointer.ref;
  _Vector3 get min => ref.min;
  _Vector3 get max => ref.max;

  BoundingBox._internal(_BoundingBox result)
  {
    Pointer<_BoundingBox> pointer = malloc.allocate<_BoundingBox>(sizeOf<_BoundingBox>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_BoundingBox>>((pointer) {
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
