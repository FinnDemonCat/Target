part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Camera
//------------------------------------------------------------------------------------

class Camera2D extends NativeWrapper<_Camera2D> {
  // NativeResource<_Camera2D>? _memory;
  
  _Camera2D get ref => pointer.ref;
  late final Vector2 offset;
  late final Vector2 target;
  // Vector2 get offset => Vector2._recieve(ref.offset);
  // Vector2 get target => Vector2._recieve(ref.target);
  double get rotation => ref.rotation;
  double get zoom => ref.zoom;

  // set offset (Vector2 value) => ref.offset = value.ref;
  // set target (Vector2 value) => ref.target = value.ref;
  set rotation (double value) => ref.rotation = value;
  set zoom (double value) => ref.zoom = value;

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

    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera2D>>((pointer) {
    malloc.free(pointer);
  });
  
  
  @override
  void Free() {
    offset.Free();
    target.Free();
    _finalizer.detach(this);
    super.Free();
  }
}

class Camera extends NativeWrapper<_Camera> {
  _Camera get ref => pointer.ref;

  double get fovy => ref.fovy;
  set fovy(double value) => ref.fovy = (value > 0) ? value : 0.0;

  CameraProjection get projection => CameraProjection.values[ref.projection];
  set projection(int value) => ref.projection = value;

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
  }) : super(sizeOf<_Camera>())
  {
    // Pointer<_Camera> pointer = malloc.allocate<_Camera>(sizeOf<_Camera>());
    pointer.ref
    ..position = pos.ref
    ..target = target.ref
    ..up = up.ref
    ..fovy = fovy
    ..projection = projection.index;

    int address = pointer.address;
    position = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    target = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    up = Vector3._Encapsulate(.fromAddress(address));

    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Free() {
    position.Free();
    target.Free();
    up.Free();
    _finalizer.detach(this);
    super.Free();
  }
}

typedef Camera3D = Camera;
