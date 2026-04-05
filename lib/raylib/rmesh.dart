part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Mesh
//------------------------------------------------------------------------------------

class Mesh implements Disposeable
{
  NativeResource<_Mesh>? _memory;
  final int _length;
  int get length => _length;

  // ignore: unused_element
  void _setmemory(_Mesh result)
  {
    Pointer<_Mesh> pointer = malloc.allocate<_Mesh>(sizeOf<_Mesh>());
    pointer.ref = result;

    _memory = NativeResource<_Mesh>(pointer);
    _finalizer.attach(this, pointer, detach: this);
    _setReferences();
  }

  void _setReferences() {
    vertices = ref.vertices.asTypedList(vertexCount);
    texcoords = ref.texcoords.asTypedList(vertexCount * 2);
    texcoords2 = ref.texcoords2.asTypedList(vertexCount * 2);
    normals = ref.normals.asTypedList(vertexCount * 3);
    tangents = ref.tangents.asTypedList(vertexCount * 4);
    colors = ref.colors.asTypedList(vertexCount * 4);
    indices = ref.indices.asTypedList(vertexCount * 3);

    animVertices = ref.animVertices.asTypedList(vertexCount * 3);
    animNormals = ref.animNormals.asTypedList(vertexCount * 3);
    boneIds = ref.boneIds.asTypedList(vertexCount * 4);
    boneWeights = ref.boneWeights.asTypedList(vertexCount * 4);
    boneMatrices = Matrix._internal(ref.boneMatrices, owner: false, length: boneCount);
    vboId = ref.vboId.asTypedList(7);
  }

  Mesh._internal(Pointer<_Mesh> pointer,{ bool owner = false, int length = 1 }) : _length = length
  {
    _memory = NativeResource<_Mesh>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);

    _setReferences();
  }

  //--------------------------------Getters-&-Setters-----------------------------------
  
  _Mesh get ref => _memory!.pointer.ref;

  int get vertexCount => ref.vertexCount;
  int get triangleCount => ref.triagleCoung;
  int get vaoID => ref.vaoID;
  int get boneCount => ref.boneCount;

  // Vertex attributes data
  late final Float32List vertices;
  late final Float32List texcoords;
  late final Float32List texcoords2;
  late final Float32List normals;
  late final Float32List tangents;
  late final Uint8List colors;
  late final Uint16List indices;

  late final Float32List animVertices;
  late final Float32List animNormals;
  late final Uint8List boneIds;
  late final Float32List boneWeights;
  late final Matrix boneMatrices;
  late final Int32List vboId;

  /* 
  // Pointer<Float> get vertices => ref.vertices;
  Float32List get vertices => ref.vertices.asTypedList(vertexCount);
  // Pointer<Float> get texcoords => ref.texcoords;
  Float32List get texcoords => ref.texcoords.asTypedList(vertexCount * 2);
  // Pointer<Float> get texcoords2 => ref.texcoords2;
  Float32List get texcoords2 => ref.texcoords2.asTypedList(vertexCount * 2);
  // Pointer<Float> get normals => ref.normals;
  Float32List get normals => ref.normals.asTypedList(vertexCount * 3);
  // Pointer<Float> get tangents => ref.tangents;
  Float32List get tangents => ref.tangents.asTypedList(vertexCount * 4);
  // Pointer<Uint8> get colors => ref.colors;
  Uint8List get colors => ref.colors.asTypedList(vertexCount * 4);
  // Pointer<Uint16> get indices => ref.indices;
  Uint16List get indices => ref.indices.asTypedList(vertexCount * 3);

  int get boneCount => ref.boneCount;
  Float32List get animVertices => ref.animVertices.asTypedList(vertexCount * 3);
  // Pointer<Float> get animVertices => ref.animVertices;
  Float32List get animNormals => ref.animNormals.asTypedList(vertexCount * 3);
  // Pointer<Float> get animNormals => ref.animNormals;
  Uint8List get boneIds => ref.boneIds.asTypedList(vertexCount * 4);
  // Pointer<Uint8> get boneIds => ref.boneIds;
  Float32List get boneWeights => ref.boneWeights.asTypedList(vertexCount * 4);
  // Pointer<Float> get boneWeights => ref.boneWeights;
  // Pointer<_Matrix> get boneMatrices => ref.boneMatrices;
  // Pointer<Int32> get vboId => ref.vboId;
  */
  //----------------------------------Constructors--------------------------------------

  /// Generate polygonal mesh
  Mesh.Poly(int sides, double radius) : _length = 1
  {
    _Mesh result = _genMeshPoly(sides, radius);
    _setmemory(result);
  }

  /// Generate plane mesh (with subdivisions)
  Mesh.Plane(double width, double length, int resX, int resZ) : _length = 1
  {
    _Mesh result = _genMeshPlane(width, length, resX, resZ);
    _setmemory(result);
  }

  /// Generate cuboid mesh
  Mesh.Cube(double width, double height, double length) : _length = 1
  {
    _Mesh result = _genMeshCube(width, height, length);
    _setmemory(result);
  }

  /// Generate sphere mesh (standard sphere)
  Mesh.Sphere(double radius, int rings, int slices) : _length = 1
  {
    _Mesh result = _genMeshSphere(radius, rings, slices);
    _setmemory(result);
  }

  /// Generate half-sphere mesh (no bottom cap)
  Mesh.Hemisphere(double radius, int rings, int slices) : _length = 1
  {
    _Mesh result = _genMeshHemiSphere(radius, rings, slices);
    _setmemory(result);
  }

  /// Generate cylinder mesh
  Mesh.Cylinder(double radius, double height, int slices) : _length = 1
  {
    _Mesh result = _genMeshCylinder(radius, height, slices);
    _setmemory(result);
  }

  /// Generate cone/pyramid mesh
  Mesh.Cone(double radius, double height, int slices) : _length = 1
  {
    _Mesh result = _genMeshCone(radius, height, slices);
    _setmemory(result);
  }

  /// Generate torus mesh
  /// 
  /// AKA Donut
  Mesh.Torus(double radius, double size, int radSeg, int sides) : _length = 1
  {
    _Mesh result = _genMeshTorus(radius, size, radSeg, sides);
    _setmemory(result);
  }

  /// Generate torus mesh
  Mesh.Knot(double radius, double size, int radSeg, int sides) : _length = 1
  {
    _Mesh result = _genMeshKnot(radius, size, radSeg, sides);
    _setmemory(result);
  }

  /// Generate heightmap mesh from image data
  Mesh.Heightmap(Image heightMap, Vector3 size) : _length = 1
  {
    _Mesh result = _genMeshHeightmap(heightMap.ref, size.ref);
    _setmemory(result);
  }

  /// Generate cubes-based map mesh from image data
  Mesh.CubicMap(Image cubicMap, Vector3 cubeSize) : _length = 1
  {
    _Mesh result = _genMeshCubicmap(cubicMap.ref, cubeSize.ref);
    _setmemory(result);
  }

  //----------------------------------Utilities-----------------------------------------

  /// Upload mesh vertex data in GPU and provide VAO/VBO ids
  static void Upload({required Mesh mesh, required bool dynamic}) => _uploadMesh(mesh._memory!.pointer, dynamic);

  /// Unload mesh data from CPU and GPU
  void Unload() => Dispose();

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
  static void DrawInstanced({ required Mesh mesh, required Material material, required List<Matrix> transforms})
  {
    using ((Arena arena)
    {
      Pointer<_Matrix> transformsArray = arena.allocate<_Matrix>(sizeOf<_Matrix>() * transforms.length);
      for (int x = 0; x < transforms.length; x++)
        (transformsArray + x).ref = transforms[x].ref;

      _drawMeshInstanced(mesh.ref, material.ref, transformsArray, transforms.length);
    });
  }

  /// Compute mesh bounding box limits
  BoundingBox GetBoundingBox()
  {
    _BoundingBox result = _getMeshBoundingBox(this.ref);
    return BoundingBox._internal(result);
  }

  /// Compute mesh tangents
  void GenTangents() =>_genMeshTangents(this._memory!.pointer);

  /// Export mesh data to file, returns true on success
  bool Export(String fileName)
  {
    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportMesh(this.ref, cFileName);
    });
  }

  /// Export mesh as code file (.h) defining multiple arrays of vertex attributes
  bool ExportAsCode(String fileName)
  {
    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportMeshAsCode(this.ref, cFileName);
    });
  }
  //---------------------------------Operator------------------------------------------

  Mesh operator [](int index)
  {
    if (index < 0 || index >= _length) throw RangeError(index);
    return Mesh._internal(_memory!.pointer + index, owner: false);
  }

  //---------------------------------Degenerators--------------------------------------
  
  static final Finalizer _finalizer = Finalizer((pointer) {
    _unloadMesh(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadMesh(_memory!.pointer.ref);
      _memory!.Dispose();      
    }
  }
}


//------------------------------------------------------------------------------------
//                                   Shader
//------------------------------------------------------------------------------------

class Shader implements Disposeable
{
  NativeResource<_Shader>? _memory;
  _Shader get ref => _memory!.pointer.ref;
  int get id => ref.id;
  // Pointer<Int32> get locs => ref.locs;
  late final Int32List locs;

  void _setmemory(_Shader result)
  {
    Pointer<_Shader> pointer = malloc.allocate<_Shader>(sizeOf<_Shader>());
    pointer.ref = result;

    _memory = NativeResource<_Shader>(pointer);
    _finalizer.attach(this, pointer, detach: this);
    _setReferences();
  }

  void _setReferences() {
    locs = ref.locs.asTypedList(32);
  }

  Shader._internal(Pointer<_Shader> pointer,{ bool owner = true }) {
    _memory = NativeResource(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
    
    _setReferences();
  }

  /// Load shader from files and bind default locations
  Shader(String vsFileName, String fsFileName)
  {
    using ((Arena arena) {
      Pointer<Utf8> cvsFileName = vsFileName.toNativeUtf8(allocator: arena);
      Pointer<Utf8> cfsFileName = fsFileName.toNativeUtf8(allocator: arena);

      _Shader result = _loadShader(cvsFileName, cfsFileName);
      _setmemory(result);
    });
  }

  /// Load shader from code strings and bind default locations
  Shader.FromMemory(Uint8List vsCode, Uint8List fsCode)
  {
    using ((Arena arena) {
      Pointer<Utf8> cvsCode = uint8ListToUtf8Pointer(vsCode, allocator: arena);
      Pointer<Utf8> cfsCode = uint8ListToUtf8Pointer(fsCode, allocator: arena);

      _Shader result = _loadShaderFromMemory(cvsCode, cfsCode);
      _setmemory(result);
    });
  }

  /// Check if a shader is valid (loaded on GPU)
  void IsValid() => _isShaderValid(ref);

  /// Get shader uniform location
  int GetLocation(String uniformName)
  {
    return using ((Arena arena) {
      final cuniformName = uniformName.toNativeUtf8(allocator: arena);
      return _getShaderLocation(ref, cuniformName);
    });
  }

  /// Get shader attribute location
  int GetLocationAttrib(String attribName)
  {
    return using ((Arena arena) {
      final cattribName = attribName.toNativeUtf8(allocator: arena);
      return _getShaderLocationAttrib(ref, cattribName);
    });
  }

  /// Set shader uniform value
  void SetValue(int locIndex, Pointer<Void> value, int uniformType) => _setShaderValue(ref, locIndex, value, uniformType);
  
  /// Set shader uniform value vector
  void SetValueV(int locIndex, Pointer<Void> value, int uniformType, int count) => _setShaderValueV(ref, locIndex, value, uniformType, count);

  /// Set shader uniform value (matrix 4x4)
  void SetValueMatrix(int locIndex, Matrix mat) => _setShaderValueMatrix(ref, locIndex, mat.ref);
  
  /// Set shader uniform value and bind the texture (sampler2d)
  void SetValueTexture(int locIndex, Texture2D texture) => _setShaderValueTexture(ref, locIndex, texture.ref);

  static final Finalizer _finalizer = Finalizer<Pointer<_Shader>>((pointer) {
    _unloadShader(pointer.ref);
    malloc.free(pointer);
  });

  /// Unload shader from GPU memory (VRAM)
  void Unload() => Dispose();

  @override
  void Dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadShader(ref);
      _memory!.Dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                 MaterialMap
//------------------------------------------------------------------------------------

class MaterialMap implements Disposeable
{
  NativeResource<_MaterialMap>? _memory;
  final int _length;
  int get length => _length;

  _MaterialMap get ref => _memory!.pointer.ref;
  late final Texture texture;
  late final Color color;
  double get value => ref.value;

  void setReferences(Pointer<_MaterialMap> pointer) {
    int address = pointer.address;
    texture = Texture._internal(.fromAddress(address));

    address += sizeOf<_Color>();
    color = Color._internal(.fromAddress(address));
  }

  MaterialMap._internal(Pointer<_MaterialMap> pointer,{ bool owner = true, int length = 1 }) : _length = length
  {
    _memory = NativeResource(pointer, IsOwner: owner);
    
    if(owner)
      _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_MaterialMap>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void Dispose() {
    _finalizer.detach(this);
    _memory!.Dispose();
  }
}

//------------------------------------------------------------------------------------
//                                   Material
//------------------------------------------------------------------------------------

class Material implements Disposeable
{
  NativeResource<_Material>? _memory;
  final int _length;
  int get length => _length;

  _Material get ref => _memory!.pointer.ref;
  late final Shader shader;
  late final MaterialMap materialMap;
  Float32List get params => ref.params.elements;

  // ------------------------------Memory management------------------------------

  // ignore: unused_element
  void _setmemory(_Material result)
  {
    if (_memory != null) Dispose();
    Pointer<_Material> pointer = malloc.allocate<_Material>(sizeOf<_Material>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);

    _setReferences();
  }

  // Continue Transform and other functions `final late` member encapsulations fix

  void _setReferences() {
    int address = _memory!.pointer.address;
    shader = Shader._internal(.fromAddress(address));

    address += sizeOf<_Shader>();
    materialMap = MaterialMap._internal(.fromAddress(address));
  }

  Material._internal(Pointer<_Material> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) Dispose();

    _memory = NativeResource(pointer, IsOwner: owner);
    if (owner)
      _finalizer.attach(this, pointer, detach: this);

    _setReferences();
  }

  // --------------------------Constructors--------------------------------------

  /// Load materials from model file
  static Material LoadMaterials(String fileName)
  {
    return using ((Arena arena)
    {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);
      Pointer<Int32> materialCount = arena.allocate<Int32>(sizeOf<Int32>());

      Pointer<_Material> array = _loadMaterials(cfileName, materialCount);

      return Material._internal(array, length: materialCount.value);
    });
  }

  /// Load default material (Supports: DIFFUSE, SPECULAR, NORMAL maps)
  Material.Default() : _length = 1
  {
    _Material result = _loadMaterialDefault();
    _setmemory(result);
  }
  // -----------------------------Utilities--------------------------------------

  /// Check if a material is valid (shader assigned, map textures loaded in GPU)
  bool IsValid() => _isMaterialValid(this.ref);

  /// Unload material from GPU memory (VRAM)
  void Unload() => Dispose();

  /// Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...)
  void SetTexture({ required int mapType, required Texture2D texture })
  {
    _setMaterialTexture(_memory!.pointer, mapType, texture.ref);
  }

  // -----------------------------Overrides--------------------------------------

  Material operator [](int index)
  {
    if (index < 0 || index >= _length) throw RangeError(index);
    return Material._internal(_memory!.pointer + index, owner: false);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Material>>((pointer) {
    _unloadMaterial(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void Dispose()
  {
    _finalizer.detach(this);
    _unloadMaterial(_memory!.pointer.ref);
    _memory!.Dispose();
  }
}
