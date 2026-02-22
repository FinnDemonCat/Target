part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Transform
//------------------------------------------------------------------------------------

class Transform implements Disposeable
{
  NativeResource<_Transform>? _memory;

  final int _length;
  int get length => _length;

  // ignore: unused_element
  void _setmemory(_Transform result)
  {
    Pointer<_Transform> pointer = malloc.allocate<_Transform>(sizeOf<_Transform>());
    pointer.ref = result;

    _memory = NativeResource<_Transform>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  Transform._internal(Pointer<_Transform> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) dispose();
    _memory = NativeResource<_Transform>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
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
  void dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}
