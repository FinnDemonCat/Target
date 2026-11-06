part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Camera
//------------------------------------------------------------------------------------

// Camera2D, defines position/orientation in 2d space
final class _Camera2D extends Struct {
  external _Vector2
  offset; // Camera offset (screen space offset from window origin)
  external _Vector2
  target; // Camera target (world space target point that is mapped to screen space offset)
  @Float()
  external double rotation; // Camera rotation in degrees (pivots around target)
  @Float()
  external double zoom; // Camera zoom (scaling around target), must not be set to 0, set to 1.0f for no scale
}

/// Camera2D, defines position/orientation in 2d space
class Camera2D extends NativeWrapper<_Camera2D> implements Finalizable {
  _Camera2D get ref => pointer.ref;
  set ref(_Camera2D value) => pointer.ref = value;

  double get rotation => ref.rotation;
  set rotation(double value) => ref.rotation = value;
  double get zoom => ref.zoom;
  set zoom(double value) => ref.zoom = value;

  late final Vector2 _offset;
  Vector2 get offset => _offset;
  set offset(Vector2 value) => ref.offset = value.ref;

  late final Vector2 _target;
  Vector2 get target => _target;
  set target(Vector2 value) => ref.target = value.ref;

  // ==================================== Constructor =====================================

  Camera2D({
    required Vector2 offset,
    required Vector2 target,
    double rotation = 0.0,
    double zoom = 1.0,
    super.arena,
  }) : super(sizeOf<_Camera2D>()) {
    ref
      ..offset = offset.ref
      ..target = target.ref
      ..rotation = rotation
      ..zoom = zoom;

    int address = pointer.address;
    _offset = Vector2._Encapsulate(.fromAddress(address));
    address += sizeOf<_Vector2>();
    _target = Vector2._Encapsulate(.fromAddress(address));

    _finalizer.attach(this, pointer.cast(), detach: this);
  }

  // =================================== Deconstructor ====================================

  static final _finalizer = Finalizer<Pointer<_Camera2D>>((token) {
    malloc.free(token);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}

// Camera, defines position/orientation in 3d space
final class _Camera3D extends Struct {
  external _Vector3 position; // Camera position
  external _Vector3 target; // Camera target it looks-at
  external _Vector3 up; // Camera up vector (rotation over its axis)
  @Float()
  external double fovy; // Camera field-of-view aperture in Y (degrees) in perspective, used as near plane height in world units in orthographic
  @Int32()
  external int projection; // Camera projection: CAMERA_PERSPECTIVE or CAMERA_ORTHOGRAPHIC
}

typedef _Camera = _Camera3D; // Camera type fallback, defaults to Camera3D

/// Camera, defines position/orientation in 3d space
class Camera extends NativeWrapper<_Camera> implements Finalizable {
  _Camera get ref => pointer.ref;
  set ref(_Camera value) => pointer.ref = value;

  double get fovy => ref.fovy;
  set fovy(num value) => ref.fovy = (value > 0) ? value.toDouble() : 0.0;

  CameraProjection get projection => CameraProjection.values[ref.projection];
  set projection(CameraProjection value) => ref.projection = value.index;

  late final Vector3 _position;
  Vector3 get position => _position;
  set position(Vector3 value) => ref.position = value.ref;

  late final Vector3 _target;
  Vector3 get target => _target;
  set target(Vector3 value) => ref.target = value.ref;

  late final Vector3 _up;
  Vector3 get up => _up;
  set up(Vector3 value) => ref.up = value.ref;

  Camera({
    required Vector3 pos,
    required Vector3 target,
    required Vector3 up,
    required double fovy,
    required CameraProjection projection,
    super.arena,
  }) : super(sizeOf<_Camera>()) {
    pointer.ref
      ..position = pos.ref
      ..target = target.ref
      ..up = up.ref
      ..fovy = fovy
      ..projection = projection.index;

    int address = pointer.address;
    _position = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    _target = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    _up = Vector3._Encapsulate(.fromAddress(address));

    _finalizer.attach(this, pointer, detach: this);
  }

  // =================================== Deconstructor ====================================

  static final _finalizer = Finalizer<Pointer<_Camera>>((token) {
    malloc.free(token);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}

typedef Camera3D = Camera;
