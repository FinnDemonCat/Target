part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   BoneInfo
//------------------------------------------------------------------------------------

class BoneInfo implements Disposeable
{
  NativeResource<_BoneInfo>? _memory;
  final int _length;
  int get length => _length;

  _BoneInfo get ref => _memory!.pointer.ref;
  late final String name;
  int get parent => ref.parent;

  void _setReferences() {
    List<int> stringList = [];
    for (int x = 0; ref.name[x] != 0; x++)
      stringList.add(ref.name[x]);

    name = String.fromCharCodes(stringList);
  }

  BoneInfo._internal(Pointer<_BoneInfo> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) Dispose();
    _memory = NativeResource<_BoneInfo>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
    
    _setReferences();
  }

  BoneInfo operator [](int index)
  {
    if (index < 0 || index >= _length) throw RangeError(index);
    return BoneInfo._internal(_memory!.pointer + index, owner: false);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_BoneInfo>>((pointer) {
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

//------------------------------------------------------------------------------------
//                                   Model
//------------------------------------------------------------------------------------

/// Model, meshes, materials and animation data
/// 
/// Access to internal arrays is provided via [meshes] and [materials] views, 
/// allowing for intuitive list-style indexing.
///
/// ### Example:
/// ```dart
/// // Accessing the first mesh's vertex data
/// var vertexCount = model.meshes[0].vertexCount;
/// 
/// // Modifying a material property
/// model.materials[0].maps[MAP_DIFFUSE].color = Color.RED;
/// ```
/// 
/// ### Direct Pointer Access:
/// If you need to interface with external C libraries or custom shaders, 
/// use the `.ptr` property on [meshes], [materials], or the [Model] itself 
/// to get the underlying memory address.
class Model implements Disposeable
{
  NativeResource<_Model>? _memory;

  _Model get ref => _memory!.pointer.ref;
  int get meshCount => ref.meshCount;
  int get boneCount => ref.boneCount;
  int get materialCount => ref.materialCount;

  void _setReferences(Pointer<_Model> pointer) {
    meshes    = Mesh._internal(pointer.ref.meshes, length: meshCount, owner: false);
    materials = Material._internal(pointer.ref.materials, length: materialCount, owner: false);
    bones     = BoneInfo._internal(pointer.ref.bones, length: boneCount, owner: false);
    bindPose  = Transform._internal(pointer.ref.bindPose, length: boneCount, owner: false);
    bounds    = _GetBoundingBox();
    meshMaterial = ref.meshMaterial.asTypedList(meshCount);
  }

  void _setmemory(_Model result)
  {
    Pointer<_Model> pointer = malloc.allocate<_Model>(sizeOf<_Model>());
    pointer.ref = result;

    _memory = NativeResource<_Model>(pointer);
    _finalizer.attach(this, pointer, detach: this);

    _setReferences(pointer);
  }
  
  late final Mesh meshes;
  late final Material materials;
  late final BoneInfo bones;
  late final Transform bindPose;
  late final BoundingBox bounds;
  late final Int32List meshMaterial;

//----------------------------------Constructors-------------------------------------
  
  /// Load model from files (meshes and materials)
  Model(String fileName)
  {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);

      _Model result = _loadModel(cfileName);
      _setmemory(result);
    });
  }

  /// Load model from generated mesh (default material)
  Model.FromMesh(Mesh mesh)
  {
    _Model result = _loadModelFromMesh(mesh.ref);
    _setmemory(result);
  }

  /// Compute model bounding box limits (considers all meshes)
  BoundingBox _GetBoundingBox() => BoundingBox._internal(_getModelBoundingBox(ref));
  /// Check if a model is valid (loaded in GPU, VAO/VBOs)
  bool IsValid() => _isModelValid(ref);
  /// Draw a model (with texture if set)
  static void Draw(Model model, Vector3 position,{ double scale = 0.0, Color? tint })
  {
    tint ??= Color.WHITE;
    _drawModel(model.ref, position.ref, scale, tint.ref);
  }

  /// Draw a model with extended parameters
  static void DrawEx(
    Model model, Vector3 position, Vector3 rotationAxis, double rotationAngle,
   {Vector3? scale, Color? tint}
  ) {
    scale ??= Vector3.One();
    tint ??= Color.WHITE;
    _drawModelEx(model.ref, position.ref, rotationAxis.ref, rotationAngle, scale.ref, tint.ref);
  }

  /// Draw a model wires (with texture if set)
  static void DrawWires(
    Model model, Vector3 position,
   {double scale = 0.0, Color? tint}
  ) {
    tint ??= Color.WHITE;
    _drawModelWires(model.ref, position.ref, scale, tint.ref);
  }

  /// Draw a model wires (with texture if set) with extended parameters
  static void DrawWiresEx(
    Model model, Vector3 position, Vector3 rotationAxis, double rotationAngle,
   {Vector3? scale, Color? tint}
  ) {
    scale ??= Vector3.One();
    tint ??= Color.WHITE;
    _drawModelWiresEx(model.ref, position.ref, rotationAxis.ref, rotationAngle, scale.ref, tint.ref);
  }

  /// Draw a model as points
  static void DrawPoints(Model model, Vector3 position,{ double scale = 0.0, Color? tint })
  {
    tint ??= Color.WHITE;
    _drawModelPoints(model.ref, position.ref, scale, tint.ref);
  }

  /// Draw a model as points with extended parameters
  static void DrawPointsEx(
    Model model, Vector3 position, Vector3 rotationAxis, double rotationAngle,
   {Vector3? scale, Color? tint}
  ) {
    scale ??= Vector3.One();
    tint ??= Color.WHITE;
    _drawModelPointsEx(model.ref, position.ref, rotationAxis.ref, rotationAngle, scale.ref, tint.ref);
  }

  /// Draw bounding box (wires)
  static void DrawBoundingBox({required Model model, required Color color}) => _drawBoundingBox(model.bounds.ref, color.ref);
//----------------------------------Method--------------------------------------------

  /// Set material for a mesh
  void SetMeshMaterial(int meshId, int materialId) => _setModelMeshMaterial(_memory!.pointer, meshId, materialId);

//-----------------------------Memory Management--------------------------------------
  
  /// Unload model (including meshes) from memory (RAM and/or VRAM)
  void Unload() => Dispose();

  static final Finalizer _finalizer = Finalizer<Pointer<_Model>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      bounds.Dispose();
      _unloadModel(_memory!.pointer.ref);
      _memory!.Dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                ModelAnimation
//------------------------------------------------------------------------------------

class ModelAnimation implements Disposeable
{
  NativeResource<_ModelAnimation>? _memory;
  _ModelAnimation get ref => _memory!.pointer.ref;

  final int _length;
  late final String? _name;
  String get animName {
    _name ??= FromCharArray(ref.name, 32);
    return _name!;
  }
  int get length => _length;
  int get frameCount => ref.frameCount;
  int get boneCount => ref.boneCount;

  BoneInfo get bones
  {
    if (ref.bones.address == 0) throw Exception("No bones were found");
    return BoneInfo._internal(ref.bones, length: boneCount, owner: false);
  }

  Transform framePoses({ required int frameIndex })
  {
    if (frameIndex < 0 || frameIndex >= frameCount) throw RangeError(frameIndex);
    return Transform._internal(ref.framePoses[frameIndex], length: boneCount, owner: false);
  }
  /* 
  // ignore: unused_element
  void _setmemory(_ModelAnimation result)
  {
    if (_memory != null) dispose();
    Pointer<_ModelAnimation> pointer = malloc.allocate<_ModelAnimation>(sizeOf<_ModelAnimation>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_ModelAnimation>(pointer);
  }
 */
  ModelAnimation._recieve(Pointer<_ModelAnimation> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) Dispose();
    if (pointer.address == 0) return;

    _memory = NativeResource<_ModelAnimation>(pointer);
    
    if (owner)
      _finalizer.attach(this, {'ptr': pointer, 'len': length}, detach: this);
  }

  /// Load model animations from file
  static ModelAnimation Load(String fileName)
  {
    int animCount = 1;
    Pointer<_ModelAnimation>? ptr;

    using ((Arena arena) {
      final Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);
      final Pointer<Int32> canimCount = arena.allocate<Int32>(sizeOf<Int32>());

      ptr = _loadModelAnimations(cfileName, canimCount);
      animCount = canimCount.value;
    });

    if (ptr == null) throw Exception("Couldn't load animations");

    return ModelAnimation._recieve(ptr!, length: animCount);
  }

  void IsValid(Model model) => _isModelAnimationValid(model.ref, ref);
  /// Update model animation pose (CPU)
  void UpdateAnimation(Model model, int frame) => _updateModelAnimation(model.ref, ref, frame);
  /// Update model animation mesh bone matrices (GPU skinning)
  void UpdateAnimationBones(Model model, int frame) => _updateModelAnimationBones(model.ref, ref, frame);

  ModelAnimation operator [](int index) {
    if (index < 0 || index >= _length) throw RangeError(index);

    return ModelAnimation._recieve(_memory!.pointer + index, owner: false);
  }

  static final Finalizer<Map<String, dynamic>> _finalizer = Finalizer((data) {
    final Pointer<_ModelAnimation> ptr = data['ptr'];
    final int len = data['len'];
    _unloadModelAnimations(ptr, len);
  });

  void Unload() => Dispose();

  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadModelAnimations(_memory!.pointer, _length);
      _memory!.Dispose();
    }
  }
}


//------------------------------------------------------------------------------------
//                                      Ray
//------------------------------------------------------------------------------------

class Ray implements Disposeable
{
  NativeResource<_Ray>? _memory;
  _Ray get ref => _memory!.pointer.ref;
  _Vector3 get position => ref.position;
  _Vector3 get direction => ref.direction;
  set position(_Vector3 value) => position = value;
  set direction(_Vector3 value) => direction = value;

  void _setmemory(_Ray result)
  {
    if (_memory != null) Dispose();

    Pointer<_Ray> pointer = malloc.allocate<_Ray>(sizeOf<_Ray>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
  }

  Ray._recieve(_Ray result)
  {
    _setmemory(result);
  }

  Ray(Vector3 position, Vector3 direction)
  {
    if (_memory != null) Dispose();

    Pointer<_Ray> pointer = malloc.allocate<_Ray>(sizeOf<_Ray>());
    pointer.ref
    ..position = position.ref
    ..direction = direction.ref;

    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Ray>>((pointer) {
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

class RayCollision implements Disposeable
{
  NativeResource<_RayCollision>? _memory;
  _RayCollision get ref => _memory!.pointer.ref;
  bool get hit => ref.hit;
  double get distance => ref.distance;
  _Vector3 get point => ref.point;
  _Vector3 get normal => ref.normal;

  void _setmemory(_RayCollision result)
  {
    if (_memory != null) Dispose();

    Pointer<_RayCollision> pointer = malloc.allocate<_RayCollision>(sizeOf<_RayCollision>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
  }

  RayCollision._recieve(_RayCollision result)
  {
    _setmemory(result);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_RayCollision>>((pointer) {
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
