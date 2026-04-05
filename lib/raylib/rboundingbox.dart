part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                 BoundingBox
//------------------------------------------------------------------------------------

class BoundingBox implements Disposeable
{
  NativeResource<_BoundingBox>? _memory;

  _BoundingBox get ref => _memory!.pointer.ref;
  // _Vector3 get min => ref.min;
  // _Vector3 get max => ref.max;

  late final Vector3 min;
  late final Vector3 max;

  void _setReferences(Pointer<_BoundingBox> pointer) {
    int address = _memory!.pointer.address;
    min = Vector3._internal(.fromAddress(address));
    
    address += sizeOf<_Vector3>();
    max = Vector3._internal(.fromAddress(address));
  }

  BoundingBox(Vector3 min, Vector3 max) {
    Pointer<_BoundingBox> pointer = malloc.allocate<_BoundingBox>(sizeOf<_BoundingBox>());
    pointer.ref
    ..min = min.ref
    ..max = max.ref;

    _finalizer.attach(this, pointer, detach: this);

    _setReferences(pointer);
  }

  BoundingBox._internal(_BoundingBox result)
  {
    Pointer<_BoundingBox> pointer = malloc.allocate<_BoundingBox>(sizeOf<_BoundingBox>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);

    _setReferences(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_BoundingBox>>((pointer) {
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
