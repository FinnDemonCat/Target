part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   BoneInfo
//------------------------------------------------------------------------------------

class BoneInfo extends NativeWrapper<_BoneInfo> {
  _BoneInfo get ref => pointer.ref;
  set ref (_BoneInfo value) => pointer.ref = value;

  late final String name;
  int get parent => ref.parent;

  void _setReferences() {
    List<int> stringList = [];
    for (int x = 0; x < 32 && ref.name[x] != 0; x++)
      stringList.add(ref.name[x]);

    name = String.fromCharCodes(stringList);
  }

  // ignore: unused_element_parameter
  BoneInfo._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
  }

  BoneInfo operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return BoneInfo._Encapsulate(pointer + index, IsOwner: false);
  }

  void operator []=(int index, BoneInfo value) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<BoneInfo> get values sync* {
    for(int x = 0; x < length; x++)
      yield this[x]; 
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_BoneInfo>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
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
class Model extends NativeWrapper<_Model> {
  _Model get ref => pointer.ref;
  set ref(_Model value) => pointer.ref = value;

  int get meshCount => ref.meshCount;
  int get boneCount => ref.boneCount;
  int get materialCount => ref.materialCount;
  
  late Matrix _transform;
  late Mesh? _meshes;
  late Material? _materials;
  late BoneInfo? _bones;
  late Transform? _bindPose;
  late Int32List meshMaterial;

  Matrix get transform => _transform;
  set transform(Matrix value) => _transform.ref = value.ref;

  Mesh? get meshes => _meshes;
  set meshes(Mesh? value) {
    if (_meshes == null)
      _meshes = value;
    else if (value != null)
      _meshes!.ref = value.ref;
  }

  Material? get materials => _materials;
  set materials(Material? value) {
    if (_materials == null)
      _materials = value;
    else if (value != null)
      _materials!.ref = value.ref;
  }

  BoneInfo? get bones => _bones;
  set bones(BoneInfo? value) {
    if (_bones == null)
      _bones = value;
    else if (value != null)
      _bones!.ref = value.ref;
  }

  Transform? get bindPose => _bindPose;
  set bindPose(Transform? value) {
    if (_bindPose == null)
      _bindPose = value;
    else if (value != null)
      _bindPose!.ref = value.ref;
  }

  void _setReferences() {
    _transform = Matrix._Encapsulate(Pointer<_Matrix>.fromAddress(pointer.address));
    
    _meshes = ref.meshes.IsNotNull
      ? Mesh._Encapsulate(ref.meshes, length: meshCount, IsOwner: false)
      : null;

    _materials = ref.materials.IsNotNull
      ? Material._Encapsulate(ref.materials, length: materialCount, IsOwner: false)
      : null;
    
    _bones = ref.bones.IsNotNull
      ? BoneInfo._Encapsulate(ref.bones, length: boneCount, IsOwner: false)
      : null;

    _bindPose = ref.bindPose.IsNotNull
      ? Transform._Encapsulate(ref.bindPose, length: boneCount, IsOwner: false)
      : null;

    meshMaterial = ref.meshMaterial.IsNotNull
      ? ref.meshMaterial.asTypedList(meshCount)
      : Int32List(meshCount);
  }

//----------------------------------Constructors-------------------------------------

  // ignore: unused_element_parameter, unused_element
  Model._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    if(IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Model._Recieve(_Model result) : super(sizeOf<_Model>()) {
    ref = result;
    _setReferences();
    if(IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }
  
  /// Load model from files (meshes and materials)
  factory Model(String fileName,[ RaylibArena? arena ]) {
    Pointer<Utf8> cfileName = fileName.toNativeUtf8();
    _Model result;

    try {
      result = _loadModel(cfileName);
    }
    catch (error) {
      rethrow;
    }
    finally {
      malloc.free(cfileName);
    }

    Model model = Model._Recieve(result);
    arena?.register(model);
    return model;
  }

  /// Load model from generated mesh (default material)
  factory Model.FromMesh(Mesh mesh,[ RaylibArena? arena ]) {
    _Model result = _loadModelFromMesh(mesh.ref);
    Model model = Model._Recieve(result);
    arena?.register(model);
    return model;
  }

  /// Compute model bounding box limits (considers all meshes)
  BoundingBox GetBoundingBox() => BoundingBox._Recieve(_getModelBoundingBox(ref));

  /// Check if a model is valid (loaded in GPU, VAO/VBOs)
  bool IsValid() => _isModelValid(ref);

  /// Draw a model (with texture if set)
  static void Draw(Model model, Vector3 position,{ double scale = 1.0, Color? tint }) {
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
   {double scale = 1.0, Color? tint}
  ) {
    tint ??= Color.WHITE;
    _drawModelWires(model.ref, position.ref, scale, tint.ref);
  }

  /// Draw a model wires (with texture if set) with extended parameters
  static void DrawWiresEx(
    Model model, Vector3 position,
    Vector3 rotationAxis, double rotationAngle,
   {Vector3? scale, Color? tint}
  ) {
    scale ??= Vector3.One();
    tint ??= Color.WHITE;
    _drawModelWiresEx(model.ref, position.ref, rotationAxis.ref, rotationAngle, scale.ref, tint.ref);
  }

  /// Draw a model as points
  static void DrawPoints(
    Model model, Vector3 position,
    {double scale = 1.0, Color? tint }
  ) {
    tint ??= Color.WHITE;
    _drawModelPoints(model.ref, position.ref, scale, tint.ref);
  }

  /// Draw a model as points with extended parameters
  static void DrawPointsEx(
    Model model, Vector3 position,
    Vector3 rotationAxis, double rotationAngle,
   {Vector3? scale, Color? tint}
  ) {
    scale ??= Vector3.One();
    tint ??= Color.WHITE;
    _drawModelPointsEx(model.ref, position.ref, rotationAxis.ref, rotationAngle, scale.ref, tint.ref);
  }

  /// Draw bounding box (wires)
  static void DrawBoundingBox({required BoundingBox bounds, required Color color}) => _drawBoundingBox(bounds.ref, color.ref);
//----------------------------------Method--------------------------------------------

  /// Set material for a mesh
  void SetMeshMaterial(int meshId, int materialId) => _setModelMeshMaterial(pointer, meshId, materialId);

//-----------------------------Memory Management--------------------------------------
  
  /// Unload model (including meshes) from memory (RAM and/or VRAM)
  void Unload() => Free();

  static final Finalizer _finalizer = Finalizer<Pointer<_Model>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Free() {
    transform.Free();
    meshes?.Free();
    materials?.Free();
    bones?.Free();
    bindPose?.Free();
    
    _unloadModel(pointer.ref);
    _finalizer.detach(this);
    super.Free();
  }
}

//------------------------------------------------------------------------------------
//                                ModelAnimation
//------------------------------------------------------------------------------------

class ModelAnimation extends NativeWrapper<_ModelAnimation> {
  _ModelAnimation get ref => pointer.ref;
  set ref (_ModelAnimation value) => pointer.ref = value;

  late final String name;
  late final BoneInfo? bones;
  late final List<Transform?> framePoses;
  late final int animationCount;
  int get frameCount => ref.frameCount;
  int get boneCount => ref.boneCount;

  void _setReferences() {
    bones = ref.bones.IsNotNull
      ? BoneInfo._Encapsulate(ref.bones, length: boneCount, IsOwner: false)
      : null;

    name = fromCharArray(ref.name, 32);
    
    for(int x = 0; x < frameCount; x++) {
      framePoses.add(Transform._Encapsulate(ref.framePoses[x], length: boneCount, IsOwner: false));
    }
  }
  
  // ignore: unused_element_parameter
  ModelAnimation._Encapsulate(super.pointer, this.animationCount,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    
    if (IsOwner)
      _finalizer.attach(this, {'ptr': pointer, 'len': animationCount}, detach: this);
  }

  // ignore: unused_element
  ModelAnimation._Recieve(_ModelAnimation result, this.animationCount) : super(sizeOf<_ModelAnimation>()) {
    ref = result;
    _setReferences();
    _finalizer.attach(this, {'ptr': pointer, 'len': animationCount}, detach: this);
  }

  /// Load model animations from file
  factory ModelAnimation.Load(String fileName,[ RaylibArena? arena ]) {
    Pointer<_ModelAnimation> ptr;
    int animCount = 0;
    final Pointer<Utf8> cfileName = fileName.toNativeUtf8();
    final Pointer<Int32> canimCount = malloc.allocate<Int32>(sizeOf<Int32>());

    try {
      ptr = _loadModelAnimations(cfileName, canimCount);
      animCount = canimCount.value;
    }
    catch (error) {
      rethrow;
    }
    finally {
      malloc.free(cfileName);
      malloc.free(canimCount);
    }

    ModelAnimation modelAnimation = ModelAnimation._Encapsulate(ptr, animCount);
    arena?.register(modelAnimation);
    return modelAnimation;
  }

  void IsValid(Model model) => _isModelAnimationValid(model.ref, ref);
  /// Update model animation pose (CPU)
  void UpdateAnimation(Model model, int frame) => _updateModelAnimation(model.ref, ref, frame);
  /// Update model animation mesh bone matrices (GPU skinning)
  void UpdateAnimationBones(Model model, int frame) => _updateModelAnimationBones(model.ref, ref, frame);

  ModelAnimation operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);

    return ModelAnimation._Encapsulate(pointer + index, 1);
  }
  
  void operator []=(int index, ModelAnimation value) {
    if (index < 0 || index >= length) throw RangeError(index);

    (pointer + index).ref = value.ref;
  }

  static final Finalizer<Map<String, dynamic>> _finalizer = Finalizer((data) {
    final Pointer<_ModelAnimation> ptr = data['ptr'];
    final int len = data['len'];
    _unloadModelAnimations(ptr, len);
  });

  void Unload() => Free();

  @override
  void Free() {
    _unloadModelAnimations(pointer, animationCount);
    _finalizer.detach(this);
    super.Free();
  }
}


//------------------------------------------------------------------------------------
//                                      Ray
//------------------------------------------------------------------------------------

class Ray extends NativeWrapper<_Ray> {
  _Ray get ref => pointer.ref;
  set ref (_Ray value) => pointer.ref = value;
  late final Vector3 position;
  late final Vector3 direction;

  void _setReferences() {
    int address = pointer.address;
    position = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    direction = Vector3._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter, unused_element
  Ray._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Ray._Recieve(_Ray result) : super(sizeOf<_Ray>()) {
    ref = result;
    _finalizer.attach(this, pointer, detach: this);
  }

  Ray(Vector3 position, Vector3 direction,[ RaylibArena? arena ]) : super(sizeOf<_Ray>()) {
    ref
      ..position = position.ref
      ..direction = direction.ref;

    _setReferences();
    arena?.register(this);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Ray>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}

class RayCollision extends NativeWrapper<_RayCollision> {
  _RayCollision get ref => pointer.ref;
  set ref(_RayCollision value) => pointer.ref = value;

  bool get hit => ref.hit;
  double get distance => ref.distance;
  late final Vector3 point;
  late final Vector3 normal;

  void _setReferences() {
    int address = pointer.address;
    address += /* sizeOf<Bool>() */ 4 + sizeOf<Float>();
    point = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    normal = Vector3._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter, unused_element
  RayCollision._Encapsulate(super.pointer,{ super.IsOwner, super.length, super.arena }) : super.fromAddress() {
    _setReferences();
    if(IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  RayCollision._Recieve(_RayCollision result,[ RaylibArena? arena ]) : super(sizeOf<_RayCollision>(), arena: arena) {
    ref = result;
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_RayCollision>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}
