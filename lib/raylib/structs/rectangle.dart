part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                  Rectangle
//------------------------------------------------------------------------------------

// typedef _FreeRectangleC    = Void Function(Pointer<Void> token);
// typedef _FreeRectangleDart = void Function(Pointer<Void> token);
// final _freeRectangle = _dyReleaseLib.lookup<NativeFunction<_FreeRectangleC>>('FreeRectangle');

/// Rectangle, 4 components
class Rectangle extends NativeWrapper<_Rectangle> implements Finalizable {
  _Rectangle get ref => pointer.ref;
  set ref(_Rectangle value) => pointer.ref = value;

	/// Rectangle top-left corner position x
	double get x => ref.x;
	/// Rectangle top-left corner position y
	double get y => ref.y;
	/// Rectangle width
	double get width => ref.width;
	/// Rectangle height
	double get height => ref.height;

	set x(num value) => ref.x = value.toDouble();
	set y(num value) => ref.y = value.toDouble();
	set width(num value) => ref.width = value.toDouble();
	set height(num value) => ref.height = value.toDouble();

	// ignore: unused_element_parameter, unused_element
	Rectangle._Encapsulate(super.pointer,{ super.IsOwner, super.length }): super.fromAddress() {
		if (IsOwner)
			_finalizer.attach(this, pointer.cast(), detach: this);
	}

	// ignore: unused_element_parameter, unused_element
	Rectangle._Recieve(_Rectangle result): super(sizeOf<_Rectangle>()) {
		ref = result;
		_finalizer.attach(this, pointer.cast(), detach: this);
	}

  void Set({num? x, num? y, num? width, num? height}) {
    this.x = x ?? this.x;
    this.y = y ?? this.y;
    this.width = width ?? this.width;
    this.height = height ?? this.height;
  }

	// ==================================== Constructor =====================================
  
  Rectangle([num x = 0.0, num y = 0.0, num width = 0.0, num height = 0.0, RaylibArena? arena]) : super(sizeOf<_Rectangle>(), arena: arena) {
    ref
      ..x = x.toDouble()
      ..y = y.toDouble()
      ..width = width.toDouble()
      ..height = height.toDouble();

	  _finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ===================================== Operators ======================================

	Rectangle operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return Rectangle._Encapsulate(pointer + index, IsOwner: false);
	}

	void operator[]=(Rectangle value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<Rectangle> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	}

	// =================================== Deconstructor ====================================

	static final _finalizer = Finalizer<Pointer<_Rectangle>>((token) {
		malloc.free(token);
	});
	  
  @override
  void Free() {
		_finalizer.detach(this);
		super.Free();
  }
}
