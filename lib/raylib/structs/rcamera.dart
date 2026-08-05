part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Camera
//------------------------------------------------------------------------------------

typedef _FreeCamera2DC    = Void Function(Pointer<Void> token);
// typedef _FreeCamera2DDart = void Function(Pointer<Void> token);
final _freeCamera2D = _dyReleaseLib.lookup<NativeFunction<_FreeCamera2DC>>('FreeCamera2D');

/// Camera2D, defines position/orientation in 2d space
class Camera2D extends NativeWrapper<_Camera2D> implements Finalizable {
  _Camera2D get ref => pointer.ref;
	set ref(_Camera2D value) => pointer.ref = value;

  double get rotation => ref.rotation;
  set rotation (double value) => ref.rotation = value;
  double get zoom => ref.zoom;
  set zoom (double value) => ref.zoom = value;

  late final Vector2 offset;
  late final Vector2 target;

	// ==================================== Constructor =====================================

  Camera2D({
    required Vector2 offset,
    required Vector2 target,
    double rotation = 0.0,
    double zoom = 1.0,
    super.arena
  }) : super(sizeOf<_Camera2D>()) {
    ref
    ..offset = offset.ref
    ..target = target.ref
    ..rotation = rotation
    ..zoom = zoom;

    int address = pointer.address;
    offset = Vector2._Encapsulate(.fromAddress(address));
    address += sizeOf<_Vector2>();
    target = Vector2._Encapsulate(.fromAddress(address));

    _nativeFinalizer.attach(this, pointer.cast(), detach: this);
  }

	// =================================== Deconstructor ====================================

	static final _nativeFinalizer = NativeFinalizer(_freeCamera2D);

	@override
	void Free() {
		_nativeFinalizer.detach(this);
		super.Free();
	}
}

typedef _FreeCameraC    = Void Function(Pointer<Void> token);
// typedef _FreeCameraDart = void Function(Pointer<Void> token);
final _freeCamera = _dyReleaseLib.lookup<NativeFunction<_FreeCameraC>>('FreeCamera');

/// Camera, defines position/orientation in 3d space
class Camera extends NativeWrapper<_Camera> implements Finalizable {
  _Camera get ref => pointer.ref;
	set ref(_Camera value) => pointer.ref = value;

  double get fovy => ref.fovy;
  set fovy(num value) => ref.fovy = (value > 0) ? value.toDouble() : 0.0;

  CameraProjection get projection => CameraProjection.values[ref.projection];
  set projection(CameraProjection value) => ref.projection = value.index;

  late final Vector3 position;
  late final Vector3 target;
  late final Vector3 up;

  Camera({
    required Vector3 pos,
    required Vector3 target,
    required Vector3 up,
    required double fovy,
    required CameraProjection projection,
    super.arena
  })
    : super(sizeOf<_Camera>())
  {
    pointer.ref
    ..position = pos.ref
    ..target = target.ref
    ..up = up.ref
    ..fovy = fovy
    ..projection = projection.index;

    int address = pointer.address;
    this.position = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    this.target = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    this.up = Vector3._Encapsulate(.fromAddress(address));

    _nativeFinalizer.attach(this, pointer.cast(), detach: this);
  }

	// =================================== Deconstructor ====================================

	static final _nativeFinalizer = NativeFinalizer(_freeCamera);

	@override
	void Free() {
		_nativeFinalizer.detach(this);
		super.Free();
	}
}

typedef Camera3D = Camera;
