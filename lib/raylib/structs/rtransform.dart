part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Transform
//------------------------------------------------------------------------------------

// typedef _FreeTransformC    = Void Function(Pointer<Void> token);
// typedef _FreeTransformDart = void Function(Pointer<Void> token);
// final _freeTransform = _dyReleaseLib.lookup<NativeFunction<_FreeTransformC>>('FreeTransform');

/// Transform, vertex transformation data
class Transform extends NativeWrapper<_Transform> implements Finalizable {
  _Transform get ref => pointer.ref;
  set ref (_Transform value) => pointer.ref = value;

	/// Translation
  late final Vector3 _translation;
  Vector3 get translation => _translation;
  set translation(Vector3 value) => _translation.ref = value.ref;

	/// Rotation
  late final Quaternion _rotation;
  Quaternion get rotation => _rotation;
  set rotation(Quaternion value) => _rotation.ref = value.ref;

	/// Scale
  late final Vector3 _scale;
  Vector3 get scale => _scale;
  set scale(Vector3 value) => _scale.ref = value.ref;

  void _setReferences() {
    int address = pointer.address;
    this._translation = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    this._rotation = Quaternion._Encapsulate(.fromAddress(address));

    address += sizeOf<_Quaternion>();
    this._scale = Vector3._Encapsulate(.fromAddress(address));
  }

	// ignore: unused_element_parameter, unused_element
  Transform._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
		if (IsOwner)
			_finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ignore: unused_element_parameter, unused_element
  Transform._Recieve(_Transform result) : super(sizeOf<_Transform>()) {
    ref = result;
    _setReferences();
		_finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ==================================== Constructor =====================================

  Transform(Vector3 translation, Quaternion rotation, Vector3 scale,[ RaylibArena? arena ]) : super(sizeOf<_Transform>(), arena: arena) {
    ref
      ..translation = translation.ref
      ..rotation = rotation.ref
      ..scale = scale.ref;

    _setReferences();
		_finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ===================================== Operators ======================================

	Transform operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return Transform._Encapsulate(pointer + index, IsOwner: false);
	}

	void operator[]=(Transform value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<Transform> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	} 

	// =================================== Deconstructor ====================================

	static final _finalizer = Finalizer<Pointer<_Transform>>((token) {
    malloc.free(token);
  });

	@override
	void Free() {
		_finalizer.detach(this);
		super.Free();
	}
}
