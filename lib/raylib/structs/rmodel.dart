part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   BoneInfo
//------------------------------------------------------------------------------------

// typedef _FreeBoneInfoC    = Void Function(Pointer<Void> token);
// typedef _FreeBoneInfoDart = void Function(Pointer<Void> token);
// final _freeBoneInfo = _dyReleaseLib.lookup<NativeFunction<_FreeBoneInfoC>>('FreeBoneInfo');

/// Bone, skeletal animation bone
class BoneInfo extends NativeWrapper<_BoneInfo> implements Finalizable {
  _BoneInfo get ref => pointer.ref;
  set ref (_BoneInfo value) => pointer.ref = value;

	/// Bone name
  late final String name;
  
	/// Bone parent
  int get parent => ref.parent;
	set parent(int value) => ref.parent = value;

  void _setReferences() {
    List<int> stringList = [];
    for (int x = 0; x < 32 && ref.name[x] != 0; x++)
      stringList.add(ref.name[x]);

    name = String.fromCharCodes(stringList);
  }

  // ignore: unused_element_parameter
  BoneInfo._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    	if (IsOwner)
    		_finalizer.attach(this, pointer.cast(), detach: this);
  }

  // ignore: unused_element_parameter, unused_element
  BoneInfo._Recieve(_BoneInfo result): super(sizeOf<_BoneInfo>()) {
    _setReferences();
    ref = result;
    _finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ===================================== Operators ======================================

	BoneInfo operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return BoneInfo._Encapsulate(pointer + index, IsOwner: false);
	}

	void operator[]=(BoneInfo value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<BoneInfo> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	}

  // =================================== Deconstructor ====================================

  static final _finalizer = Finalizer<Pointer<_BoneInfo>>((token) {
    malloc.free(token);
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

// Unload model (including meshes) from memory (RAM and/or VRAM)
// typedef _FreeModelC    = Void Function(Pointer<Void> token);
// typedef _FreeModelDart = void Function(Pointer<Void> token);
// final _freeModel = _dyReleaseLib.lookup<NativeFunction<_FreeModelC>>('FreeModel');

/// Model, meshes, materials and animation data
class Model extends NativeWrapper<_Model> implements Finalizable {
  _Model get ref => pointer.ref;
  set ref(_Model value) => pointer.ref = value;

	/// Number of meshes
  int get meshCount => ref.meshCount;
	set meshCount(int value) => ref.meshCount = value;

	/// Number of bones
  int get boneCount => ref.boneCount;
	set boneCount(int value) => ref.boneCount = value;

	/// Number of materials
  int get materialCount => ref.materialCount;
	set materialCount(int value) => ref.materialCount = value;
  
  late Matrix _transform;
  late Mesh? _meshes;
  late Material? _materials;
  late BoneInfo? _bones;
  late Transform? _bindPose;
  late Int32List meshMaterial;

	/// Local transform matrix
  Matrix get transform => _transform;
  set transform(Matrix value) => _transform.ref = value.ref;

	/// Number of meshes
  Mesh? get meshes => _meshes;
  set meshes(Mesh? value) {
    if (_meshes == null)
      _meshes = value;
    else if (value != null)
      _meshes!.ref = value.ref;
  }

	/// Materials array
  Material? get materials => _materials;
  set materials(Material? value) {
    if (_materials == null)
      _materials = value;
    else if (value != null)
      _materials!.ref = value.ref;
  }

	/// Bones information (skeleton)
  BoneInfo? get bones => _bones;
  set bones(BoneInfo? value) {
    if (_bones == null)
      _bones = value;
    else if (value != null)
      _bones!.ref = value.ref;
  }

	/// Bones base transformation (pose)
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

  // ignore: unused_element_parameter, unused_element
  Model._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
		if (IsOwner)
			_finalizer.attach(this, pointer.cast(), detach: this);
  }

  Model._Recieve(_Model result) : super(sizeOf<_Model>()) {
    ref = result;
    _setReferences();
		_finalizer.attach(this, pointer.cast(), detach: this);
  }
  
	// ==================================== Constructor =====================================

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

  /// Set material for a mesh
  void SetMeshMaterial(int meshId, int materialId) => _setModelMeshMaterial(pointer, meshId, materialId);

	// =================================== Deconstructor ====================================

  static final _finalizer = Finalizer<Pointer<_Model>>((token) {
    _unloadModel(token.ref);
    malloc.free(token);
  });

  // Unload model (including meshes) from memory (RAM and/or VRAM)
  @override
  void Free() {
    _unloadModel(ref);
    _finalizer.detach(this);
    super.Free();
  }
}

//------------------------------------------------------------------------------------
//                                ModelAnimation
//------------------------------------------------------------------------------------

// Unload animation array data
// typedef _FreeModelAnimationC    = Void Function(Pointer<Void> token);
// typedef _FreeModelAnimationDart = void Function(Pointer<Void> token);
// final _freeModelAnimation = _dyReleaseLib.lookup<NativeFunction<_FreeModelAnimationC>>('FreeModelAnimation');

// TODO: Fix NativeFinalizer implementation
/// ModelAnimation
class ModelAnimation extends NativeWrapper<_ModelAnimation> implements Finalizable {
  _ModelAnimation get ref => pointer.ref;
  set ref (_ModelAnimation value) => pointer.ref = value;

	/// Animation name
  late final String name;
	/// Bones information (skeleton)
  late final BoneInfo? bones;
	/// Poses array by frame
  late final List<Transform?> framePoses;
	/// Number of animation frames
  int get frameCount => ref.frameCount;
	/// Number of bones
  int get boneCount => ref.boneCount;
  /// Number of animations
  late final int animationCount;

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

	// ===================================== Operators ======================================

	ModelAnimation operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return ModelAnimation._Encapsulate(pointer + index, 1, IsOwner: false);
	}

	void operator[]=(ModelAnimation value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<ModelAnimation> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	}

	// =================================== Deconstructor ====================================

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

// typedef _FreeRayC    = Void Function(Pointer<Void> token);
// typedef _FreeRayDart = void Function(Pointer<Void> token);
// final _freeRay = _dyReleaseLib.lookup<NativeFunction<_FreeRayC>>('FreeRay');

/// Ray, ray for raycasting
class Ray extends NativeWrapper<_Ray> implements Finalizable {
  _Ray get ref => pointer.ref;
  set ref (_Ray value) => pointer.ref = value;

  late final Vector3 _position;
	/// Ray position (origin)
  Vector3 get position => _position;
  set position(Vector3 value) => _position.ref = value.ref;
  
  late final Vector3 _direction;
	/// Ray direction (normalized)
  Vector3 get direction => _direction;
  set direction(Vector3 value) => _direction.ref = value.ref;

  void _setReferences() {
    int address = pointer.address;
    _position = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    _direction = Vector3._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter, unused_element
  Ray._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();

    if (IsOwner)
      _finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ignore: unused_element_parameter, unused_element
  Ray._Recieve(_Ray result) : super(sizeOf<_Ray>()) {
    ref = result;
    _setReferences();

    _finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ==================================== Constructor =====================================

  Ray(Vector3 position, Vector3 direction,[ RaylibArena? arena ]) : super(sizeOf<_Ray>()) {
    ref
      ..position = position.ref
      ..direction = direction.ref;

    _setReferences();

    arena?.register(this);
    _finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ===================================== Operators ======================================

	Ray operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return Ray._Encapsulate(pointer + index, IsOwner: false);
	}

	void operator[]=(Ray value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<Ray> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	}

  // =================================== Deconstructor ====================================

  static final _finalizer = Finalizer<Pointer<_Ray>>((token) {
    malloc.free(token);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}

// typedef _FreeRayCollisionC    = Void Function(Pointer<Void> token);
// typedef _FreeRayCollisionDart = void Function(Pointer<Void> token);
// final _freeRayCollision = _dyReleaseLib.lookup<NativeFunction<_FreeRayCollisionC>>('FreeRayCollision');

/// RayCollision, ray hit information
class RayCollision extends NativeWrapper<_RayCollision> implements Finalizable {
  _RayCollision get ref => pointer.ref;
  set ref(_RayCollision value) => pointer.ref = value;

	/// Did the ray hit something?
  bool get hit => ref.hit;
	set hit(bool value) => ref.hit = value;
	/// Distance to the nearest hit
  double get distance => ref.distance;
	set distance(num value) => ref.distance = value.toDouble();
  
  late final Vector3 _point;
	/// Point of the nearest hit
  Vector3 get point => _point;
  set point(Vector3 value) => _point.ref = value.ref;
  
  late final Vector3 _normal;
	/// Surface normal of hit
  Vector3 get normal => _normal;
  set normal(Vector3 value) => _normal.ref = value.ref;

  void _setReferences() {
    int address = pointer.address;
    address += /* sizeOf<Bool>() */ 4 + sizeOf<Float>();
    _point = Vector3._Encapsulate(.fromAddress(address));

    address += sizeOf<_Vector3>();
    _normal = Vector3._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter, unused_element
  RayCollision._Encapsulate(super.pointer,{ super.IsOwner, super.length, super.arena }) : super.fromAddress() {
    _setReferences();
    if(IsOwner)
		  _finalizer.attach(this, pointer.cast(), detach: this);
  }

	// ignore: unused_element_parameter, unused_element
  RayCollision._Recieve(_RayCollision result,[ RaylibArena? arena ]) : super(sizeOf<_RayCollision>(), arena: arena) {
    ref = result;
    _setReferences();
    _finalizer.attach(this, pointer.cast(), detach: this);
  }

  // ===================================== Operators ======================================

	RayCollision operator[](int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		return RayCollision._Encapsulate(pointer + index, IsOwner: false);
	}

	void operator[]=(RayCollision value, int index) {
		if (index < 0 || index >= length) throw RangeError(index);
		(pointer + index).ref = value.ref;
	}

	@override
	Iterable<RayCollision> get values sync* {
		for (int x = 0; x < length; x++)
			yield this[x];
	}

  // =================================== Deconstructor ====================================

  static final _finalizer = Finalizer<Pointer<_RayCollision>>((token) {
    malloc.free(token);
  });

  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}
