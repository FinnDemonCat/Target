part of 'raylib.dart';

//------------------------------------------------------------------------------------
/// Module Functions Definition - Vector2 math
//------------------------------------------------------------------------------------
class Vector2 implements Disposeable
{
	NativeResource<_Vector2>? _memory;

	void _setmemory(_Vector2 result)
	{
    if (_memory != null) dispose();

    Pointer<_Vector2> pointer = malloc.allocate<_Vector2>(sizeOf<_Vector2>());
    _memory = NativeResource(pointer);

    _finalizer.attach(this, pointer, detach: this);
  }

  double get x { return _memory!.pointer.ref.x; }
  double get y { return _memory!.pointer.ref.y; }
  set x (double value) { _memory!.pointer.ref.x = value; }
  set y (double value) { _memory!.pointer.ref.y = value; }

  _Vector2 get ref => _memory!.pointer.ref;
  set ref (_Vector2 value) => ref = value;
  Pointer<_Vector2> get _ptr => _memory!.pointer;

  /// Set `x` and `y`  at once
  void Set(double x, double y) { this.x = x; this.y = y; }

//--------------------------------Constructors----------------------------------------

  /// Vector with components of value x and y. Defaults to 0.0 and 0.0
  Vector2([double x = 0.0, double y = 0.0])
  {
    Pointer<_Vector2> pointer = malloc.allocate<_Vector2>(sizeOf<_Vector2>());

    pointer.ref
    ..x = x
    ..y = y;

    _memory = NativeResource<_Vector2>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  Vector2._internal(_Vector2 result)
  {
    _setmemory(result);
  }

  /// Vector with components value 0.0f
  factory Vector2.Zero() => Vector2();

  /// Vector with components value 1.0f
  factory Vector2.One() => Vector2(1.0, 1.0);

//--------------------------------Methods---------------------------------------------

  /// Get max value for each pair of components
  /// 
  /// Developer Note: This method returns a new instance of Vecto2
  static Vector2 Max(Vector2 v1, Vector2 v2) => Vector2(math.max(v1.x, v2.x));

  /// Calculate two vectors dot product
  static double Dot(Vector2 v1, Vector2 v2) => (v1.x * v2.x) + (v1.y * v2.y);

  /// Calculate two vectors cross product
  static double Cross(Vector2 v1, Vector2 v2) => (v1.x * v2.x) - (v1.y * v2.y); 

  /// Calculate reflected vector to normal
  static Vector2 Reflect(Vector2 v, Vector2 normal)
  {
    double dotProduct = (v.x * normal.x) + (v.y * normal.y);

    return Vector2(
      v.x - (2.0 * normal.x) * dotProduct,
      v.y - (2.0 * normal.y) * dotProduct
    );
  }
  
  /// Check whether two given vectors are almost equal
  static bool Equals(Vector2 p, Vector2 q)
  {
    return ((p.x - q.x).abs() <= (EPSILON * math.max(1.0, math.max(p.x.abs(), q.x.abs())))) &&
                ((p.y - q.y).abs() <= (EPSILON * math.max(1.0, math.max(p.y.abs(), q.y.abs()))));
  }

  /// Compute the direction of a refracted ray
  /// 
  /// v: normalized direction of the incoming ray
  /// 
  /// n: normalized normal vector of the interface of two optical media
  /// 
  /// r: ratio of the refractive index of the medium from where the ray comes
  /// 
  /// to the refractive index of the medium on the other side of the surface
  Vector2 Refract(Vector2 v, Vector2 n, double r)
  {
    Vector2 result = Vector2.Zero();

    double dot = (v.x * v.x) + (v.y * v.y);
    double d = 1.0 - r * r * (1.0 - dot * dot);

    if (d >= 0)
    {
      d = math.sqrt(d);
      result.x = r * v.x - (r * dot + d) * n.x;
      result.y = r * v.y - (r * dot + d) * n.y;
    }

    return result;
  }

  /// Get (evaluate) spline point: Linear
  void GetSplinePointLinear(Vector2 startPos, Vector2 endPos, double t) {
    ref = _getSplinePointLinear(startPos.ref, endPos.ref, t);
  }

  /// Get (evaluate) spline point: B-Spline
  void GetSplinePointBasis(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, double t) {
    ref = _getSplinePointBasis(p1.ref, p2.ref, p3.ref, p4.ref, t);
  }

  /// Get (evaluate) spline point: Catmull-Rom
  void GetSplinePointCatmullRom(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, double t) {
    ref = _getSplinePointCatmullRom(p1.ref, p2.ref, p3.ref, p4.ref, t);
  }

  /// Get (evaluate) spline point: Quadratic Bezier
  void GetSplinePointBezierQuad(Vector2 p1, Vector2 c2, Vector2 p3, double t) {
    ref = _getSplinePointBezierQuad(p1.ref, c2.ref, p3.ref, t);
  }

  /// Get (evaluate) spline point: Cubic Bezier
  void GetSplinePointBezierCubic(Vector2 p1, Vector2 c2, Vector2 c3, Vector2 p4, double t) {
    ref = _getSplinePointBezierCubic(p1.ref, c2.ref, c3.ref, p4.ref, t);
  }

//------------------------------------Deconstrutor------------------------------------
  
  static final Finalizer _finalizer = Finalizer<Pointer<_Vector2>>((pointer) {
    if (pointer.address == 0) return;

    malloc.free(pointer);
  });
  
  @override
  void dispose() {
    if(_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

/// **Performance Note:** Performed *in-place* to prevent GC pressure 
/// and avoid redundant `malloc` calls in the loop.
///
/// * **Address:** Remains constant.
/// * **Memory:** Zero new allocations.
extension Vector2Math on Vector2
{
  /// Add two vectors (v1 + v2)
  void Add(Vector2 other) { this.x += other.x; this.y += other.y; }

  /// Returns the sum of `this` and `other` vectors
  Vector2 operator +(Vector2 other) => Vector2(this.x+other.x, this.y+other.y);
  
  /// Subtract two vectors (v1 - v2)
  void Subtract(Vector2 other) { this.x -= other.x; this.y -= other.y; }

  /// Returns the dif of `this` and `other` vectors
  Vector2 operator -(Vector2 other) => Vector2(this.x-other.x, this.y-other.y);

  /// Subtract vector by float value
  void SubractValue(double sub) { this.x -= sub; this.y -= sub; }

  /// Calculate vector length
  double Length() => math.sqrt((this.x * this.x) + (this.y + this.y));

  /// Calculate vector square length
  double LengthSqr() => ((this.x * this.x) + (this.y + this.y));

  /// Calculate distance between two vectors
  double Distance(Vector2 v2)
  {
	  return math.sqrt((this.x - v2.x) * (this.x - v2.x)) + ((this.y - v2.y) + (this.y - v2.y));
  }

  /// Calculate square distance between two vectors
  double DistanceSqr(Vector2 v2)
  {
	  return ((this.x - v2.x) * (this.x - v2.x)) + ((this.y - v2.y) + (this.y - v2.y));
  }

  /// Calculate the signed angle from this to v2, relative to the origin (0, 0)
  ///
  /// NOTE: Coordinate system convention: positive X right, positive Y down
  ///
  /// positive angles appear clockwise, and negative angles appear counterclockwise
  double Angle(Vector2 v2)
  {
    double dot = (this.x * v2.x) + (this.y * v2.y);
    double det = (this.x * v2.y) - (this.y * v2.x);

    return math.atan2(det, dot);
  }

  /// Calculate angle defined by a two vectors line
  ///
  /// NOTE: Parameters need to be normalized
  /// 
  /// DEVELOPER NOTE: Calculates LineAngle with `this` as start and `arg` as end
  ///
  /// Current implementation should be aligned with glm::angle
  double LineAngle(Vector2 end) => -math.atan2(end.y - this.y, end.x - this.x);
  
  /// Scale vector (multiply by value)
  void Scale(double value) { this.x *= value; this.y *= value; }

  /// Multiplies `this` vector by `other` (In-place)
  void Multiply(Vector2 other) { this.x *= other.x; this.y *= other.y; }

  /// Returns the product of `this` and `other` vectors (New instance)
  Vector2 operator *(Vector2 other) => Vector2(this.x * other.x, this.y * other.y);

  /// Divides `this` vector by `other` (In-place)
  void Divide(Vector2 other) { this.x /= other.x; this.y /= other.y; }

  /// Returns the quotient of `this` and `other` vectors (New instance)
  Vector2 operator /(Vector2 other) => Vector2(this.x / other.x, this.y / other.y);

  /// Negate `this` vector
  void Negate() { this.x *= -1; this.y *= -1; }

  /// Transforms a Vector2 by a given Matrix
  void Transform() {}

  /// Calculate linear interpolation between two vectors
  /// 
  /// Developer Note: For memory persistance, this extension modifies `this` to be the result of LERP of `v1`, `v2` and `ammount`
  void Lerp(Vector2 v1, Vector2 v2, double ammount)
  {
    this.x = v1.x + ammount * (v2.x - v1.x);
    this.y = v1.y + ammount * (v2.y - v1.y);
  }

  /// Rotate vector by angle
  void Rotate(double angle)
  {
    double cosresult = math.cos(angle);
    double sinresult = math.sin(angle);

    this.x = (this.x * cosresult - this.y * sinresult);
    this.y = (this.x * sinresult + this.y * cosresult);
  }

  /// Move Vector towards target
  void MoveTowards(Vector2 target, double maxDistance)
  {
    double dx = target.x - this.x;
    double dy = target.y - this.y;
    double value = (dx * dx) + (dy * dy);

    if ((value == 0) || (maxDistance >= 0) && (value <= maxDistance * maxDistance)) return;

    double dist = math.sqrt(value);

    this.x = this.x + dx / dist * maxDistance;
    this.y = this.y + dy / dist * maxDistance;
  }

  void Invert()
  {
    this.x = 1.0 / this.x;
    this.y = 1.0 / this.y;
  }

  /// Clamp the components of the vector between
  ///
  /// min and max values specified by the given vectors
  void Clamp(Vector2 min, Vector2 max)
  {
    this.x = math.min(max.x, math.max(min.x, this.x));
    this.y = math.min(max.y, math.max(min.y, this.y));
  }

  /// Clamp the magnitude of the vector between two min and max values
  void ClampValue(double min, double max)
  {
    double length = (this.x * this.x) + (this.y * this.y);
    if (length > 0.0)
    {
      length = math.sqrt(length);
      double scale = 1.0;

      if (length < min)
      {
        scale = min/length;
      }
      else if (length > max)
      {
        scale = max/length;
      }

      this.x = this.x * scale;
      this.y = this.y * scale;
    }
  }
}

//------------------------------------------------------------------------------------
/// Module Functions Definition - Vector3 math
//------------------------------------------------------------------------------------

class Vector3 implements Disposeable
{
  NativeResource<_Vector3>? _memory;

  // ignore: unused_element
  void _setmemory(_Vector3 result)
  {
    if (_memory != null) _memory!.dispose();

    Pointer<_Vector3> pointer = malloc.allocate<_Vector3>(sizeOf<_Vector3>());
    pointer.ref
    ..x = result.x
    ..y = result.y
    ..z = result.z;

    _memory = NativeResource(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  _Vector3 get ref => _memory!.pointer.ref;
  Pointer<_Vector3> get _ptr => _memory!.pointer;

  double get x => ref.x;
  double get y => ref.y;
  double get z => ref.z;

  set x (double value) => _memory!.pointer.ref.x = value;
  set y (double value) => _memory!.pointer.ref.y = value;
  set z (double value) => _memory!.pointer.ref.z = value;

  ///Set all values in a single call
  void Set(double x, double y, double z)
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }

//----------------------------------Constructors------------------------------------

  Vector3([double x = 0.0, double y = 0.0, double z = 0.0])
  {
    if (_memory != null) _memory!.dispose();

    Pointer<_Vector3> pointer = malloc.allocate<_Vector3>(sizeOf<_Vector3>());
    pointer.ref
    ..x = x
    ..y = y
    ..z = z;

    _memory = NativeResource(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  Vector3._recieve(_Vector3 result) { _setmemory(result); }

  /// Vector with components value 0.0f
  factory Vector3.Zero() => Vector3();

  /// Vector with components value 1.0f
  factory Vector3.One() => Vector3(1.0, 1.0, 1.0);

//--------------------------------Methods-------------------------------------------

  static Vector3 CrossProduct(Vector3 v1, Vector3 v2)
  {
    Vector3 result = Vector3();
    result.x = v1.y * v2.z - v1.z * v2.y;
    result.y = v1.z * v2.x - v1.x * v2.z;
    result.z = v1.x * v2.y - v1.y * v2.x;

    return result;
  }

  static Vector3 Perpendicular(Vector3 v)
  {
    Vector3 result = Vector3();
    double min = v.x.abs();
    Vector3 cardinalAxis = Vector3(1.0, 0.0, 0.0);

    if (v.y.abs() < min)
    {
      min = v.y.abs();
      cardinalAxis = Vector3(0.0, 1.0, 0.0);
    }

    if (v.z.abs() < min)
    {
      cardinalAxis = Vector3(0.0, 0.0, 1.0);
    }

    result.x = v.y * cardinalAxis.z - v.z * cardinalAxis.y;
    result.y = v.z * cardinalAxis.x - v.x * cardinalAxis.z;
    result.z = v.x * cardinalAxis.y - v.y * cardinalAxis.x;

    return result;
  }

  /// Calculate distance between two vectors
  double Distance(Vector3 v1, Vector3 v2)
  {
    double dx = v2.x - v1.x;
    double dy = v2.y - v1.y;
    double dz = v2.z - v1.z;

    return math.sqrt(dx*dx + dy*dy + dz*dz);
  }

  /// Calculate square distance between two vectors
  double DistanceSqr(Vector3 v1, Vector3 v2)
  {
    double dx = v2.x - v1.x;
    double dy = v2.y - v1.y;
    double dz = v2.z - v1.z;

    return dx*dx + dy*dy + dz*dz;
  }

  /// Calculate angle between two vectors
  double Angle(Vector3 v1, Vector3 v2)
  {
    double crossX = v1.y*v2.z - v1.z*v2.y;
    double crossY = v1.z*v2.x - v1.x*v2.z;
    double crossZ = v1.x*v2.y - v1.y*v2.x;
    double len = math.sqrt(crossX*crossX + crossY*crossY + crossZ*crossZ);
    double dot = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);

    return math.atan2(len, dot);
  }

  ///Calculate the projection of the vector v1 on to v2
  static Vector3 Project(Vector3 v1, Vector3 v2)
  {
    Vector3 result = Vector3();

    double v1dv2 = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);
    double v2dv2 = (v2.x*v2.x + v2.y*v2.y + v2.z*v2.z);
    
    // magnitude division by zero guard
    double mag = (v2dv2 != 0.0) ? (v1dv2 / v2dv2) : 0.0;

    result.x = v2.x * mag;
    result.y = v2.y * mag;
    result.z = v2.z * mag;

    return result;
  }

  ///Calculate the rejection of the vector v1 on to v2
  static Vector3 Reject(Vector3 v1, Vector3 v2)
  {
    Vector3 result = Vector3();

    double v1dv2 = (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z);
    double v2dv2 = (v2.x*v2.x + v2.y*v2.y + v2.z*v2.z);

    double mag = v1dv2/v2dv2;

    result.x = v1.x - (v2.x*mag);
    result.y = v1.y - (v2.y*mag);
    result.z = v1.z - (v2.z*mag);

    return result;
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Vector3>>((pointer) {
    malloc.free(pointer);
  });

  /// Orthonormalize provided vectors
  /// Makes vectors normalized and orthogonal to each other
  /// Gram-Schmidt function implementation
  static void OrthoNormalize(Vector3 v1, Vector3 v2)
  {
    double length = 0.0;
    double ilength = 0.0;

    // Vector3Normalize(v1)
    length = math.sqrt(v1.x*v1.x + v1.y*v1.y + v1.z*v1.z);
    
    if (length == 0.0) length = 1.0;
    ilength = 1.0 / length;

    v1.x *= ilength;
    v1.y *= ilength;
    v1.z *= ilength;

    // Vector3CrossProduct(v1, v2)
    double vn1x = v1.y*v2.z - v1.z*v2.y;
    double vn1y = v1.z*v2.x - v1.x*v2.z;
    double vn1z = v1.x*v2.y - v1.y*v2.x;

    double l2 = math.sqrt(vn1x*vn1x + vn1y*vn1y + vn1z*vn1z);
    
    if (l2 == 0.0) l2 = 1.0;
    double il2 = 1.0 / l2;
    
    vn1x *= il2;
    vn1y *= il2;
    vn1z *= il2;

    v2.x = vn1y*v1.z - vn1z*v1.y;
    v2.y = vn1z*v1.x - vn1x*v1.z;
    v2.z = vn1x*v1.y - vn1y*v1.x;
  }

//----------------------------------Generators--------------------------------------

  /// Calculate cubic hermite interpolation between two vectors and their tangents
  /// 
  /// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
  Vector3 CubicHermite(Vector3 v1, Vector3 tangent1, Vector3 v2, Vector3 tangent2, double amount)
  {
    Vector3 result = Vector3();

    double amountPow2 = amount*amount;
    double amountPow3 = amount*amount*amount;

    result.x = (2*amountPow3 - 3*amountPow2 + 1)*v1.x + (amountPow3 - 2*amountPow2 + amount)*tangent1.x + (-2*amountPow3 + 3*amountPow2)*v2.x + (amountPow3 - amountPow2)*tangent2.x;
    result.y = (2*amountPow3 - 3*amountPow2 + 1)*v1.y + (amountPow3 - 2*amountPow2 + amount)*tangent1.y + (-2*amountPow3 + 3*amountPow2)*v2.y + (amountPow3 - amountPow2)*tangent2.y;
    result.z = (2*amountPow3 - 3*amountPow2 + 1)*v1.z + (amountPow3 - 2*amountPow2 + amount)*tangent1.z + (-2*amountPow3 + 3*amountPow2)*v2.z + (amountPow3 - amountPow2)*tangent2.z;

    return result;
  }

  /// Calculate reflected vector to normalVector3 Vector3Reflect(Vector3 v, Vector3 normal)
  Vector3 Reflect(Vector3 v, Vector3 normal)
  {
    Vector3 result = Vector3();

    // I is the original vector
    // N is the normal of the incident plane
    // R = I - (2*N*(DotProduct[I, N]))

    double dotProduct = (v.x*normal.x + v.y*normal.y + v.z*normal.z);

    result.x = v.x - (2.0*normal.x)*dotProduct;
    result.y = v.y - (2.0*normal.y)*dotProduct;
    result.z = v.z - (2.0*normal.z)*dotProduct;

    return result;
  }

  /// Get min value for each pair of components
  Vector3 Min(Vector3 v1, Vector3 v2)
  {
    Vector3 result = Vector3();

    result.x = math.min(v1.x, v2.x);
    result.y = math.min(v1.y, v2.y);
    result.z = math.min(v1.z, v2.z);

    return result;
  }

  /// Get max value for each pair of components
  Vector3 Max(Vector3 v1, Vector3 v2)
  {
    Vector3 result = Vector3();

    result.x = math.max(v1.x, v2.x);
    result.y = math.max(v1.y, v2.y);
    result.z = math.max(v1.z, v2.z);

    return result;
  }

  /// Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
  /// 
  /// NOTE: Assumes P is on the plane of the triangleVector3 Vector3Barycenter(Vector3 p, Vector3 a, Vector3 b, Vector3 c)
  Vector3 Barycenter(Vector3 p, Vector3 a, Vector3 b, Vector3 c)
  {
    Vector3 result = Vector3();

    double v0x = b.x - a.x, v0y = b.y - a.y, v0z = b.z - a.z;   // Vector3Subtract(b, a)
    double v1x = c.x - a.x, v1y = c.y - a.y, v1z = c.z - a.z;   // Vector3Subtract(c, a)
    double v2x = p.x - a.x, v2y = p.y - a.y, v2z = p.z - a.z;   // Vector3Subtract(p, a)

    double d00 = (v0x*v0x + v0y*v0y + v0z*v0z);    // Vector3DotProduct(v0, v0)
    double d01 = (v0x*v1x + v0y*v1y + v0z*v1z);    // Vector3DotProduct(v0, v1)
    double d11 = (v1x*v1x + v1y*v1y + v1z*v1z);    // Vector3DotProduct(v1, v1)
    double d20 = (v2x*v0x + v2y*v0y + v2z*v0z);    // Vector3DotProduct(v2, v0)
    double d21 = (v2x*v1x + v2y*v1y + v2z*v1z);    // Vector3DotProduct(v2, v1)

    double denom = d00*d11 - d01*d01;

    result.y = (d11*d20 - d01*d21)/denom;
    result.z = (d00*d21 - d01*d20)/denom;
    result.x = 1.0 - (result.z + result.y);

    return result;
  }

  /// Projects a Vector3 from screen space into object space
  /// 
  /// NOTE: Self-contained function, no other raymath functions are called
  Vector3 Unproject(Vector3 source, Matrix projection, Matrix view)
  {
    Vector3 result = Vector3();

    var matViewProj = [ // MatrixMultiply(view, projection);
      view.m0*projection.m0 + view.m1*projection.m4 + view.m2*projection.m8 + view.m3*projection.m12,
      view.m0*projection.m1 + view.m1*projection.m5 + view.m2*projection.m9 + view.m3*projection.m13,
      view.m0*projection.m2 + view.m1*projection.m6 + view.m2*projection.m10 + view.m3*projection.m14,
      view.m0*projection.m3 + view.m1*projection.m7 + view.m2*projection.m11 + view.m3*projection.m15,
      view.m4*projection.m0 + view.m5*projection.m4 + view.m6*projection.m8 + view.m7*projection.m12,
      view.m4*projection.m1 + view.m5*projection.m5 + view.m6*projection.m9 + view.m7*projection.m13,
      view.m4*projection.m2 + view.m5*projection.m6 + view.m6*projection.m10 + view.m7*projection.m14,
      view.m4*projection.m3 + view.m5*projection.m7 + view.m6*projection.m11 + view.m7*projection.m15,
      view.m8*projection.m0 + view.m9*projection.m4 + view.m10*projection.m8 + view.m11*projection.m12,
      view.m8*projection.m1 + view.m9*projection.m5 + view.m10*projection.m9 + view.m11*projection.m13,
      view.m8*projection.m2 + view.m9*projection.m6 + view.m10*projection.m10 + view.m11*projection.m14,
      view.m8*projection.m3 + view.m9*projection.m7 + view.m10*projection.m11 + view.m11*projection.m15,
      view.m12*projection.m0 + view.m13*projection.m4 + view.m14*projection.m8 + view.m15*projection.m12,
      view.m12*projection.m1 + view.m13*projection.m5 + view.m14*projection.m9 + view.m15*projection.m13,
      view.m12*projection.m2 + view.m13*projection.m6 + view.m14*projection.m10 + view.m15*projection.m14,
      view.m12*projection.m3 + view.m13*projection.m7 + view.m14*projection.m11 + view.m15*projection.m15
    ];

    // Calculate inverted matrix -> MatrixInvert(matViewProj);
    // Cache the matrix values (speed optimization)
    double a00 = matViewProj[0],  a01 = matViewProj[1],  a02 = matViewProj[2],  a03 = matViewProj[3];
    double a10 = matViewProj[4],  a11 = matViewProj[5],  a12 = matViewProj[6],  a13 = matViewProj[7];
    double a20 = matViewProj[8],  a21 = matViewProj[9],  a22 = matViewProj[10], a23 = matViewProj[11];
    double a30 = matViewProj[12], a31 = matViewProj[13], a32 = matViewProj[14], a33 = matViewProj[15];

    double b00 = a00*a11 - a01*a10;
    double b01 = a00*a12 - a02*a10;
    double b02 = a00*a13 - a03*a10;
    double b03 = a01*a12 - a02*a11;
    double b04 = a01*a13 - a03*a11;
    double b05 = a02*a13 - a03*a12;
    double b06 = a20*a31 - a21*a30;
    double b07 = a20*a32 - a22*a30;
    double b08 = a20*a33 - a23*a30;
    double b09 = a21*a32 - a22*a31;
    double b10 = a21*a33 - a23*a31;
    double b11 = a22*a33 - a23*a32;

    // Calculate the invert determinant (inlined to avoid double-caching)
    double invDet = 1.0/(b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);

    var matViewProjInv = [
      (a11*b11 - a12*b10 + a13*b09)*invDet,
      (-a01*b11 + a02*b10 - a03*b09)*invDet,
      (a31*b05 - a32*b04 + a33*b03)*invDet,
      (-a21*b05 + a22*b04 - a23*b03)*invDet,
      (-a10*b11 + a12*b08 - a13*b07)*invDet,
      (a00*b11 - a02*b08 + a03*b07)*invDet,
      (-a30*b05 + a32*b02 - a33*b01)*invDet,
      (a20*b05 - a22*b02 + a23*b01)*invDet,
      (a10*b10 - a11*b08 + a13*b06)*invDet,
      (-a00*b10 + a01*b08 - a03*b06)*invDet,
      (a30*b04 - a31*b02 + a33*b00)*invDet,
      (-a20*b04 + a21*b02 - a23*b00)*invDet,
      (-a10*b09 + a11*b07 - a12*b06)*invDet,
      (a00*b09 - a01*b07 + a02*b06)*invDet,
      (-a30*b03 + a31*b01 - a32*b00)*invDet,
      (a20*b03 - a21*b01 + a22*b00)*invDet
    ];

    // Create quaternion from source point
    double quatx = source.x, quaty = source.y, quatz = source.z, quatw = 1.0;

    // Multiply quat point by unprojecte matrix
    // QuaternionTransform(quat, matViewProjInv)
    double qtx = matViewProjInv[0]*quatx + matViewProjInv[4]*quaty + matViewProjInv[8]*quatz + matViewProjInv[12]*quatw;
    double qty = matViewProjInv[1]*quatx + matViewProjInv[5]*quaty + matViewProjInv[9]*quatz + matViewProjInv[13]*quatw;
    double qtz = matViewProjInv[2]*quatx + matViewProjInv[6]*quaty + matViewProjInv[10]*quatz + matViewProjInv[14]*quatw;
    double qtw = matViewProjInv[3]*quatx + matViewProjInv[7]*quaty + matViewProjInv[11]*quatz + matViewProjInv[15]*quatw;

    // Normalized world points in vectors
    result.x = qtx/qtw;
    result.y = qty/qtw;
    result.z = qtz/qtw;

    return result;
  }

  /// Check whether two given vectors are almost equal
  bool Equals(Vector3 p, Vector3 q)
  {
    return (((p.x - q.x).abs()) <= (EPSILON*math.max(1.0, math.max((p.x).abs(), (q.x).abs())))) &&
           (((p.y - q.y).abs()) <= (EPSILON*math.max(1.0, math.max((p.y).abs(), (q.y).abs())))) &&
           (((p.z - q.z).abs()) <= (EPSILON*math.max(1.0, math.max((p.z).abs(), (q.z).abs()))));
  }

  /// Compute the direction of a refracted ray
  /// 
  /// v: normalized direction of the incoming ray
  /// 
  /// n: normalized normal vector of the interface of two optical media
  /// 
  /// r: ratio of the refractive index of the medium from where the ray comes
  /// 
  /// to the refractive index of the medium on the other side of the surface
  /// 
  Vector3 Refract(Vector3 v, Vector3 n, double r)
  {
    Vector3 result = Vector3();

    double dot = v.x*n.x + v.y*n.y + v.z*n.z;
    double d = 1.0 - r*r*(1.0 - dot*dot);

    if (d >= 0.0)
    {
      d = math.sqrt(d);
      v.x = r*v.x - (r*dot + d)*n.x;
      v.y = r*v.y - (r*dot + d)*n.y;
      v.z = r*v.z - (r*dot + d)*n.z;

      result = v;
    }

    return result;
  }

  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _memory!.dispose();
      _finalizer.detach(this);
    }
  }
}

extension Vector3Math on Vector3
{
  /// Add two vectors (v1 + v2) - In-place
  void Add(Vector3 v2) {
    this.x += v2.x;
    this.y += v2.y;
    this.z += v2.z;
  }

  /// Returns a new vector as the sum of this and v2
  Vector3 operator +(Vector3 v2) => Vector3(this.x + v2.x, this.y + v2.y, this.z + v2.z);

  /// Subtract two vectors (v1 - v2) - In-place
  void Subtract(Vector3 v2) {
    this.x -= v2.x;
    this.y -= v2.y;
    this.z -= v2.z;
  }

  /// Returns a new vector as the difference of this and v2
  Vector3 operator -(Vector3 v2) => Vector3(this.x - v2.x, this.y - v2.y, this.z - v2.z);

  /// Add vector and float value
  void AddValue(double add)
  {
    this.x += add;
    this.y += add;
    this.z += add;
  }

  /// Subtract vector by float value
  void SubtractValue(double add)
  {
    this.x -= add;
    this.y -= add;
    this.z -= add;
  }

  /// Multiply vector by scalar
  void Scale(double scale)
  {
    this.x *= scale;
    this.y *= scale;
    this.z *= scale;
  }

  /// Multiply `this` by `v2` (In-place)
  void Multiply(Vector3 v2)
  {
    this.x *= v2.x;
    this.y *= v2.y;
    this.z *= v2.z;
  }
  /// Returns the product of x, y, and z of `this` vector and `other` vector (New instance)
  Vector3 operator *(Vector3 other) => Vector3(this.x*other.x, this.y*other.y, this.z*other.z);

  /// Calculate vector length
  double Length() => math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);
  /// Calculate vector square length
  double DotProduct(Vector3 v) => (this.x*v.x + this.y*v.y + this.z*v.z);
  /// Calculate two vectors dot product
  double LengthSqr() => (this.x*this.x + this.y*this.y + this.z*this.z);
  /// Negate provided vector (invert direction)
  void Negate()
  {
    this.x *= -1;
    this.y *= -1;
    this.z *= -1;
  }

  /// Divides `this` by `v2` (In-place)
  void Divide(Vector3 v2) {
    this.x /= v2.x;
    this.y /= v2.y;
    this.z /= v2.z;
  }

  /// Returns the quotient of x, y, and z of `this` vector and `other` vector (New instance)
  Vector3 operator /(Vector3 other) => Vector3(this.x / other.x, this.y / other.y, this.z / other.z);

  /// Normalize provided vector
  void Normalize()
  {
    double length = math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z);
    
    if (length != 0.0)
    {
      double ilength = 1.0 / length;

      this.x *= ilength;
      this.y *= ilength;
      this.z *= ilength;
    }
  }

  /// Transform a vector by quaternion rotation
  void RotateByQuaternion(Quaternion q)
  {
    double dx = this.x, dy = this.y, dz = this.z;
    double qx = q.x, qy = q.y, qz = q.z, qw = q.w;

    this.x = dx*(qx*qx + qw*qw - qy*qy - qz*qz) + dy*(2*qx*qy - 2*qw*qz) + dz*(2*qx*qz + 2*qw*qy);
    this.y = dx*(2*qw*qz + 2*qx*qy) + dy*(qw*qw - qx*qx + qy*qy - qz*qz) + dz*(-2*qw*qx + 2*qy*qz);
    this.z = dx*(-2*qw*qy + 2*qx*qz) + dy*(2*qw*qx + 2*qy*qz) + dz*(qw*qw - qx*qx - qy*qy + qz*qz);
  }

  /// Transforms a Vector3 by a given Matrix
  void Transform(Matrix mat)
  {
    double x = this.x, y = this.y, z = this.z;

    this.x = mat.m0*x + mat.m4*y + mat.m8*z + mat.m12;
    this.y = mat.m1*x + mat.m5*y + mat.m9*z + mat.m13;
    this.z = mat.m2*x + mat.m6*y + mat.m10*z + mat.m14;
  }

  /// Rotates a vector around an axis
  void RotateByAxisAngle(Vector3 axis, double angle)
  {
    double vx = this.x, vy = this.y, vz = this.z;
    double ax = axis.x, ay = axis.y, az = axis.z;

    double length = math.sqrt(ax*ax + ay*ay + az*az);
    if (length == 0.0) return;
    double ilength = 1.0 / length;
    ax *= ilength; ay *= ilength; az *= ilength;

    angle /= 2.0;
    double a = math.sin(angle);
    double wx = ax*a;
    double wy = ay*a;
    double wz = az*a;
    a = math.cos(angle);

    // Vector3CrossProduct(w, v)
    double wvx = wy*vz - wz*vy;
    double wvy = wz*vx - wx*vz;
    double wvz = wx*vy - wy*vx;

    // Vector3CrossProduct(w, wv)
    double wwvx = wy*wvz - wz*wvy;
    double wwvy = wz*wvx - wx*wvz;
    double wwvz = wx*wvy - wy*wvx;

    // Vector3Scale(wwv, 2)
    wwvx *= 2;
    wwvy *= 2;
    wwvz *= 2;
    this.x += wvx + wwvx;
    this.y += wvy + wwvy;
    this.z += wvz + wwvz;
  }

  /// Move Vector towards target
  void MoveTowards(Vector3 target, double maxDistance)
  {
    double dx = target.x - this.x;
    double dy = target.y - this.y;
    double dz = target.z - this.z;
    double value = (dx*dx) + (dy*dy) + (dz*dz);

    if (value == 0.0) return;
    
    if (maxDistance >= 0 && value <= maxDistance*maxDistance)
    {
      this.x = target.x;
      this.y = target.y;
      this.z = target.z;
      return;
    }

    double dist = math.sqrt(value);

    this.x += dx/dist*maxDistance;
    this.y += dy/dist*maxDistance;
    this.z += dz/dist*maxDistance;
  }

  /// Calculate linear interpolation between two vectors (In Place)
  void Lerp(Vector3 v2, double amount)
  {
    this.x += amount*(v2.x - this.x);
    this.y += amount*(v2.y - this.y);
    this.z += amount*(v2.z - this.z);
  }

  /// Invert the given vector
  void Invert()
  {
    this.x = 1.0/this.x;
    this.y = 1.0/this.y;
    this.z = 1.0/this.z;
  }

  /// Clamp the components of the vector between
  /// 
  /// min and max values specified by the given vectors
  void Clamp(Vector3 min, Vector3 max)
  {
    this.x = math.min(max.x, math.max(min.x, this.x));
    this.y = math.min(max.y, math.max(min.y, this.y));
    this.z = math.min(max.z, math.max(min.z, this.z));
  }

  void ClampValue(double min, double max)
  {
    double length = (this.x*this.x) + (this.y*this.y) + (this.z*this.z);
    if (length > 0.0)
    {
      length = math.sqrt(length);

      double scale = 1;    // By default, 1 as the neutral element.
      if (length < min)
      {
        scale = min/length;
      }
      else if (length > max)
      {
        scale = max/length;
      }

      this.x*=scale;
      this.y*=scale;
      this.z*=scale;
    }
  }
}

//----------------------------------------------------------------------------------
/// Module Functions Definition - Vector4 math
//----------------------------------------------------------------------------------
class Vector4 implements Disposeable
{
  NativeResource<_Vector4>? _memory;

  // ignore: unused_element
  void _setmemory(_Vector4 result)
  {
    Pointer<_Vector4> pointer = malloc.allocate<_Vector4>(sizeOf<_Vector4>());
    pointer.ref
    ..x = result.x
    ..y = result.y
    ..z = result.z
    ..w = result.w;

    _memory = NativeResource(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  Vector4._recieve(_Vector4 result) { _setmemory(result); }

  Vector4._internal(Pointer<_Vector4> pointer)
  {
    _memory = NativeResource(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  _Vector4 get ref => _memory!.pointer.ref;

  set ref (_Vector4 v) => _memory!.pointer.ref = v;

  double get x => _memory!.pointer.ref.x;
  double get y => _memory!.pointer.ref.y;
  double get z => _memory!.pointer.ref.z;
  double get w => _memory!.pointer.ref.w;

  set x(double value) => _memory!.pointer.ref.x = value;
  set y(double value) => _memory!.pointer.ref.y = value;
  set z(double value) => _memory!.pointer.ref.z = value;
  set w(double value) => _memory!.pointer.ref.w = value;

  void Set([double x = 0.0, double y = 0.0, double z = 0.0, double w = 0.0])
  {
    this.ref
    ..x = x
    ..y = y
    ..z = z
    ..w = w;
  }

  Vector4([double x = 0.0, double y = 0.0, double z = 0.0, double w = 0.0])
  {
    Pointer<_Vector4> pointer = malloc.allocate<_Vector4>(sizeOf<_Vector4>());
    pointer.ref
    ..x = x
    ..y = y
    ..z = z
    ..w = w;

    _memory = NativeResource(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  factory Vector4.Zero() => Vector4();

  factory Vector4.One() => Vector4(1.0, 1.0, 1.0, 1.0);

  static double DotProduct(Vector4 v1, Vector4 v2) => (v1.x*v2.x + v1.y*v2.y + v1.z*v2.z + v1.w*v2.w);

  /// Calculate distance between two vectors
  static double Distance(Vector4 v1, Vector4 v2)
  {
    return math.sqrt(
      (v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) +
      (v1.z - v2.z)*(v1.z - v2.z) + (v1.w - v2.w)*(v1.w - v2.w)
    );
  }

  /// Calculate square distance between two vectors
  static double DistanceSqr(Vector4 v1, Vector4 v2)
  {
    return (
      (v1.x - v2.x)*(v1.x - v2.x) + (v1.y - v2.y)*(v1.y - v2.y) +
      (v1.z - v2.z)*(v1.z - v2.z) + (v1.w - v2.w)*(v1.w - v2.w)
    );
  }

  /// Get min value for each pair of components
  /// 
  /// Creates new instance
  static Vector4 Min(Vector4 v1, Vector4 v2)
  {
    Vector4 result = Vector4();

    result.x = math.min(v1.x, v2.x);
    result.y = math.min(v1.y, v2.y);
    result.z = math.min(v1.z, v2.z);
    result.w = math.min(v1.w, v2.w);

    return result;
  }

  /// Get max value for each pair of components
  /// 
  /// Creates new instance
  static Vector4 Max(Vector4 v1, Vector4 v2)
  {
    Vector4 result = Vector4();

    result.x = math.max(v1.x, v2.x);
    result.y = math.max(v1.y, v2.y);
    result.z = math.max(v1.z, v2.z);
    result.w = math.max(v1.w, v2.w);

    return result;
  }

  /// Check whether two given vectors are almost equal
  static bool Equals(Vector4 p, Vector4 q)
  {
    return ((p.x - q.x).abs() <= (EPSILON * math.max(1.0, math.max(p.x.abs(), q.x.abs())))) &&
           ((p.y - q.y).abs() <= (EPSILON * math.max(1.0, math.max(p.y.abs(), q.y.abs())))) &&
           ((p.z - q.z).abs() <= (EPSILON * math.max(1.0, math.max(p.z.abs(), q.z.abs())))) &&
           ((p.w - q.w).abs() <= (EPSILON * math.max(1.0, math.max(p.w.abs(), q.w.abs()))));
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Vector4>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

extension Vector4Math on Vector4
{
  void Add(Vector4 v)
  {
    this.x += v.x;
    this.y += v.y;
    this.z += v.z;
    this.w += v.w;
  }

  Vector4 operator+(Vector4 v2) => Vector4(this.x+v2.x, this.y+v2.y, this.z+v2.z, this.w+v2.w);

  void AddValue(double add)
  {
    this.x += add;
    this.y += add;
    this.z += add;
    this.w += add;
  }

  void Subtract(Vector4 v)
  {
    this.x -= v.x;
    this.y -= v.y;
    this.z -= v.z;
    this.w -= v.w;
  }

  Vector4 operator-(Vector4 v2) => Vector4(this.x-v2.x, this.y-v2.y, this.z-v2.z, this.w-v2.w);

  void SubtractValue(double sub)
  {
    this.x -= sub;
    this.y -= sub;
    this.z -= sub;
    this.w -= sub;
  }

  double Length() => math.sqrt((this.x*this.x) + (this.y*this.y) + (this.z*this.z));

  double LengthSqr() => (this.x*this.x) + (this.y*this.y) + (this.z*this.z);

  void Scale(double scale)
  {
    this.x *= scale;
    this.y *= scale;
    this.z *= scale;
    this.w *= scale;
  }

  // Multiplies `this` vector by `other`
  void Multiply(Vector4 other)
  {
    this.x *= other.x;
    this.y *= other.y;
    this.z *= other.z;
    this.w *= other.w;
  }

  /// Multiply vector by vector
  Vector4 operator *(Vector4 v) => Vector4(this.x*v.x, this.y*v.y, this.z*v.z, this.w*v.w);

  /// Negate vector
  void Negate()
  {
    this.x *= -1;
    this.y *= -1;
    this.z *= -1;
    this.w *= -1;
  }

  /// Divides `this` vector by `other` (In-place)
  void Divide(Vector4 other) {
    if (other.x == 0 || other.y == 0 || other.z == 0 || other.w == 0) throw Exception("Division by zero!");

    this.x /= other.x;
    this.y /= other.y;
    this.z /= other.z;
    this.w /= other.w;
  }

  /// Divide vector by vector (New instance)
  Vector4 operator /(Vector4 v) => Vector4(this.x/v.x, this.y/v.y, this.z/v.z, this.w/v.w);

  /// Normalize provided vector
  void Normalize()
  {
    double length = math.sqrt((this.x*this.x) + (this.y*this.y) + (this.z*this.z) + (this.w*this.w));

    if (length > 0)
    {
      double ilength = 1.0 / length;

      this.x *= ilength;
      this.y *= ilength;
      this.z *= ilength;
      this.w *= ilength;
    }
  }

  /// Calculate linear interpolation between two vectors
  void Lerp(Vector4 v2, double ammount)
  {
    this.x = this.x + ammount*(v2.x - this.x);
    this.y = this.y + ammount*(v2.y - this.y);
    this.z = this.z + ammount*(v2.z - this.z);
    this.w = this.w + ammount*(v2.w - this.w);
  }

  /// Move Vector towards target
  void MoveTowards(Vector4 target, double maxDistance)
  {
    double dx = target.x - this.x;
    double dy = target.y - this.y;
    double dz = target.z - this.z;
    double dw = target.w - this.w;
    double value = (dx*dx) + (dy*dy) + (dz*dz) + (dw*dw);

    if ((value == 0) || ((maxDistance >= 0) && (value <= maxDistance*maxDistance))) return;

    double dist = math.sqrt(value);

    this.x += dx/dist*maxDistance;
    this.y += dx/dist*maxDistance;
    this.z += dx/dist*maxDistance;
    this.w += dx/dist*maxDistance;
  }

  /// Invert the given vector
  void Invert()
  {
    this.x = 1.0 / this.x;
    this.y = 1.0 / this.y;
    this.z = 1.0 / this.z;
    this.w = 1.0 / this.w;
  }
}
//------------------------------------------------------------------------------------
/// Module Functions Definition - Quaternion math
//------------------------------------------------------------------------------------

class Quaternion extends Vector4
{
  Quaternion._internal(Pointer<_Quaternion> pointer) : super._internal(pointer);

  factory Quaternion([double x = 0.0, double y = 0.0, double z = 0.0, double w = 1.0])
  {
    Pointer<_Quaternion> pointer = malloc.allocate<_Quaternion>(sizeOf<_Quaternion>());
    pointer.ref
    ..x = x
    ..y = y
    ..z = z
    ..w = w;

    return Quaternion._internal(pointer);
  }

  /// Calculate quaternion cubic spline interpolation using Cubic Hermite Spline algorithm
  /// as described in the GLTF 2.0 specification: https://registry.khronos.org/glTF/specs/2.0/glTF-2.0.html#interpolation-cubic
  static Quaternion CubicHermiteSpline({
    required Quaternion q1, required Quaternion outTan1,
    required Quaternion q2, required Quaternion inTan2,
    required double t
  }) {
    double t2 = t*t;
    double t3 = t2*t;
    double h00 = 2*t3 - 3*t2 + 1;
    double h10 = t3 - 2*t2 + t;
    double h01 = -2*t3 + 3*t2;
    double h11 = t3 - t2;

    Quaternion result = Quaternion();
    result.x = h00*q1.x + h10*outTan1.x + h01*q2.x + h11*inTan2.x;
    result.y = h00*q1.y + h10*outTan1.y + h01*q2.y + h11*inTan2.y;
    result.z = h00*q1.z + h10*outTan1.z + h01*q2.z + h11*inTan2.z;
    result.w = h00*q1.w + h10*outTan1.w + h01*q2.w + h11*inTan2.w;

    result.Normalize();

    return result;
  }

  /// Calculate quaternion based on the rotation from one vector to another
  /// 
  /// Note: AI warned about passing oposite vectors
  static Quaternion FromVector3ToVector3(Vector3 from, Vector3 to)
  {
    Quaternion result = Quaternion();

    double cos2Theta = (from.x*to.x + from.y*to.y + from.z*to.z); // Vector3DotProduct(from, to)
    Vector3 cross = Vector3(from.y*to.z - from.z*to.y, from.z*to.x - from.x*to.z, from.x*to.y - from.y*to.x); // Vector3CrossProduct(from, to)

    result.x = cross.x;
    result.y = cross.y;
    result.z = cross.z;
    result.w = math.sqrt(cross.x*cross.x + cross.y*cross.y + cross.z*cross.z + cos2Theta*cos2Theta) + cos2Theta;

    // QuaternionNormalize(q);
    // NOTE: Normalize to essentially nlerp the original and identity to 0.5
    Quaternion q = result;
    double length = math.sqrt(q.x*q.x + q.y*q.y + q.z*q.z + q.w*q.w);
    if (length == 0.0) length = 1.0;
    double ilength = 1.0/length;

    result.x = q.x*ilength;
    result.y = q.y*ilength;
    result.z = q.z*ilength;
    result.w = q.w*ilength;

    return result;
  }

  /// Get a quaternion for a given rotation matrix
  static Quaternion FromMatrix(Matrix matrix)
  {
    Quaternion result = Quaternion();

    double fourWSquaredMinus1 = matrix.m0  + matrix.m5 + matrix.m10;
    double fourXSquaredMinus1 = matrix.m0  - matrix.m5 - matrix.m10;
    double fourYSquaredMinus1 = matrix.m5  - matrix.m0 - matrix.m10;
    double fourZSquaredMinus1 = matrix.m10 - matrix.m0 - matrix.m5;

    int biggestIndex = 0;
    double fourBiggestSquaredMinus1 = fourWSquaredMinus1;
    if (fourXSquaredMinus1 > fourBiggestSquaredMinus1)
    {
      fourBiggestSquaredMinus1 = fourXSquaredMinus1;
      biggestIndex = 1;
    }

    if (fourYSquaredMinus1 > fourBiggestSquaredMinus1)
    {
      fourBiggestSquaredMinus1 = fourYSquaredMinus1;
      biggestIndex = 2;
    }

    if (fourZSquaredMinus1 > fourBiggestSquaredMinus1)
    {
      fourBiggestSquaredMinus1 = fourZSquaredMinus1;
      biggestIndex = 3;
    }

    double biggestVal = math.sqrt(fourBiggestSquaredMinus1 + 1.0)*0.5;
    double mult = 0.25/biggestVal;

    // Caching values to avoid multiple accesses through FFI
    double m1 = matrix.m1, m2 = matrix.m2, m4 = matrix.m4;
    double m6 = matrix.m6, m8 = matrix.m8, m9 = matrix.m9;

    switch (biggestIndex)
    {
    case 0:
      result.w = biggestVal;
      result.x = (m6 - m9)*mult;
      result.y = (m8 - m2)*mult;
      result.z = (m1 - m4)*mult;
      break;
    case 1:
      result.x = biggestVal;
      result.w = (m6 - m9)*mult;
      result.y = (m1 + m4)*mult;
      result.z = (m8 + m2)*mult;
      break;
    case 2:
      result.y = biggestVal;
      result.w = (m8 - m2)*mult;
      result.x = (m1 + m4)*mult;
      result.z = (m6 + m9)*mult;
      break;
    case 3:
      result.z = biggestVal;
      result.w = (m1 - m4)*mult;
      result.x = (m8 + m2)*mult;
      result.y = (m6 + m9)*mult;
      break;
    }

    return result;
  }

  /// Get identity quaternion
  factory Quaternion.Identity() => Quaternion();
  
  /// Get rotation quaternion for an angle and axis
  /// 
  /// NOTE: Angle must be provided in radians
  /// 
  /// Dev Note: This function was adapted, proceed with caution. _I am tired_
  static Quaternion FromAxisAngle(Vector3 axis, double angle)
  {
    Quaternion result = Quaternion();

    double axisLength = math.sqrt(axis.x*axis.x + axis.y*axis.y + axis.z*axis.z);

    if (axisLength != 0)
    {
      angle *= 0.5;

      double length = 0.0;
      double ilength = 0.0;

      // Caching values to prevent modifying original instance
      // Vector3Normalize(axis)
      double iaxisLen = 1.0 / axisLength;
      double ax = axis.x * iaxisLen;
      double ay = axis.y * iaxisLen;
      double az = axis.z * iaxisLen;

      double sinres = math.sin(angle);
      double cosres = math.cos(angle);

      result.x = ax*sinres;
      result.y = ay*sinres;
      result.z = az*sinres;
      result.w = cosres;

      length = math.sqrt(result.x*result.x + result.y*result.y + result.z*result.z + result.w*result.w);
      if (length == 0.0) length = 1.0;
      ilength = 1.0/length;
      result.x = result.x*ilength;
      result.y = result.y*ilength;
      result.z = result.z*ilength;
      result.w = result.w*ilength;
    }

    return result;
  }

  /// Get the rotation angle and axis for a given quaternion
  /// 
  /// Dev note: primitive tipes aren't passed by reference. Prepare a variable to get the return angle
  double ToAxisAngle(Vector3 outAxis, double outAngle)
  {
    double qx = this.x, qy = this.y,
           qz = this.z, qw = this.w;

    if (qw  > 1.0)
    {
      // QuaternionNormalize(q);
      double length = math.sqrt(qx*qx + qy*qy + qz*qz + qw*qw);
      if (length == 0.0) length = 1.0;
      double ilength = 1.0 / length;

      qx = qx*ilength;
      qy = qy*ilength;
      qz = qz*ilength;
      qw = qw*ilength;
    }

    double resAxisX = 0.0, resAxisY = 0.0, resAxisZ = 0.0;

    double resAngle = 2.0*math.acos(qw);
    double den = math.sqrt(1.0 - qw*qw);

    if (den > EPSILON)
    {
      resAxisX = qx/den;
      resAxisY = qy/den;
      resAxisZ = qz/den;
    }
    else
    {
      // This occurs when the angle is zero.
      // Not a problem: just set an arbitrary normalized axis.
      resAxisX = 1.0;
    }

    outAxis.Set(resAxisX, resAxisY, resAxisZ);
    return resAngle;
  }

  /// Get the quaternion equivalent to Euler angles
  /// 
  /// NOTE: Rotation order is ZYX
  static Quaternion FromEuler({required double pitch, required double yaw, required double roll})
  {
    Quaternion result = Quaternion();

    double x0 = math.cos(pitch*0.5);
    double x1 = math.sin(pitch*0.5);
    double y0 = math.cos(yaw*0.5);
    double y1 = math.sin(yaw*0.5);
    double z0 = math.cos(roll*0.5);
    double z1 = math.sin(roll*0.5);

    result.x = x1*y0*z0 - x0*y1*z1;
    result.y = x0*y1*z0 + x1*y0*z1;
    result.z = x0*y0*z1 - x1*y1*z0;
    result.w = x0*y0*z0 + x1*y1*z1;

    return result;
  }

  /// Check whether two given quaternions are almost equal
  bool Equals(Quaternion p, Quaternion q)
  {
    double px = p.x, py = p.y, pz = p.z, pw = p.w;
    double qx = q.x, qy = q.y, qz = q.z, qw = q.w;

    return ((((px - qx).abs()) <= (EPSILON*math.max(1.0, math.max((px).abs(), (qx).abs())))) &&
            (((py - qy).abs()) <= (EPSILON*math.max(1.0, math.max((py).abs(), (qy).abs())))) &&
            (((pz - qz).abs()) <= (EPSILON*math.max(1.0, math.max((pz).abs(), (qz).abs())))) &&
            (((pw - qw).abs()) <= (EPSILON*math.max(1.0, math.max((pw).abs(), (qw).abs()))))) ||
            ((((px + qx).abs()) <= (EPSILON*math.max(1.0, math.max((px).abs(), (qx).abs())))) &&
            (((py + qy).abs()) <= (EPSILON*math.max(1.0, math.max((py).abs(), (qy).abs())))) &&
            (((pz + qz).abs()) <= (EPSILON*math.max(1.0, math.max((pz).abs(), (qz).abs())))) &&
            (((pw + qw).abs()) <= (EPSILON*math.max(1.0, math.max((pw).abs(), (qw).abs())))));
  }
}

extension QuaternionMath on Quaternion
{
  /// Add two quaternions (In place)
  void Add(Quaternion q)
  {
    this.x += q.x;
    this.y += q.y;
    this.z += q.z;
    this.w += q.w;
  }

  /// Add two quaternions (New Instance)
  Quaternion operator +(Quaternion q) {
    Quaternion result = Quaternion(); 

    result.x = this.x + q.x;
    result.y = this.y + q.y;
    result.z = this.z + q.z;
    result.w = this.w + q.w;
    return result;
  }

  /// Add quaternion and double value
  void AddValue(double add) { this.x += add; this.y += add; this.z += add; this.w += add; }

  /// Add two quaternions (In place)
  void Subtract(Quaternion q)
  {
    this.x -= q.x;
    this.y -= q.y;
    this.z -= q.z;
    this.w -= q.w;
  }
  
  /// Add two quaternions (New Instance)
  Quaternion operator -(Quaternion q)
  {
    Quaternion result = Quaternion();

    result.x = this.x - q.x;
    result.y = this.y - q.y;
    result.z = this.z - q.z;
    result.w = this.w - q.w;

    return result;
  }

  /// Subtract quaternion and double value
  void SubtractValue(double sub) { this.x -= sub; this.y -= sub; this.z -= sub; this.w -= sub; }

  /// Computes the length of a quaternion
  double Length() => math.sqrt((this.x*this.x) + (this.y*this.y) + (this.z*this.z) + (this.w*this.w));

  /// Normalize provided quaternion
  void Normalize()
  {
    double length = math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z + this.w*this.w);
    if (length == 0.0) length = 1.0;
    double ilength = 1.0/length;

    double qx = this.x, qy = this.y;
    double qz = this.z, qw = this.w;

    this.x = qx*ilength;
    this.y = qy*ilength;
    this.z = qz*ilength;
    this.w = qw*ilength;
  }

  /// Invert provided quaternion
  void Invert()
  {
    double lengthSq = this.x*this.x + this.y*this.y + this.z*this.z + this.w*this.w;

    if (lengthSq != 0.0)
    {
      double ilength = 1.0/lengthSq;

      this.x *= -ilength;
      this.y *= -ilength;
      this.z *= -ilength;
      this.w *=  ilength;
    }
  }

  /// Calculate two quaternion multiplication (In place)
  void Multiply(Quaternion q)
  {
    double qax = this.x, qay = this.y, qaz = this.z, qaw = this.w;
    double qbx = q.x, qby = q.y, qbz = q.z, qbw = q.w;

    this.x = qax*qbw + qaw*qbx + qay*qbz - qaz*qby;
    this.y = qay*qbw + qaw*qby + qaz*qbx - qax*qbz;
    this.z = qaz*qbw + qaw*qbz + qax*qby - qay*qbx;
    this.w = qaw*qbw - qax*qbx - qay*qby - qaz*qbz;
  }

  /// Calculate two quaternion multiplication (New Instance)
  Quaternion operator *(Quaternion q)
  {
    Quaternion result = Quaternion();

    double qax = this.x, qay = this.y, qaz = this.z, qaw = this.w;
    double qbx = q.x, qby = q.y, qbz = q.z, qbw = q.w;

    result.x = qax*qbw + qaw*qbx + qay*qbz - qaz*qby;
    result.y = qay*qbw + qaw*qby + qaz*qbx - qax*qbz;
    result.z = qaz*qbw + qaw*qbz + qax*qby - qay*qbx;
    result.w = qaw*qbw - qax*qbx - qay*qby - qaz*qbz;

    return result;
  }

  /// Scale quaternion by float value
  void Scale(double value)
  {
    this.x *= value;
    this.y *= value;
    this.z *= value;
    this.w *= value;
  }

  /// Divide `this` quatertnion by `q` quatertnion
  void Divide(Quaternion q) { this.x/=q.x; this.y/=q.y; this.z/=q.z; this.w/=q.w; }

  /// Calculate linear interpolation between two quaternions
  void Lerp(Quaternion q2, double amount)
  {
    double qx = this.x, qy = this.y;
    double qz = this.z, qw = this.w;

    this.x = qx + amount*(q2.x - qx);
    this.y = qy + amount*(q2.y - qy);
    this.z = qz + amount*(q2.z - qz);
    this.w = qw + amount*(q2.w - qw);
  }
  
  /// Calculate slerp-optimized interpolation between two quaternions
  void NLerp(Quaternion q2, double amount)
  {
    double qx = this.x, qy = this.y;
    double qz = this.z, qw = this.w;

    this.x = qx + amount*(q2.x - qx);
    this.y = qy + amount*(q2.y - qy);
    this.z = qz + amount*(q2.z - qz);
    this.w = qw + amount*(q2.w - qw);

    double length = math.sqrt(this.x*this.x + this.y*this.y + this.z*this.z + this.w*this.w);
    if (length == 0.0) length = 1.0;
    double ilength = 1.0/length;

    this.x *= ilength;
    this.y *= ilength;
    this.z *= ilength;
    this.w *= ilength;
  }

  /// Calculates spherical linear interpolation between two quaternions
  void Slerp(Quaternion q2, double amount)
  {
    double cosHalfTheta = this.x*q2.x + this.y*q2.y + this.z*q2.z + this.w*q2.w;
    // Not to modify the original instance
    double q2x = q2.x, q2y = q2.y, q2z = q2.z, q2w = q2.w;

    if (cosHalfTheta < 0)
    {
      q2x = -q2x; q2y = -q2y; q2z = -q2z; q2w = -q2w;
      cosHalfTheta = -cosHalfTheta;
    }

    if (cosHalfTheta.abs() >= 1.0) return;
    else if (cosHalfTheta > 0.95) // Since arguments are passed as references, Gemini suggested not passing this q2 as parameter
    {
      this.x = x + amount*(q2x - x);
      this.y = y + amount*(q2y - y);
      this.z = z + amount*(q2z - z);
      this.w = w + amount*(q2w - w);

      this.Normalize();
    }
    else
    {
      double halfTheta = math.acos(cosHalfTheta);
      double sinHalfTheta = math.sqrt(1.0 - cosHalfTheta*cosHalfTheta);
      double q1x = this.x, q1y = this.y;
      double q1z = this.z, q1w = this.w;

      if (sinHalfTheta.abs() < EPSILON)
      {
        this.x = (q1x*0.5 + q2x*0.5);
        this.y = (q1y*0.5 + q2y*0.5);
        this.z = (q1z*0.5 + q2z*0.5);
        this.w = (q1w*0.5 + q2w*0.5);
      }
      else
      {
        double ratioA = math.sin((1 - amount)*halfTheta)/sinHalfTheta;
        double ratioB = math.sin(amount*halfTheta)/sinHalfTheta;

        this.x = (q1x*ratioA + q2x*ratioB);
        this.y = (q1y*ratioA + q2y*ratioB);
        this.z = (q1z*ratioA + q2z*ratioB);
        this.w = (q1w*ratioA + q2w*ratioB);
      }
    }
  }

  /// Get a matrix for a given quaternion
  Matrix ToMatrix()
  {
    Matrix result = Matrix();
    
    double a2 = this.x*this.x;
    double b2 = this.y*this.y;
    double c2 = this.z*this.z;
    double ac = this.x*this.z;
    double ab = this.x*this.y;
    double bc = this.y*this.z;
    double ad = this.w*this.x;
    double bd = this.w*this.y;
    double cd = this.w*this.z;

    result.m0 = 1 - 2*(b2 + c2);
    result.m1 = 2*(ab + cd);
    result.m2 = 2*(ac - bd);

    result.m4 = 2*(ab - cd);
    result.m5 = 1 - 2*(a2 + c2);
    result.m6 = 2*(bc + ad);

    result.m8 = 2*(ac + bd);
    result.m9 = 2*(bc - ad);
    result.m10 = 1 - 2*(a2 + b2);

    return result;
  }

  /// Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
  /// 
  /// NOTE: Angles are returned in a Vector3 struct in radians
  Vector3 ToEuler()
  {
    Vector3 result = Vector3();
    double qx = this.x, qy = this.y, qz = this.z, qw = this.w; 

    // Roll (x-axis rotation)
    double x0 = 2.0*(qw*qx + qy*qz);
    double x1 = 1.0 - 2.0*(qx*qx + qy*qy);
    result.x = math.atan2(x0, x1);

    // Pitch (y-axis rotation)
    double y0 = 2.0*(qw*qy - qz*qx);
    y0 = y0 > 1.0 ? 1.0 : y0;
    y0 = y0 < -1.0 ? -1.0 : y0;
    result.y = math.asin(y0);

    // Yaw (z-axis rotation)
    double z0 = 2.0*(qw*qz + qx*qy);
    double z1 = 1.0 - 2.0*(qy*qy + qz*qz);
    result.z = math.atan2(z0, z1);

    return result;
  }

  /// Transform a quaternion given a transformation matrix (In place)
  void Transform(Matrix mat)
  {
    double qx = this.x, qy = this.y, qz = this.z, qw = this.w;
    
    this.x = mat.m0*qx + mat.m4*qy + mat.m8*qz + mat.m12*qw;
    this.y = mat.m1*qx + mat.m5*qy + mat.m9*qz + mat.m13*qw;
    this.z = mat.m2*qx + mat.m6*qy + mat.m10*qz + mat.m14*qw;
    this.w = mat.m3*qx + mat.m7*qy + mat.m11*qz + mat.m15*qw;
  }
}