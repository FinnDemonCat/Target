part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Transform
//------------------------------------------------------------------------------------

class Transform extends NativeWrapper<_Transform> {
  _Transform get ref => pointer.ref;
  set ref (_Transform value) => pointer.ref = value;

  late final Vector3 translation;
  late final Quaternion rotation;
  late final Vector3 scale;

  // ignore: unused_element
  /* void _setmemory(_Transform result) {
    Pointer<_Transform> pointer = malloc.allocate<_Transform>(sizeOf<_Transform>());
    pointer.ref = result;

    _memory = NativeWrapper<_Transform>(pointer);
    _finalizer.attach(this, pointer, detach: this);
    _setReferences(pointer);
  } */

  void _setReferences() {
    int address = pointer.address;
    this.translation = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    this.rotation = Quaternion._Encapsulate(.fromAddress(address));

    address += sizeOf<_Quaternion>();
    this.scale = Vector3._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element
  Transform._Recieve(_Transform result) : super(sizeOf<_Transform>()) {
    ref = result;
    _setReferences();
    _finalizer.attach(this, pointer, detach: this);
  }

  // ignore: unused_element_parameter
  Transform._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Transform(Vector3 translation, Quaternion rotation, Vector3 scale) : super(sizeOf<_Transform>()) {
    ref
      ..translation = translation.ref
      ..rotation = rotation.ref
      ..scale = scale.ref;

    _setReferences();
    _finalizer.attach(this, pointer, detach: this);
  }

  Transform operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return Transform._Encapsulate(pointer + index);
  }

  void operator []=(Transform value, int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<Transform> get values sync* {
    for (int x = 0; x < length; x++)
      yield this[x];
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Transform>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}
