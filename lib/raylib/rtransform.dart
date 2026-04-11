part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Transform
//------------------------------------------------------------------------------------

class Transform implements Disposeable
{
  NativeResource<_Transform>? _memory;
  final int _length;
  int get length => _length;

  _Transform get ref => _memory!.pointer.ref;
  set ref (_Transform value) => _memory!.pointer.ref = value;

  late final Vector3 translation;
  late final Quaternion rotation;
  late final Vector3 scale;

  // ignore: unused_element
  void _setmemory(_Transform result)
  {
    Pointer<_Transform> pointer = malloc.allocate<_Transform>(sizeOf<_Transform>());
    pointer.ref = result;

    _memory = NativeResource<_Transform>(pointer);
    _finalizer.attach(this, pointer, detach: this);
    _setReferences(pointer);
  }

  void _setReferences(Pointer<_Transform> pointer) {
    int address = pointer.address;
    this.translation = Vector3._internal(.fromAddress(address), owner: false);

    address += sizeOf<_Vector3>();
    this.rotation = Quaternion._internal(.fromAddress(address), owner: false);

    address += sizeOf<_Quaternion>();
    this.scale = Vector3._internal(.fromAddress(address), owner: false);
  }

  Transform._internal(Pointer<_Transform> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (pointer.IsNull()) throw ArgumentError("[Target]: The loaded Transform is NULL!");
    if (_memory != null) Dispose();
    _memory = NativeResource<_Transform>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);

    _setReferences(pointer);
  }

  Transform(Vector3 translation, Quaternion rotation, Vector3 scale) : _length = 1
  {
    Pointer<_Transform> pointer = malloc.allocate<_Transform>(sizeOf<_Transform>());
    pointer.ref
    ..translation = translation.ref
    ..rotation = rotation.ref
    ..scale = scale.ref;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Transform>(pointer);

    _setReferences(pointer);
  }

  Transform operator [](int index)
  {
    if (index < 0 || index >= length) throw RangeError(index);
    return Transform._internal(_memory!.pointer + index, owner: false);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Transform>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.Dispose();
    }
  }
}
