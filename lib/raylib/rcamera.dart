part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Camera
//------------------------------------------------------------------------------------

class Camera2D implements Disposeable
{
  NativeResource<_Camera2D>? _memory;
  
  _Camera2D get ref => _memory!.pointer.ref;
  Vector2 get offset => Vector2._recieve(ref.offset);
  Vector2 get target => Vector2._recieve(ref.target);
  double get rotation => ref.rotation;
  double get zoom => ref.zoom;

  set offset (Vector2 value) => ref.offset = value.ref;
  set target (Vector2 value) => ref.target = value.ref;
  set rotation (double value) => ref.rotation = value;
  set zoom (double value) => ref.zoom = value;

  Camera2D({
    required Vector2 offset,
    required Vector2 target,
    double rotation = 0.0,
    double zoom = 1.0
  }) {
    if (zoom < 1.0) zoom = 1.0;

    Pointer<_Camera2D> pointer = malloc.allocate<_Camera2D>(sizeOf<_Camera2D>());
    pointer.ref
    ..offset = offset.ref
    ..target = target.ref
    ..rotation = rotation
    ..zoom = zoom;

    _memory = NativeResource<_Camera2D>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera2D>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.Dispose();
    }
  }
}

// Todo
class Camera3D implements Disposeable
{
  NativeResource<_Camera3D>? _memory;

  _Camera3D get ref => _memory!.pointer.ref;
  _Vector3 get position => _memory!.pointer.ref.position;
  _Vector3 get target => _memory!.pointer.ref.target;
  _Vector3 get up => _memory!.pointer.ref.up;
  double get fovy => _memory!.pointer.ref.fovy;
  CameraProjection get projection => CameraProjection.values[_memory!.pointer.ref.projection];

  set position(Vector3 value) => ref.position = value.ref;
  set target(Vector3 value) => ref.target = value.ref;
  set up(Vector3 value) => ref.up = value.ref;
  set fovy(double value) => ref.fovy = (value > 0) ? value : 0.0;
  set projection(int value) => ref.projection = value;

  Camera3D({
    required Vector3 pos,
    required Vector3 target,
    required Vector3 up,
    required double fovy,
    required CameraProjection projection
  }) {
    Pointer<_Camera3D> pointer = malloc.allocate<_Camera3D>(sizeOf<_Camera3D>());
    pointer.ref
    ..position = pos.ref
    ..target = target.ref
    ..up = up.ref
    ..fovy = fovy
    ..projection = projection.index;

    this._memory = NativeResource<_Camera3D>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera3D>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.Dispose();
    }
  }
}

typedef Camera = Camera3D;
