part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                   Mesh
//------------------------------------------------------------------------------------

class Mesh extends NativeWrapper<_Mesh> {
  //--------------------------------Getters-&-Setters-----------------------------------
  
  _Mesh get ref => pointer.ref;
  set ref (_Mesh value) => pointer.ref = value;

  int get vertexCount => ref.vertexCount;
  int get triangleCount => ref.triagleCoung;
  /// OpenGL Vertex Array Object id
  int get vaoID => ref.vaoID;
  int get boneCount => ref.boneCount;

  // Vertex attributes data
  /// Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
  late final Float32List vertices;
  /// Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
  late final Float32List texcoords;
  /// Vertex texture second coordinates (UV - 2 components per vertex) (shader-location = 5)
  late final Float32List texcoords2;
  /// Vertex normals (XYZ - 3 components per vertex) (shader-location = 2)
  late final Float32List normals;
  /// Vertex tangents (XYZW - 4 components per vertex) (shader-location = 4)
  late final Float32List tangents;
  /// Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
  late final Uint8List colors;
  /// Vertex indices (in case vertex data comes indexed)
  late final Uint16List indices;

  /// Animated vertex positions (after bones transformations)
  late final Float32List animVertices;
  /// Animated normals (after bones transformations)
  late final Float32List animNormals;
  /// Vertex bone ids, max 255 bone ids, up to 4 bones influence by vertex (skinning) (shader-location = 6)
  late final Uint8List boneIds;
  /// Vertex bone weight, up to 4 bones influence by vertex (skinning) (shader-location = 7)
  late final Float32List boneWeights;
  /// Bones animated transformation matrices
  late final Matrix boneMatrices;
  /// OpenGL Vertex Buffer Objects id (default vertex data)
  late final Int32List vboId;

  void _setReferences() {
    vertices = ref.vertices.IsNotNull 
      ? ref.vertices.asTypedList(vertexCount) 
      : Float32List(vertexCount);

    texcoords = ref.texcoords.IsNotNull 
      ? ref.texcoords.asTypedList(vertexCount * 2) 
      : Float32List(vertexCount * 2);

    texcoords2 = ref.texcoords2.IsNotNull 
      ? ref.texcoords2.asTypedList(vertexCount * 2) 
      : Float32List(vertexCount * 2);

    normals = ref.normals.IsNotNull 
      ? ref.normals.asTypedList(vertexCount * 3) 
      : Float32List(vertexCount * 3);

    tangents = ref.tangents.IsNotNull 
      ? ref.tangents.asTypedList(vertexCount * 4) 
      : Float32List(vertexCount * 4);

    colors = ref.colors.IsNotNull 
      ? ref.colors.asTypedList(vertexCount * 4) 
      : Uint8List(vertexCount * 4);

    indices = ref.indices.IsNotNull 
      ? ref.indices.asTypedList(triangleCount * 3) 
      : Uint16List(triangleCount * 3);

    animVertices = ref.animVertices.IsNotNull 
      ? ref.animVertices.asTypedList(vertexCount * 3) 
      : Float32List(vertexCount * 3);

    animNormals = ref.animNormals.IsNotNull 
      ? ref.animNormals.asTypedList(vertexCount * 3) 
      : Float32List(vertexCount * 3);

    boneIds = ref.boneIds.IsNotNull 
      ? ref.boneIds.asTypedList(vertexCount * 4) 
      : Uint8List(vertexCount * 4);

    boneWeights = ref.boneWeights.IsNotNull 
      ? ref.boneWeights.asTypedList(vertexCount * 4) 
      : Float32List(vertexCount * 4);

    if (ref.boneMatrices.IsNotNull && boneCount > 0)
      boneMatrices = Matrix._Encapsulate(ref.boneMatrices, length: boneCount);
    else
      boneMatrices = Matrix();

    vboId = ref.vboId.IsNotNull 
      ? ref.vboId.asTypedList(16) 
      : Int32List(16);
  }

  //--------------------------------Constructors----------------------------------------

  // ignore: unused_element_parameter
  Mesh._Encapsulate(super.pointer,{ super.IsOwner, super.length }): super.fromAddress() {
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  // ignore: unused_element
  Mesh._Recieve(_Mesh result) : super(sizeOf<_Mesh>()) {
    ref = result;
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Mesh({
    Float32List? vertices,
    Float32List? texcoords,
    Float32List? texcoords2,
    Float32List? normals,
    Float32List? tangents,
    Uint8List? colors,
    Uint16List? indices,
    Float32List? animVertices,
    Float32List? animNormals,
    Uint8List? boneIds,
    Float32List? boneWeights,
    Matrix? boneMatrices,
    Int32List? vboId,
  })
    : super(sizeOf<_Mesh>())
  {
    this.vertices = vertices ?? Float32List(0);
    this.texcoords = texcoords ?? Float32List(0);
    this.texcoords2 = texcoords2 ?? Float32List(0);
    this.normals = normals ?? Float32List(0);
    this.tangents = tangents ?? Float32List(0);
    this.colors = colors ?? Uint8List(0);
    this.indices = indices ?? Uint16List(0);
    this.animVertices = animVertices ?? Float32List(0);
    this.animNormals = animNormals ?? Float32List(0);
    this.boneIds = boneIds ?? Uint8List(0);
    this.boneWeights = boneWeights ?? Float32List(0);
    this.boneMatrices = boneMatrices ?? Matrix();
    this.vboId = vboId ?? Int32List(0);
  }
  
  //----------------------------------Constructors--------------------------------------

  /// Generate polygonal mesh
  factory Mesh.Poly(int sides, double radius,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshPoly(sides, radius);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate plane mesh (with subdivisions)
  factory Mesh.Plane(double width, double length, int resX, int resZ,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshPlane(width, length, resX, resZ);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate cuboid mesh
  factory Mesh.Cube(double width, double height, double length,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshCube(width, height, length);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate sphere mesh (standard sphere)
  factory Mesh.Sphere(double radius, int rings, int slices,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshSphere(radius, rings, slices);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate half-sphere mesh (no bottom cap)
  factory Mesh.Hemisphere(double radius, int rings, int slices,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshHemiSphere(radius, rings, slices);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate cylinder mesh
  factory Mesh.Cylinder(double radius, double height, int slices,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshCylinder(radius, height, slices);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate cone/pyramid mesh
  factory Mesh.Cone(double radius, double height, int slices,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshCone(radius, height, slices);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate torus mesh
  /// 
  /// AKA Donut
  factory Mesh.Torus(double radius, double size, int radSeg, int sides,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshTorus(radius, size, radSeg, sides);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate torus mesh
  factory Mesh.Knot(double radius, double size, int radSeg, int sides,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshKnot(radius, size, radSeg, sides);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate heightmap mesh from image data
  factory Mesh.Heightmap(Image heightMap, Vector3 size,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshHeightmap(heightMap.ref, size.ref);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  /// Generate cubes-based map mesh from image data
  factory Mesh.CubicMap(Image cubicMap, Vector3 cubeSize,[ RaylibArena? arena ]) {
    _Mesh result = _genMeshCubicmap(cubicMap.ref, cubeSize.ref);
    Mesh mesh = Mesh._Recieve(result);
    arena?.register(mesh);
    return mesh;
  }

  //----------------------------------Utilities-----------------------------------------

  /// Upload mesh vertex data in GPU and provide VAO/VBO ids
  static void Upload({required Mesh mesh, required bool dynamic}) => _uploadMesh(mesh.pointer, dynamic);

  /// Unload mesh data from CPU and GPU
  void Unload() => Free();

  /// Update mesh vertex data in GPU for a specific buffer index
  static void UpdateBuffer({
    required Mesh mesh, required int index,
    required Pointer<Void> data, required int dataSize,
    required int offset
  }) {
    _updateMeshBuffer(mesh.ref, index, data, dataSize, offset);
  }

  /// Draw a 3d mesh with material and transform
  static void Draw(Mesh mesh, Material material, Matrix transform) => _drawMesh(mesh.ref, material.ref, transform.ref);

  /// Draw multiple mesh instances with material and different transforms
  static void DrawInstanced({ required Mesh mesh, required Material material, required List<Matrix> transforms}) {
    using ((Arena arena) {
      Pointer<_Matrix> transformsArray = arena.allocate<_Matrix>(sizeOf<_Matrix>() * transforms.length);
      for (int x = 0; x < transforms.length; x++)
        (transformsArray + x).ref = transforms[x].ref;

      _drawMeshInstanced(mesh.ref, material.ref, transformsArray, transforms.length);
    });
  }

  /// Compute mesh bounding box limits
  BoundingBox GetBoundingBox() {
    _BoundingBox result = _getMeshBoundingBox(this.ref);
    return BoundingBox._Recieve(result);
  }

  /// Compute mesh tangents
  void GenTangents() => _genMeshTangents(pointer);

  /// Export mesh data to file, returns true on success
  bool Export(String fileName) {
    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportMesh(this.ref, cFileName);
    });
  }

  /// Export mesh as code file (.h) defining multiple arrays of vertex attributes
  bool ExportAsCode(String fileName){
    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportMeshAsCode(this.ref, cFileName);
    });
  }
  //---------------------------------Operator------------------------------------------

  Mesh operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return Mesh._Encapsulate(pointer + index);
  }

  void operator []=(Mesh value, int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<Mesh> get values sync* {
    for (int x = 0; x < length; x++)
      yield this[x];
  }

  //---------------------------------Degenerators--------------------------------------
  
  static final Finalizer _finalizer = Finalizer((pointer) {
    _unloadMesh(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void Free() {
    _unloadMesh(ref);
    _finalizer.detach(this);
    super.Free();
  }
}


//------------------------------------------------------------------------------------
//                                   Shader
//------------------------------------------------------------------------------------

class Shader extends NativeWrapper<_Shader> {
  _Shader get ref => pointer.ref;
  set ref(_Shader value) => pointer.ref = value;

  int get id => ref.id;
  set id (int value) => ref.id = value;
  
  late final Int32List locs;
  final Map<String, int> uniformLocIndex = {};
  final Map<String, int> attbLocIndex = {};

  void _setReferences() {
    locs = ref.locs.asTypedList(32);
  }

  // ignore: unused_element
  Shader._Recieve(_Shader result) : super(sizeOf<_Shader>()) {
    ref = result;
    _finalizer.attach(this, pointer, detach: this);
  }

  // ignore: unused_element_parameter
  Shader._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  /// Load shader from files and bind default locations
  factory Shader(String? vsFileName, String? fsFileName,[ RaylibArena? arena ]) {
    Pointer<Utf8> cvsFileName = (vsFileName != null)
      ? vsFileName.toNativeUtf8()
      : nullptr;
    Pointer<Utf8> cfsFileName = (fsFileName != null)
      ? fsFileName.toNativeUtf8()
      : nullptr;

    _Shader result;

    try {
      result = _loadShader(cvsFileName, cfsFileName);
    }
    catch(error) {
      rethrow;
    }
    finally {
      malloc.free(cvsFileName);
      malloc.free(cfsFileName);
    }

    Shader shader = Shader._Recieve(result);
    arena?.register(shader);
    return shader;
  }

  /// Load shader from code strings and bind default locations
  factory Shader.FromMemory(Uint8List? vsCode, Uint8List? fsCode,[ RaylibArena? arena ]) {
    Pointer<Utf8> cvsCode = (vsCode != null)
      ? vsCode.toUTF8Pointer()
      : nullptr;
    Pointer<Utf8> cfsCode = (fsCode != null)
      ? fsCode.toUTF8Pointer()
      : nullptr;
    
    _Shader result;

    try {
      result = _loadShaderFromMemory(cvsCode, cfsCode);
    }
    catch (error) {
      rethrow;
    }
    finally {
      malloc.free(cvsCode);
      malloc.free(cfsCode);
    }

    Shader shader = Shader._Recieve(result);
    arena?.register(shader);
    return shader;
  }

  /// Check if a shader is valid (loaded on GPU)
  bool IsValid() => _isShaderValid(ref);

  /// Get shader uniform location
  int GetLocation(String uniformName) {
    final cuniformName = uniformName.toNativeUtf8();
    int locIndex = _getShaderLocation(ref, cuniformName);

    uniformLocIndex[uniformName] = locIndex;
    malloc.free(cuniformName);

    return locIndex;
  }

  /// Get shader attribute location
  int GetLocationAttrib(String attribName) {
    final cattribName = attribName.toNativeUtf8();
    int locIndex = _getShaderLocationAttrib(ref, cattribName);
    attbLocIndex[attribName] = locIndex;

    return locIndex;
  }

  /// Set shader uniform value
  /// 
  /// The class automatically registers the locIndex of an attribute or uniform searched on [uniformLocIndex]
  /// 
  /// map and [attbLocIndex] map.
  void SetValue(int locIndex, Object value, ShaderUniformDataType type) {
    if (value is int) {
      var tempPtr = malloc.allocate<Int32>(sizeOf<Int32>());
      tempPtr.value = value;
      _setShaderValue(ref, locIndex, tempPtr.cast<Void>(), type.index);
    }
    else if (value is double) {
      var tempPtr = malloc.allocate<Float>(sizeOf<Float>());
      tempPtr.value = value;
      _setShaderValue(ref, locIndex, tempPtr.cast<Void>(), type.index);
    }
    else if (value is Vector2)
      _setShaderValue(ref, locIndex, value.pointer.cast<Void>(), type.index);
    else if (value is Vector3)
      _setShaderValue(ref, locIndex, value.pointer.cast<Void>(), type.index);
    else if (value is Vector4)
      _setShaderValue(ref, locIndex, value.pointer.cast<Void>(), type.index);
    // else if (value is Texture) {
    //   var tempPtr = malloc.allocate<Int32>(sizeOf<Int32>());
    //   tempPtr.value = value.id;
    //   pointer = tempPtr.cast<Void>();
    // }
    else
      return;
  }
  
  /// Set shader uniform value vector
  void SetValueV(int locIndex, List<Object> values, ShaderUniformDataType type) {
    return using((arena) {
      if (values.first is int) {
        Pointer<Int32> tempPtr = arena.allocate<Int32>(sizeOf<Int32>() * values.length);

        for (int x = 0; x < values.length; x++)
          tempPtr[x] = (values as List<int>)[x];
        
        _setShaderValueV(ref, locIndex, .fromAddress(tempPtr.address), type.index, values.length);
      }
      else if (values.first is double) {
        Pointer<Float> tempPtr = arena.allocate<Float>(sizeOf<Float>() * values.length);

        for (int x = 0; x < values.length; x++)
          tempPtr[x] = (values as List<double>)[x];
        
        _setShaderValueV(ref, locIndex, .fromAddress(tempPtr.address), type.index, values.length);
      }
      else if (values.first is Vector2) {
        Pointer<_Vector2> tempPtr = arena.allocate<_Vector2>(sizeOf<_Vector2>() * values.length);

        for (int x = 0; x < values.length; x++)
          tempPtr[x] = (values as List<Vector2>)[x].ref;
        
        _setShaderValueV(ref, locIndex, .fromAddress(tempPtr.address), type.index, values.length);
      }
      else if (values.first is Vector3) {
        Pointer<_Vector3> tempPtr = arena.allocate<_Vector3>(sizeOf<_Vector3>() * values.length);

        for (int x = 0; x < values.length; x++)
          tempPtr[x] = (values as List<Vector3>)[x].ref;
        
        _setShaderValueV(ref, locIndex, .fromAddress(tempPtr.address), type.index, values.length);
      }
      else if (values.first is Vector4) {
        Pointer<_Vector4> tempPtr = arena.allocate<_Vector4>(sizeOf<_Vector4>() * values.length);

        for (int x = 0; x < values.length; x++)
          tempPtr[x] = (values as List<Vector4>)[x].ref;
        
        _setShaderValueV(ref, locIndex, .fromAddress(tempPtr.address), type.index, values.length);
      }
      else if (values.first is Texture) {
        Pointer<Int32> tempPtr = arena.allocate<Int32>(sizeOf<Int32>() * values.length);

        for (int x = 0; x < values.length; x++)
          tempPtr[x] = (values as List<Texture>)[x].id;
        
        _setShaderValueV(ref, locIndex, .fromAddress(tempPtr.address), type.index, values.length);
      }
      else
        return;
    });
  }

  /// Set shader uniform value (matrix 4x4)
  void SetValueMatrix(int locIndex, Matrix mat) => _setShaderValueMatrix(ref, locIndex, mat.ref);
  
  /// Set shader uniform value and bind the texture (sampler2d)
  void SetValueTexture(int locIndex, Texture2D texture) => _setShaderValueTexture(ref, locIndex, texture.ref);

  static final Finalizer _finalizer = Finalizer<Pointer<_Shader>>((pointer) {
    _unloadShader(pointer.ref);
    malloc.free(pointer);
  });

  /// Unload shader from GPU memory (VRAM)
  void Unload() => Free();

  @override
  void Free() {
    _unloadShader(ref);
    _finalizer.detach(this);
    super.Free();
  }
}

//------------------------------------------------------------------------------------
//                                 MaterialMap
//------------------------------------------------------------------------------------

class MaterialMap extends NativeWrapper<_MaterialMap> {
  _MaterialMap get ref => pointer.ref;
  set ref(_MaterialMap value) => pointer.ref = value; 

  late final Texture texture;
  late final Color color;
  double get value => ref.value;

  void setReferences(Pointer<_MaterialMap> pointer) {
    int address = pointer.address;
    texture = Texture._Encapsulate(.fromAddress(address));

    address += sizeOf<_Color>();
    color = Color._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter
  MaterialMap._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress();

  // static final Finalizer _finalizer = Finalizer<Pointer<_MaterialMap>>((pointer) {
  //   malloc.free(pointer);
  // });

  // @override
  // void Free() {
  //   _finalizer.detach(this);
  //   _memory!.Free();
  // }
}

//------------------------------------------------------------------------------------
//                                   Material
//------------------------------------------------------------------------------------

class Material extends NativeWrapper<_Material> {
  _Material get ref => pointer.ref;
  set ref (_Material value) => pointer.ref = value;

  late final Shader _shader;
  Shader get shader => _shader;
  set shader(Shader value) => ref.shader = value.ref;

  late final MaterialMap _materialMap;
  MaterialMap get materialMap => _materialMap;
  set materialMap(MaterialMap value) => _materialMap.ref = value.ref;

  Float32List get params => ref.params.elements;

  // ------------------------------Memory management------------------------------

  void _setReferences() {
    int address = pointer.address;
    _shader = Shader._Encapsulate(.fromAddress(address));
    
    address += sizeOf<_Shader>();
    _materialMap = MaterialMap._Encapsulate(.fromAddress(address));
  }

  // ignore: unused_element_parameter
  Material._Encapsulate(super.pointer,{ super.IsOwner, super.length }) : super.fromAddress() {
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Material._Recieve(_Material result) : super(sizeOf<_Material>()) {
    ref = result;
    _setReferences();
    if (IsOwner)
      _finalizer.attach(this, pointer, detach: this);
  }

  // --------------------------Constructors--------------------------------------

  /// Load materials from model file
  factory Material.LoadMaterials(String fileName,[ RaylibArena? arena ]) {
    Pointer<Utf8> cfileName = fileName.toNativeUtf8();
    Pointer<Int32> materialCount = malloc.allocate<Int32>(sizeOf<Int32>());
    Pointer<_Material> result;

    Material material;

    try {
      result = _loadMaterials(cfileName, materialCount);
      material = Material._Encapsulate(result, IsOwner: true, length: materialCount.value);
    }
    catch (error) {
      rethrow;
    }
    finally {
      malloc.free(cfileName);
      malloc.free(materialCount);
    }

    arena?.register(material);
    return material;
  }

  /// Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
  factory Material.Default() {
    _Material result = _loadMaterialDefault();
    return Material._Recieve(result);
  }
  // -----------------------------Utilities--------------------------------------

  /// Check if a material is valid (shader assigned, map textures loaded in GPU)
  bool IsValid() => _isMaterialValid(this.ref);

  /// Unload material from GPU memory (VRAM)
  void Unload() => Free();

  /// Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
  void SetTexture({ required MaterialMapIndex mapType, required Texture2D texture }) {
    _setMaterialTexture(pointer, mapType.index, texture.ref);
  }

  // -----------------------------Overrides--------------------------------------

  Material operator [](int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    return Material._Encapsulate(pointer + index);
  }

  void operator []=(Material value, int index) {
    if (index < 0 || index >= length) throw RangeError(index);
    (pointer + index).ref = value.ref;
  }

  @override
  Iterable<Material> get values sync* {
    for (int x = 0; x < length; x++)
      yield this[x];
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Material>>((pointer) {
    _unloadMaterial(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void Free() {
    _unloadMaterial(pointer.ref);
    _finalizer.detach(this);
    super.Free();
  }
}
