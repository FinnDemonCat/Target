part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                 BoundingBox
//------------------------------------------------------------------------------------

class BoundingBox extends NativeWrapper<_BoundingBox>
{
  _BoundingBox get ref => pointer.ref;
  set ref (_BoundingBox value) => pointer.ref = value;
  late final Vector3 min;
  late final Vector3 max;

  void _setReferences(Pointer<_BoundingBox> pointer) {
    int address = pointer.address;
    min = Vector3._Encapsulate(.fromAddress(address));
    
    address += sizeOf<_Vector3>();
    max = Vector3._Encapsulate(.fromAddress(address));
  }
  
  BoundingBox(Vector3 min, Vector3 max) : super(sizeOf<_BoundingBox>()) {
    ref
      ..min = min.ref
      ..max = max.ref;

    _finalizer.attach(this, pointer, detach: this);
    _setReferences(pointer);
  }

  BoundingBox._Recieve(_BoundingBox result) : super(sizeOf<_BoundingBox>()) {
    ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _setReferences(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_BoundingBox>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void Free() {
    max.Free();
    min.Free();
    _finalizer.detach(this);
    super.Free();
  }
}
