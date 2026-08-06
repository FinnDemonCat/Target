part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                 BoundingBox
//------------------------------------------------------------------------------------

// typedef _FreeBoundingBoxC    = Void Function(Pointer<Void> token);
// typedef _FreeBoundingBoxDart = void Function(Pointer<Void> token);
// final _freeBoundingBox = _dyReleaseLib.lookup<NativeFunction<_FreeBoundingBoxC>>('FreeBoundingBox');

/// BoundingBox
class BoundingBox extends NativeWrapper<_BoundingBox> implements Finalizable {
  _BoundingBox get ref => pointer.ref;
  set ref (_BoundingBox value) => pointer.ref = value;

  late final Vector3 _min;
	/// Minimum vertex box-corner
  Vector3 get min => _min;
  set min(Vector3 value) => _min.ref = value.ref;

  late final Vector3 _max;
	/// Maximum vertex box-corner
  Vector3 get max => _max;
  set max(Vector3 value) => _max.ref = value.ref;

  void _setReferences(Pointer<_BoundingBox> pointer) {
    int address = pointer.address;
    _min = Vector3._Encapsulate(.fromAddress(address));
    
    address += sizeOf<_Vector3>();
    _max = Vector3._Encapsulate(.fromAddress(address));
  }

	// ignore: unused_element_parameter, unused_element
	BoundingBox._Encapsulate(super.pointer,{ super.IsOwner, super.length }): super.fromAddress() {
    _setReferences(pointer);
		if (IsOwner)
			_finalizer.attach(this, pointer.cast(), detach: this);
	}

	// ignore: unused_element_parameter, unused_element
	BoundingBox._Recieve(_BoundingBox result): super(sizeOf<_BoundingBox>()) {
		ref = result;
    _setReferences(pointer);
		_finalizer.attach(this, pointer.cast(), detach: this);
	}
  
  BoundingBox(Vector3 min, Vector3 max,{ super.arena }) : super(sizeOf<_BoundingBox>()) {
    ref
      ..min = min.ref
      ..max = max.ref;

		_finalizer.attach(this, pointer.cast(), detach: this);
    _setReferences(pointer);
  }

  // ===================================== Operators ======================================

	BoundingBox operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return BoundingBox._Encapsulate(pointer + index, IsOwner: false);
	}

	void operator[]=(BoundingBox value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<BoundingBox> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	}
  
	// =================================== Deconstructor ====================================

	static final _finalizer = Finalizer<Pointer<_BoundingBox>>((token) {
		malloc.free(token);
	});

	@override
	void Free() {
		_finalizer.detach(this);
		super.Free();
	}
}
