library raylib;

import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'dart:io';
import 'dart:math' as math;
part 'raylib_bindings.dart';

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

  /// Set `x` and `y`  at once
  void Set(double x, double y) { this.x = x; this.y = y; }

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
  void LerpOf(Vector2 v1, Vector2 v2, double ammount)
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

  double get x => _memory!.pointer.ref.x;
  double get y => _memory!.pointer.ref.y;
  double get z => _memory!.pointer.ref.z;

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

  _Vector3 get ref => _memory!.pointer.ref;

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

  /// Vector with components value 0.0f
  factory Vector3.Zero() => Vector3();

  /// Vector with components value 1.0f
  factory Vector3.One() => Vector3(1.0, 1.0, 1.0);

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
  void LerpOf(Vector3 v2, double amount)
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
  void LerpOf(Vector4 v2, double ammount)
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
  void LerpOf(Quaternion q2, double amount)
  {
    double qx = this.x, qy = this.y;
    double qz = this.z, qw = this.w;

    this.x = qx + amount*(q2.x - qx);
    this.y = qy + amount*(q2.y - qy);
    this.z = qz + amount*(q2.z - qz);
    this.w = qw + amount*(q2.w - qw);
  }
  
  /// Calculate slerp-optimized interpolation between two quaternions
  void NLerpOf(Quaternion q2, double amount)
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
  void SlerpOf(Quaternion q2, double amount)
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

//------------------------------------------------------------------------------------
// Module Functions Definition - Matrix math
//------------------------------------------------------------------------------------

class Matrix implements Disposeable
{
  NativeResource<_Matrix>? _memory;

  // ignore: unused_element
  void _setMemory(_Matrix result)
  {
    Pointer<_Matrix> pointer = malloc.allocate<_Matrix>(sizeOf<_Matrix>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
  }

  _Matrix get ref => _memory!.pointer.ref;

  double get m0 => ref.m0;
  double get m1 => ref.m1;
  double get m2 => ref.m2;
  double get m3 => ref.m3;
  double get m4 => ref.m4;
  double get m5 => ref.m5;
  double get m6 => ref.m6;
  double get m7 => ref.m7;
  double get m8 => ref.m8;
  double get m9 => ref.m9;
  double get m10 => ref.m10;
  double get m11 => ref.m11;
  double get m12 => ref.m12;
  double get m13 => ref.m13;
  double get m14 => ref.m14;
  double get m15 => ref.m15;

  set m0(double value) => ref.m0 = value;
  set m1(double value) => ref.m1 = value;
  set m2(double value) => ref.m2 = value;
  set m3(double value) => ref.m3 = value;
  set m4(double value) => ref.m4 = value;
  set m5(double value) => ref.m5 = value;
  set m6(double value) => ref.m6 = value;
  set m7(double value) => ref.m7 = value;
  set m8(double value) => ref.m8 = value;
  set m9(double value) => ref.m9 = value;
  set m10(double value) => ref.m10 = value;
  set m11(double value) => ref.m11 = value;
  set m12(double value) => ref.m12 = value;
  set m13(double value) => ref.m13 = value;
  set m14(double value) => ref.m14 = value;
  set m15(double value) => ref.m15 = value;

  set column1(Vector4 v) {
    _Matrix r = ref;
    r.m0 = v.x; r.m1 = v.y; r.m2 = v.z; r.m3 = v.w;
  }

  set column2(Vector4 v) {
    _Matrix r = ref;
    r.m4 = v.x; r.m5 = v.y; r.m6 = v.z; r.m7 = v.w;
  }
  
  set column3(Vector4 v) {
    _Matrix r = ref;
    r.m8 = v.x; r.m9 = v.y; r.m10 = v.z; r.m11 = v.w;
  }

  set column4(Vector4 v) {
    _Matrix r = ref;
    r.m12 = v.x; r.m13 = v.y; r.m14 = v.z; r.m15 = v.w;
  }

  Vector4 get column1 => Vector4._internal((_memory!.pointer.cast<Float>() + 0).cast<_Vector4>());
  Vector4 get column2 => Vector4._internal((_memory!.pointer.cast<Float>() + 4).cast<_Vector4>());
  Vector4 get column3 => Vector4._internal((_memory!.pointer.cast<Float>() + 8).cast<_Vector4>());
  Vector4 get column4 => Vector4._internal((_memory!.pointer.cast<Float>() + 12).cast<_Vector4>());
  
  Matrix([
    double m0 = 1.0, double m4 = 0.0, double m8 = 0.0, double m12 = 0.0,
    double m1 = 0.0, double m5 = 1.0, double m9 = 0.0, double m13 = 0.0,
    double m2 = 0.0, double m6 = 0.0, double m10 = 1.0, double m14 = 0.0,
    double m3 = 0.0, double m7 = 0.0, double m11 = 0.0, double m15 = 1.0,
  ]) {
    Pointer<_Matrix> pointer = malloc.allocate<_Matrix>(sizeOf<_Matrix>());
    
    pointer.ref
      ..m0 = m0   ..m4 = m4   ..m8 = m8   ..m12 = m12
      ..m1 = m1   ..m5 = m5   ..m9 = m9   ..m13 = m13
      ..m2 = m2   ..m6 = m6   ..m10 = m10 ..m14 = m14
      ..m3 = m3   ..m7 = m7   ..m11 = m11 ..m15 = m15;

    _memory = NativeResource<_Matrix>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }
  
  /// Get identity matrix
  static final Matrix Identity = Matrix();

  /// Get translation matrix
  static Matrix Translate({double x = 0.0, double y = 0.0, double z = 0.0})
  {
    Matrix result = Matrix();

    result.m12 = x;
    result.m13 = y;
    result.m14 = z;

    return result;
  }

  /// Create rotation matrix from axis and angle
  /// 
  /// NOTE: Angle should be provided in radians
  static Matrix Rotate(Vector3 axis, double angle)
  {
    Matrix result = Matrix();

    double x = axis.x, y = axis.y, z = axis.z;
    double lengthSqr = x*x + y*y + z*z;

    if ((lengthSqr != 1.0) && (lengthSqr != 0.0))
    {
      double ilength = 1.0/math.sqrt(lengthSqr);
      x *= ilength;
      y *= ilength;
      z *= ilength;
    }

    double sinres = math.sin(angle);
    double cosres = math.cos(angle);
    double t = 1.0 - cosres;

    result.m0 = x*x*t + cosres;
    result.m1 = y*x*t + z*sinres;
    result.m2 = z*x*t - y*sinres;
    result.m3 = 0.0;

    result.m4 = x*y*t - z*sinres;
    result.m5 = y*y*t + cosres;
    result.m6 = z*y*t + x*sinres;
    result.m7 = 0.0;

    result.m8 = x*z*t + y*sinres;
    result.m9 = y*z*t - x*sinres;
    result.m10 = z*z*t + cosres;
    result.m11 = 0.0;

    result.m12 = 0.0;
    result.m13 = 0.0;
    result.m14 = 0.0;
    result.m15 = 1.0;

    return result;
  }
  
  /// Get x-rotation matrix
  /// 
  /// NOTE: Angle must be provided in radians
  static Matrix RotateX(double angle)
  {
    Matrix result = Matrix();

    double cosres = math.cos(angle);
    double sinres = math.sin(angle);

    result.m5 = cosres;
    result.m6 = sinres;
    result.m9 = -sinres;
    result.m10 = cosres;
    
    return result;
  }

  /// Get y-rotation matrix
  /// 
  /// NOTE: Angle must be provided in radians
  static Matrix RotateY(double angle)
  {
    Matrix result = Matrix();

    double cosres = math.cos(angle);
    double sinres = math.sin(angle);

    result.m0 = cosres;
    result.m2 = -sinres;
    result.m8 = sinres;
    result.m10 = cosres;

    return result;
  }

  /// Get z-rotation matrix
  /// 
  /// NOTE: Angle must be provided in radians
  static Matrix RotateZ(double angle)
  {
    Matrix result = Matrix();

    double cosres = math.cos(angle);
    double sinres = math.sin(angle);

    result.m0 = cosres;
    result.m1 = sinres;
    result.m4 = -sinres;
    result.m5 = cosres;

    return result;
  }

  /// Get xyz-rotation matrix
  /// 
  /// NOTE: Angle must be provided in radians
  static Matrix RotateXYZ(Vector3 angle)
  {
    Matrix result = Matrix();

    double cosz = math.cos(-angle.z);
    double sinz = math.sin(-angle.z);
    double cosy = math.cos(-angle.y);
    double siny = math.sin(-angle.y);
    double cosx = math.cos(-angle.x);
    double sinx = math.sin(-angle.x);

    result.m0 = cosz*cosy;
    result.m1 = (cosz*siny*sinx) - (sinz*cosx);
    result.m2 = (cosz*siny*cosx) + (sinz*sinx);

    result.m4 = sinz*cosy;
    result.m5 = (sinz*siny*sinx) + (cosz*cosx);
    result.m6 = (sinz*siny*cosx) - (cosz*sinx);

    result.m8 = -siny;
    result.m9 = cosy*sinx;
    result.m10= cosy*cosx;

    return result;
  }

  /// Get perspective projection matrix
  static Matrix Frustrum({
    required double left     , required double right   ,
    required double bottom   , required double top     , 
    required double nearPlane, required double farPlane
  }) {
    Matrix result = Matrix();

    double rl = (right - left);
    double tb = (top - bottom);
    double fn = (farPlane - nearPlane);

    result.m0 = (nearPlane*2.0)/rl;
    result.m1 = 0.0;
    result.m2 = 0.0;
    result.m3 = 0.0;

    result.m4 = 0.0;
    result.m5 = (nearPlane*2.0)/tb;
    result.m6 = 0.0;
    result.m7 = 0.0;

    result.m8 = (right + left)/rl;
    result.m9 = (top + bottom)/tb;
    result.m10 = -(farPlane + nearPlane)/fn;
    result.m11 = -1.0;

    result.m12 = 0.0;
    result.m13 = 0.0;
    result.m14 = -(farPlane*nearPlane*2.0)/fn;
    result.m15 = 0.0;

    return result;
  }

  /// Get perspective projection matrix
  /// 
  /// NOTE: Fovy angle must be provided in radians
  static Matrix Perspective({
    required double fovY, required double aspect,
    required double nearPlane, required double farPlane
  }) {
    Matrix result = Matrix();

    double top = nearPlane*math.tan(fovY*0.5);
    double bottom = -top;
    double right = top*aspect;
    double left = -right;

    // MatrixFrustum(-right, right, -top, top, near, far);
    double rl = (right - left);
    double tb = (top - bottom);
    double fn = (farPlane - nearPlane);

    result.m0 = (nearPlane*2.0)/rl;
    result.m5 = (nearPlane*2.0)/tb;
    result.m8 = (right + left)/rl;
    result.m9 = (top + bottom)/tb;
    result.m10 = -(farPlane + nearPlane)/fn;
    result.m11 = -1.0;
    result.m14 = -(farPlane*nearPlane*2.0)/fn;

    return result;
  }

  /// Get orthographic projection matrix
  static Matrix Ortho({
    required double left, required double right,
    required double bottom, required double top,
    required double nearPlane, required double farPlane
  }) {
    Matrix result = Matrix();

    double rl = (right - left);
    double tb = (top - bottom);
    double fn = (farPlane - nearPlane);

    result.m0 = 2.0/rl;
    result.m1 = 0.0;
    result.m2 = 0.0;
    result.m3 = 0.0;
    result.m4 = 0.0;
    result.m5 = 2.0/tb;
    result.m6 = 0.0;
    result.m7 = 0.0;
    result.m8 = 0.0;
    result.m9 = 0.0;
    result.m10 = -2.0/fn;
    result.m11 = 0.0;
    result.m12 = -(left + right)/rl;
    result.m13 = -(top + bottom)/tb;
    result.m14 = -(farPlane + nearPlane)/fn;
    result.m15 = 1.0;

    return result;
  }

  static Matrix LookAt({required Vector3 eye, required Vector3 target, required Vector3 up})
  {
    Matrix result = Matrix();

    double length = 0.0;
    double ilength = 0.0;

    // Vector3Subtract(eye, target)
    Vector3 vz = eye - target;
    // { eye.x - target.x, eye.y - target.y, eye.z - target.z };

    // Vector3Normalize(vz)
    Vector3 v = vz;
    length = math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length == 0.0) length = 1.0;
    ilength = 1.0/length;
    vz.x *= ilength;
    vz.y *= ilength;
    vz.z *= ilength;

    // Vector3CrossProduct(up, vz)
    Vector3 vx = Vector3.CrossProduct(up, vz);
    // { up.y*vz.z - up.z*vz.y, up.z*vz.x - up.x*vz.z, up.x*vz.y - up.y*vz.x };

    // Vector3Normalize(x)
    v = vx;
    length = math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
    if (length == 0.0) length = 1.0;
    ilength = 1.0/length;
    vx.x *= ilength;
    vx.y *= ilength;
    vx.z *= ilength;

    // Vector3CrossProduct(vz, vx)
    Vector3 vy = Vector3.CrossProduct(vz, vx);
    // { vz.y*vx.z - vz.z*vx.y, vz.z*vx.x - vz.x*vx.z, vz.x*vx.y - vz.y*vx.x };

    result.m0 = vx.x;
    result.m1 = vy.x;
    result.m2 = vz.x;
    result.m3 = 0.0;
    result.m4 = vx.y;
    result.m5 = vy.y;
    result.m6 = vz.y;
    result.m7 = 0.0;
    result.m8 = vx.z;
    result.m9 = vy.z;
    result.m10 = vz.z;
    result.m11 = 0.0;
    result.m12 = -(vx.x*eye.x + vx.y*eye.y + vx.z*eye.z);   // Vector3DotProduct(vx, eye)
    result.m13 = -(vy.x*eye.x + vy.y*eye.y + vy.z*eye.z);   // Vector3DotProduct(vy, eye)
    result.m14 = -(vz.x*eye.x + vz.y*eye.y + vz.z*eye.z);   // Vector3DotProduct(vz, eye)
    result.m15 = 1.0;

    return result;
  }

  /// Compose a transformation matrix from rotational, translational and scaling components
  static Matrix Compose(Vector3 translation, Quaternion rotation, Vector3 scale)
  {
    // Initialize vectors components and scale them
    double rx = scale.x, ry = 0.0, rz = 0.0;
    double ux = 0.0, uy = scale.y, uz = 0.0;
    double fx = 0.0, fy = 0.0, fz = scale.z;

    double qx = rotation.x, qy = rotation.y, qz = rotation.z, qw = rotation.w;

    // Right vector
    double resRx = rx*(qx*qx + qw*qw - qy*qy - qz*qz) + ry*(2*qx*qy - 2*qw*qz) + rz*( 2*qx*qz + 2*qw*qy);
    double resRy = rx*(2*qw*qz + 2*qx*qy) + ry*(qw*qw - qx*qx + qy*qy - qz*qz) + rz*(-2*qw*qx + 2*qy*qz);
    double resRz = rx*(-2*qw*qy + 2*qx*qz) + ry*(2*qw*qx + 2*qy*qz) + rz*(qw*qw - qx*qx - qy*qy + qz*qz);

    // Up vector
    double resUx = ux*(qx*qx + qw*qw - qy*qy - qz*qz) + uy*(2*qx*qy - 2*qw*qz) + uz*( 2*qx*qz + 2*qw*qy);
    double resUy = ux*(2*qw*qz + 2*qx*qy) + uy*(qw*qw - qx*qx + qy*qy - qz*qz) + uz*(-2*qw*qx + 2*qy*qz);
    double resUz = ux*(-2*qw*qy + 2*qx*qz) + uy*(2*qw*qx + 2*qy*qz) + uz*(qw*qw - qx*qx - qy*qy + qz*qz);

    // Forward vector
    double resFx = fx*(qx*qx + qw*qw - qy*qy - qz*qz) + fy*(2*qx*qy - 2*qw*qz) + fz*( 2*qx*qz + 2*qw*qy);
    double resFy = fx*(2*qw*qz + 2*qx*qy) + fy*(qw*qw - qx*qx + qy*qy - qz*qz) + fz*(-2*qw*qx + 2*qy*qz);
    double resFz = fx*(-2*qw*qy + 2*qx*qz) + fy*(2*qw*qx + 2*qy*qz) + fz*(qw*qw - qx*qx - qy*qy + qz*qz);
    
    // Set result matrix output
    return Matrix(
      resRx, resUx, resFx, translation.x,
      resRy, resUy, resFy, translation.y,
      resRz, resUz, resFz, translation.z,
      0.0, 0.0, 0.0, 1.0
    );
  }

  /// Decompose a transformation matrix into its rotational, translational and scaling components and remove shear
  static void Decompose(Matrix mat, Vector3 translation, Quaternion rotation, Vector3 scale)
  {
    double eps = 1e-9;

    // Extract Translation
    translation.x = mat.m12;
    translation.y = mat.m13;
    translation.z = mat.m14;

    // Matrix Columns - Rotation will be extracted into here
    var matcolums = [ mat.m0, mat.m4, mat.m8,
                      mat.m1, mat.m5, mat.m9,
                      mat.m2, mat.m6, mat.m10 ];
    
    // Shear Parameters XY, XZ, and YZ (extract and ignored)
    var shear = [ 0.0, 0.0, 0.0 ];

    // Normalized Scale Parameters
    double sclX = 0.0, sclY = 0.0, sclZ = 0.0;

    // Max-Normalizing helps numerical stability
    double stabilizer = eps;
    for(int x = 0; x < 9; x++)
      stabilizer = math.max(stabilizer, matcolums[x].abs());

    double istabilizer = 1.0 / stabilizer;
    for(int x = 0; x < 9; x++) matcolums[x] *= istabilizer;


    // X Scale
    var vx = matcolums[0], vy = matcolums[1], vz = matcolums[2];
    sclX = math.sqrt(vx*vx + vy*vy + vz*vz);
    if (sclX > eps)
    {
      matcolums[0] *= (1.0/sclX);
      matcolums[1] *= (1.0/sclX);
      matcolums[2] *= (1.0/sclX);
    }

    // Compute XY shear and make col2 orthogonal
    shear[0] = (matcolums[0]*matcolums[3] + matcolums[1]*matcolums[4] + matcolums[2]*matcolums[5]);
    vx = matcolums[0] * shear[0];
    vy = matcolums[1] * shear[0];
    vz = matcolums[2] * shear[0];
    
    matcolums[3] -= vx;
    matcolums[4] -= vy;
    matcolums[5] -= vz;

    // Y Scale
    vx = matcolums[3]; vy = matcolums[4]; vz = matcolums[5];
    sclY = math.sqrt(vx*vx + vy*vy + vz*vz);
    if (sclY > eps)
    {
      matcolums[3] *= 1.0/sclY;  
      matcolums[4] *= 1.0/sclY;
      matcolums[5] *= 1.0/sclY;

      shear[0] /= sclY;
    }

    // Compute XZ and YZ shears and make col3 orthogonal
    // Compute XZ
    shear[1] = (matcolums[0]*matcolums[6] + matcolums[1]*matcolums[7] + matcolums[2]*matcolums[8]);
    // Scale
    vx = matcolums[0] * shear[1];
    vy = matcolums[1] * shear[1];
    vz = matcolums[2] * shear[1];
    // Subtract
    matcolums[6] -= vx;
    matcolums[7] -= vy;
    matcolums[8] -= vz;

    // Compute YZ shear
    shear[2] = (matcolums[3]*matcolums[6] + matcolums[4]*matcolums[7] + matcolums[5]*matcolums[8]);
    // Scale
    vx = matcolums[3] * shear[2];
    vy = matcolums[4] * shear[2];
    vz = matcolums[5] * shear[2];
    // Subtract
    matcolums[6] -= vx;
    matcolums[7] -= vy;
    matcolums[8] -= vz;

    // Z Scale
    vx = matcolums[6]; vy = matcolums[7]; vz = matcolums[8];
    sclZ = math.sqrt(vx*vx + vy*vy + vz*vz);
    if(sclZ > eps)
    {
      matcolums[6] *= 1.0/sclZ;
      matcolums[7] *= 1.0/sclZ;
      matcolums[8] *= 1.0/sclZ;

      shear[1] /= sclZ;
      shear[2] /= sclZ;
    }

    //   x y z
    // 0 0 1 2
    // 1 3 4 5
    // 2 6 7 8
    vx = matcolums[4]*matcolums[8] - matcolums[5]*matcolums[7];
    vy = matcolums[5]*matcolums[6] - matcolums[3]*matcolums[8];
    vz = matcolums[3]*matcolums[7] - matcolums[4]*matcolums[6];

    vx *= matcolums[0];
    vy *= matcolums[1];
    vz *= matcolums[2];
    var det = vx + vy + vz;

    if (det < 0)
    {
      sclX *= -1; sclY *= -1; sclZ *= -1;

      for (int i = 0; i < 9; i++) matcolums[i] *= -1;
    }

    // Set Scale
    scale.Set(sclX * stabilizer, sclY * stabilizer, sclZ * stabilizer);

    // Main matcolums diagonal
    // m0  -> matcolums[0]
    // m5  -> matcolums[4]
    // m10 -> matcolums[8]

    double fourWSquaredMinus1 = matcolums[0] + matcolums[4] + matcolums[8];
    double fourXSquaredMinus1 = matcolums[0] - matcolums[4] - matcolums[8];
    double fourYSquaredMinus1 = matcolums[4] - matcolums[0] - matcolums[8];
    double fourZSquaredMinus1 = matcolums[8] - matcolums[0] - matcolums[4];

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

    double m1 = matcolums[3], m2 = matcolums[6], m4 = matcolums[1];
    double m6 = matcolums[7], m8 = matcolums[2], m9 = matcolums[5];

    switch (biggestIndex)
    {
    case 0:
      rotation.w = biggestVal;
      rotation.x = (m6 - m9)*mult;
      rotation.y = (m8 - m2)*mult;
      rotation.z = (m1 - m4)*mult;
      break;
    case 1:
      rotation.x = biggestVal;
      rotation.w = (m6 - m9)*mult;
      rotation.y = (m1 + m4)*mult;
      rotation.z = (m8 + m2)*mult;
      break;
    case 2:
      rotation.y = biggestVal;
      rotation.w = (m8 - m2)*mult;
      rotation.x = (m1 + m4)*mult;
      rotation.z = (m6 + m9)*mult;
      break;
    case 3:
      rotation.z = biggestVal;
      rotation.w = (m1 - m4)*mult;
      rotation.x = (m8 + m2)*mult;
      rotation.y = (m6 + m9)*mult;
      break;
    }
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Matrix>>((pointer) {
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

extension MatrixMath on Matrix
{
  /// Add `other` matrix to `this`
  void Add(Matrix right)
  {
    this.column1 += right.column1;
    this.column2 += right.column2;
    this.column3 += right.column3;
    this.column4 += right.column4;
  }

  /// Returns the sum of `this` and `other` matrix
  Matrix operator +(Matrix other)
  {
    Matrix result = Matrix();

    result.column1.Add(this.column1);
    result.column2.Add(this.column2);
    result.column3.Add(this.column3);
    result.column4.Add(this.column4);

    result.column1.Add(other.column1);
    result.column2.Add(other.column2);
    result.column3.Add(other.column3);
    result.column4.Add(other.column4);

    return result;
  }
  /// Subtract `other` matrix to `this`
  void Subtract(Matrix right)
  {
    this.column1 -= right.column1;
    this.column2 -= right.column2;
    this.column3 -= right.column3;
    this.column4 -= right.column4;
  }

  /// Returns the sum of `this` and `other` matrix
  Matrix operator -(Matrix other)
  {
    Matrix result = Matrix();

    result.column1.Subtract(this.column1);
    result.column2.Subtract(this.column2);
    result.column3.Subtract(this.column3);
    result.column4.Subtract(this.column4);

    result.column1.Subtract(other.column1);
    result.column2.Subtract(other.column2);
    result.column3.Subtract(other.column3);
    result.column4.Subtract(other.column4);

    return result;
  }

  /// Get two matrix multiplication
  /// 
  /// NOTE: When multiplying matrices... the order matters!
  /// 
  /// Warning! Untested. Proceed with caution
  Matrix operator *(Matrix right)
  {
    Matrix result = Matrix();

    final l0 = m0,  l1 = m1,  l2 = m2,  l3 = m3;
    final l4 = m4,  l5 = m5,  l6 = m6,  l7 = m7;
    final l8 = m8,  l9 = m9,  l10 = m10, l11 = m11;
    final l12 = m12, l13 = m13, l14 = m14, l15 = m15;

    final r0 = right.m0,  r1 = right.m1,  r2 = right.m2,  r3 = right.m3;
    final r4 = right.m4,  r5 = right.m5,  r6 = right.m6,  r7 = right.m7;
    final r8 = right.m8,  r9 = right.m9,  r10 = right.m10, r11 = right.m11;
    final r12 = right.m12, r13 = right.m13, r14 = right.m14, r15 = right.m15;

    result.m0 = l0*r0 + l1*r4 + l2*r8 + l3*r12;
    result.m1 = l0*r1 + l1*r5 + l2*r9 + l3*r13;
    result.m2 = l0*r2 + l1*r6 + l2*r10 + l3*r14;
    result.m3 = l0*r3 + l1*r7 + l2*r11 + l3*r15;

    result.m4 = l4*r0 + l5*r4 + l6*r8 + l7*r12;
    result.m5 = l4*r1 + l5*r5 + l6*r9 + l7*r13;
    result.m6 = l4*r2 + l5*r6 + l6*r10 + l7*r14;
    result.m7 = l4*r3 + l5*r7 + l6*r11 + l7*r15;

    result.m8 = l8*r0 + l9*r4 + l10*r8 + l11*r12;
    result.m9 = l8*r1 + l9*r5 + l10*r9 + l11*r13;
    result.m10 = l8*r2 + l9*r6 + l10*r10 + l11*r14;
    result.m11 = l8*r3 + l9*r7 + l10*r11 + l11*r15;

    result.m12 = l12*r0 + l13*r4 + l14*r8 + l15*r12;
    result.m13 = l12*r1 + l13*r5 + l14*r9 + l15*r13;
    result.m14 = l12*r2 + l13*r6 + l14*r10 + l15*r14;
    result.m15 = l12*r3 + l13*r7 + l14*r11 + l15*r15;

    return result;
  }

  /// Invert provided matrix
  void Invert()
  {
    double a00 = this.m0, a01 = this.m1, a02 = this.m2, a03 = this.m3;
    double a10 = this.m4, a11 = this.m5, a12 = this.m6, a13 = this.m7;
    double a20 = this.m8, a21 = this.m9, a22 = this.m10, a23 = this.m11;
    double a30 = this.m12, a31 = this.m13, a32 = this.m14, a33 = this.m15;

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

    double det = (b00*b11 - b01*b10 + b02*b09 + b03*b08 - b04*b07 + b05*b06);
    if (det.abs() < 0.000001) return;

    // Calculate the invert determinant (inlined to avoid double-caching)
    double invDet = 1.0 / det;

    this.m0 = (a11*b11 - a12*b10 + a13*b09)*invDet;
    this.m1 = (-a01*b11 + a02*b10 - a03*b09)*invDet;
    this.m2 = (a31*b05 - a32*b04 + a33*b03)*invDet;
    this.m3 = (-a21*b05 + a22*b04 - a23*b03)*invDet;
    this.m4 = (-a10*b11 + a12*b08 - a13*b07)*invDet;
    this.m5 = (a00*b11 - a02*b08 + a03*b07)*invDet;
    this.m6 = (-a30*b05 + a32*b02 - a33*b01)*invDet;
    this.m7 = (a20*b05 - a22*b02 + a23*b01)*invDet;
    this.m8 = (a10*b10 - a11*b08 + a13*b06)*invDet;
    this.m9 = (-a00*b10 + a01*b08 - a03*b06)*invDet;
    this.m10 = (a30*b04 - a31*b02 + a33*b00)*invDet;
    this.m11 = (-a20*b04 + a21*b02 - a23*b00)*invDet;
    this.m12 = (-a10*b09 + a11*b07 - a12*b06)*invDet;
    this.m13 = (a00*b09 - a01*b07 + a02*b06)*invDet;
    this.m14 = (-a30*b03 + a31*b01 - a32*b00)*invDet;
    this.m15 = (a20*b03 - a21*b01 + a22*b00)*invDet;
  }
} 

//------------------------------------------------------------------------------------
//                                  Rectangle
//------------------------------------------------------------------------------------

/// Rectangle, 4 components
class Rectangle implements Disposeable
{
  NativeResource<_Rectangle>? _memory;

  // ignore: unused_element
  void _setMemory(_Rectangle result)
  {
    if (_memory != null) _memory!.dispose();

    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref = result;


    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  _Rectangle get ref => _memory!.pointer.ref;
  double get width => _memory!.pointer.ref.width;
  double get height => _memory!.pointer.ref.height;
  double get x => _memory!.pointer.ref.x;
  double get y => _memory!.pointer.ref.y;

  set width(double value)  => _memory!.pointer.ref.width  = value.abs().roundToDouble();
  set height(double value) => _memory!.pointer.ref.height = value.abs().roundToDouble();
  set x(double value) => _memory!.pointer.ref.x = value.abs().roundToDouble();
  set y(double value) => _memory!.pointer.ref.y = value.abs().roundToDouble();

  Rectangle([double x = 0.0, double y = 0.0, double width = 0.0, double height = 0.0])
  {
    Pointer<_Rectangle> pointer = malloc.allocate<_Rectangle>(sizeOf<_Rectangle>());
    pointer.ref
    ..x = x
    ..y = y
    ..width = width
    ..height = height;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Rectangle>(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Rectangle>>((pointer)
  {
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

//------------------------------------------------------------------------------------
//                                   Window
//------------------------------------------------------------------------------------

/// Window-related functions
abstract class Window
{
  // Initialize window and OpenGL context
  static void Init({required int width, required int height, required String title})
  {
    using ((Arena arena) {
      final cTitle = title.toNativeUtf8(allocator: arena);

      _initWindow(width, height, cTitle);
    });
  }
  /// Close window and unload OpenGL context
  static void Close() => _closeWindow();            
  /// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)      
  static bool ShouldClose() => _windowShouldClose();
  /// Check if window has been initialized successfully
  static bool IsReady() => _isWindowReady();
  /// Check if window is currently fullscreen
  static bool IsFullScreen() => _isFullScreen();
  /// Check if window is currently hidden
  static bool IsHidden() => _isHidden();
  /// Check if window is currently minimized
  static bool IsMinimized() => _isMinimized();
  /// Check if window is currently maximized
  static bool IsMaximized() => _isMaximized();
  /// Check if window is currently focused
  static bool IsFocused() => _isFocused();
  /// Check if window has been resized last frame
  static bool IsResized() => _isResized();
  /// Check if one specific window flag is enabled
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static bool IsState(int flag) => _isWindowState(flag) != 0;
  /// Set window configuration state using flags
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static void SetState(int flag) => _setWindowState(flag);

  /// Setup init configuration flags (view FLAGS)
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static void SetFlags(int flag) => _setConfigFlags(flag);

  /// Takes a screenshot of current screen (filename extension defines format)
  static void TakeScreenshoot(String fileName)
  {
    using ((Arena arena) {
      Pointer<Utf8> cfileName = fileName.toNativeUtf8(allocator: arena);

      _takeScreenshot(cfileName);
    });
  }

  /// Clear window configuration state flags
  /// 
  /// The parameter `flag` expects a ConfigFlags value
  static void ClearState(int flag) => _clearWindowState(flag);
  /// Toggle window state: fullscreen/windowed, resizes monitor to match window resolution
  static void ToggleFullscreen() => _toggleFullscreen();
  /// Toggle window state: borderless windowed, resizes window to match monitor resolution
  static void ToggleBorderlessWindowed() => _toggleBorderlessWindowed();
  /// Set window state: maximized, if resizable
  static void Maximize() => _maximizeWindow();
  /// Set window state: minimized, if resizable
  static void Minimize() => _minimizeWindow();
  /// Restore window from being minimized/maximized
  static void Restore() => _restoreWindow();
  /// Set icon for window (single image, RGBA 32bit)
  static void SetIcon(Image image) => _setWindowIcon(image.ref);
  /// Set icon for window (multiple images, RGBA 32bit)
  static void SetIcons(List<Image> images)
  {
    using((Arena arena) {
      Pointer<_Image> ref = arena.allocate<_Image>(sizeOf<_Image>() * images.length);

      for(int x = 0; x < images.length; x++)
        ref[x] = images[x].ref;

      _setWindowIcons(ref, images.length);      
    });
  }
  /// Set title for window
  static void SetTitle(String title)
  {
    using((Arena arena) {
      Pointer<Utf8> pointer = title.toNativeUtf8(allocator: arena);

      _setWindowTitle(pointer);
    });
  }

  /// Set window position on screen
  static void SetPosition(int x, int y) => _setWindowPosition(x, y);
  /// Set monitor for the current window
  static void SetMonitor(int monitor) => _setWindowMonitor(monitor);
  /// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
  static void SetMinSize(int width, int height) => _setWindowMinSize(width, height);
  /// Set window maximum dimensions (for FLAG_WINDOW_RESIZABLE)
  static void SetMaxSize(int width, int height) => _setWindowMaxSize(width, height);
  /// Set window dimensions
  static void SetSize(int width, int height) => _setWindowSize(width, height);
  /// Set window opacity [0.0f..1.0f]
  static void SetOpacity(double opacity) => _setWindowOpacity(opacity);
  /// Set window focused
  static void SetFocused() => _setWindowFocused();
  /// Get native window handle
  static Pointer<Void> GetHandle() => _getWindowHandle();
  /// Get current screen width
  static int Width() => _getScreenWidth();
  /// Get current screen height
  static int Height() => _getScreenHeight();
  /// Get current render width (it considers HiDPI)
  static int RenderWidth() => _getRenderWidth();
  /// Get current render height (it considers HiDPI)
  static int RenderHeight() => _getRenderHeight();
  /// Get number of connected monitors
  static int GetMonitorCount() => _getMonitorCount();
  /// Get specified monitor position
  static int GetCurrentMonitor() => _getCurrentMonitor();
  /// Get specified monitor position
  static Vector2 GetMonintorPosition(int monitor)
  {
    Vector2 position = Vector2();
    position._setmemory(_getMonitorPosition(monitor));

    return position;
  }
  /// Get specified monitor width (current video mode used by monitor)
  static int GetMonitorWidth(int monitor) => _getMonitorWidth(monitor);
  /// Get specified monitor height (current video mode used by monitor)
  static int GetMonitorHeight(int monitor) => _getMonitorHeight(monitor);
  /// Get specified monitor physical width in millimetres
  static int GetMonitorPhysicalWidth(int monitor) => _getMonitorPhysicalWidth(monitor);
  /// Get specified monitor physical height in millimetres
  static int GetMonitorPhysicalHeight(int monitor) => _getMonitorPhysicalHeight(monitor);
  /// Get specified monitor refresh rate
  static int GetMonitorRefreshRate(int monitor) => _getMonitorRefreshRate(monitor);
  /// Get window position XY on monitor
  static Vector2 GetPosition()
  {
    Vector2 position = Vector2();
    position._setmemory(_getWindowPosition());

    return position;
  }
  /// Get window scale DPI factor
  static Vector2 GetScaleDPI()
  {
    Vector2 position = Vector2();
    position._setmemory(_getWindowScaleDPI());
    
    return position;
  }
  /// Get the human-readable, UTF-8 encoded name of the specified monitor
  static String GetMonitorName(int monitor) => _getMonitorName(monitor).toDartString();
  /// Set clipboard text content
  static void SetClipboardText(String text)
  {
    using((Arena arena) {
      Pointer<Utf8> cText = text.toNativeUtf8(allocator: arena);

      _setClipboardText(cText);
    });
  }
  /// Get clipboard text content
  static String GetClipboardText() => _getClipboardText().toDartString();
  /// Get clipboard image content
  static Image GetClipboardImage() => Image._Recieve(_getClipboardImage());
  /// Enable waiting for events on EndDrawing(), no automatic event polling
  static void EnableEventWaiting() => _enableEventWaiting();
  /// Disable waiting for events on EndDrawing(), automatic events polling
  static void DisabelEventWaiting() => _disableEventWaiting();
  /// Set a custom key to exit program (default is ESC)
  static void SetExitKey(int key) => _setExitKey(key);
}

//------------------------------------------------------------------------------------
//                            Input handling functions
//------------------------------------------------------------------------------------

abstract class Cursor
{
  /// Shows cursor
  static void Show() => _showCursor();
  /// Hides cursor
  static void Hide() => _hideCursor();
  /// Check if cursor is not visible
  static bool IsHidden() => _isCursorHidden();
  /// Enables cursor (unlock cursor)
  static void Enable() => _enableCursor();
  /// Disables cursor (lock cursor)
  static void Disable() => _disableCursor();
  /// Check if cursor is on the screen
  static bool IsOnScreen() => _isCursorOnScreen();
  /// Set mouse cursor
  static void Set(int cursor) => _setMouseCursor(cursor);
}

abstract class Gestures
{
  /// Enable a set of gestures using flags
  static void SetEnabled(int flags) => _setGesturesEnabled(flags);
  /// Check if a gesture have been detected
  static void IsDetected(int gesture) => _isGestureDetected(gesture);
  /// Get latest detected gesture
  static int GetDetected() => _getGestureDetected();
  /// Get gesture hold time in seconds
  static double GetHoldDuration() => _getGestureHoldDuration();
  /// Get gesture drag vector
  static Vector2 GetDragVector() => Vector2._internal(_getGestureDragVector());
  /// Get gesture drag angle
  static double GetDragAngle() => _getGestureDragAngle().toDouble();
  /// Get gesture pinch delta
  static Vector2 GetPinchVector() => Vector2._internal(_getGesturePinchVector());
  /// Get gesture pinch angle
  static double GetPinchAngle() => _getGesturePinchAngle().toDouble();
}

//------------------------------------------------------------------------------------
//                            Input trigger functions
//------------------------------------------------------------------------------------

/// Keyboard related functions
abstract class Key
{
  /// Check if a key has been pressed once
  static bool IsPressed(int key) => _isKeyPressed(key);
  /// Check if a key has been pressed again
  static bool IsPressedRepeat(int key) => _isKeyPressedRepeat(key);
  /// Check if a key is being pressed
  static bool IsDown(int key) => _isKeyDown(key);
  /// Check if a key is NOT being pressed
  static bool IsUp(int key) => _isKeyUp(key);
  /// Check if a key has been released once
  static bool IsReleased(int key) => _isKeyReleased(key);
  /// Get key pressed (keycode), call it multiple times for keys queued, returns 0 when the queue is empty
  static int Get() => _getKeyPressed();
  /// Get char pressed (unicode), call it multiple times for chars queued, returns 0 when the queue is empty
  static String GetChar() => _getCharPressed().toString();
  /// Get name of a QWERTY key on the current keyboard layout (eg returns string 'q' for KEY_A on an AZERTY keyboard)
  static String GetName() => _getKeyName().toDartString();
}

/// Mouse related functions
abstract class Mouse
{ 
  /// Check if a mouse button has been pressed once
  static bool IsButtonDown(int button) => _isMouseButtonDown(button);
  /// Check if a mouse button is NOT being pressed
  static bool IsButtonUp(int button) => _isMouseButtonUp(button);
  /// Check if a mouse button has been pressed once
  static bool IsPressed(int button) => _isMouseButtonPressed(button);
  /// Check if a mouse button has been released once
  static bool IsReleased(int button) => _isMouseButtonReleased(button);
  // Get mouse position X
  static int GetX() => _getMouseX();
  /// Get mouse position Y
  static int GetY() => _getMouseY();
  /// Get mouse position XY
  static Vector2 GetPosition() => Vector2._internal(_getMousePosition());
  /// Get mouse delta between frames
  static Vector2 GetPositionDelta() => Vector2._internal(_getMouseDelta());
  /// Set mouse position XY
  static void SetPosition(int x, int y) => _setMousePosition(x, y);
  /// Set mouse offset
  static void SetOffset(int offsetX, int offsetY) => _setMouseOffset(offsetX, offsetY);
  /// Set mouse scaling
  static void SetScale(double scaleX, double scaleY) => _setMouseScale(scaleX, scaleY);
  /// Get mouse wheel movement for X or Y, whichever is larger
  static double GetWheelMove() => _getMouseWheelMove().toDouble();
  /// Get mouse wheel movement for both X and Y
  static Vector2 GetWheelMoveV() => Vector2._internal(_getMouseWheelMoveV());
}

/// Gamepad related functions
abstract class Gamepad
{
  /// Check if a gamepad is available
  static bool IsAvaiable(int gamepad) => _isGamepadAvailable(gamepad);
  /// Get gamepad internal name id
  static String GetName(int gamepad) => _getGamepadName(gamepad).toDartString();
  /// Check if a gamepad button is being pressed
  static bool IsButtonDown(int gamepad, int button) => _isGamepadButtonDown(gamepad, button);
  /// Check if a gamepad button is NOT being pressed
  static bool IsButtonUp(int gamepad, int button) => _isGamepadButtonUp(gamepad, button);
  /// Check if a gamepad button has been pressed once
  static bool IsButtonPressed(int gamepad, int button) => _isGamepadButtonPressed(gamepad, button);
  /// Get the last gamepad button pressed
  static int GetButtonPressed() => _getGamepadButtonPressed();
  /// Check if a gamepad button is being pressed
  static bool IsButtonReleased(int gamepad, int button) => _isGamepadButtonReleased(gamepad, button);
  /// Get axis count for a gamepad
  static int GetAxisCount(int gamepad) => _getGamepadAxisCount(gamepad);
  /// Get movement value for a gamepad axis
  static double GetAxisMovement(int gamepad, int axis) => _getGamepadAxisMovement(gamepad, axis);
  /// Set internal gamepad mappings (SDL_GameControllerDB)
  static int SetMappins(String mappings)
  {
    return using ((Arena arena) {
      Pointer<Utf8> cmappings = mappings.toNativeUtf8(allocator: arena);

      return _setGamepadMappings(cmappings);
    });
  }
  /// Set gamepad vibration for both motors (duration in seconds)
  static void SetVibration(int gamepad,{ required double leftMotor, required double rightMotor, required double duration })
  {
    _setGamepadVibration(gamepad, leftMotor, rightMotor, duration);
  }
}

/// Touch related functions
abstract class Touch
{
  // I could probably setup some type of initializer which gets the points count
  /// Get touch position X for touch point 0 (relative to screen size)
  static int GetX() => _getTouchX();
  /// Get touch position Y for touch point 0 (relative to screen size)
  static int GetY() => _getTouchY();
  /// Get touch position XY for a touch point index (relative to screen size)
  static Vector2 GetPosition(int index) => Vector2._internal(_getTouchPosition(index));
  /// Get touch point identifier for given index
  static int GetPointId(int index) => _getTouchPointId(index);
  /// Get number of touch points
  static int GetPointCount() => _getTouchPointCount();
}

//------------------------------------------------------------------------------------
//                                   Frame
//------------------------------------------------------------------------------------

/// Timing-related functions
abstract class Frame
{
  /// Set target FPS (maximum)
  static void SetTargetFPS(int fps) => _setTargetFPS(fps);
  /// Get time in seconds for last frame drawn (delta time)
  static double GetFrameTime() => _getFrameTime();
  /// Get elapsed time in seconds since InitWindow()
  static double GetTime() => _getTime();
  /// Get current FPS
  static int GetFPS() => _getFPS();
}

//------------------------------------------------------------------------------------
//                                   Color
//------------------------------------------------------------------------------------

class Color implements Disposeable
{
  NativeResource<_Color>? _memory;

  // ignore: unused_element
  _setMemory(_Color result)
  {
    Pointer<_Color> pointer = malloc.allocate<_Color>(sizeOf<_Color>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);
  }

  _Color get ref => _memory!.pointer.ref;

  static final Color LIGHTGRAY  = Color(200, 200, 200, 255);
  static final Color GRAY       = Color(130, 130, 130, 255);
  static final Color DARKGRAY   = Color( 80,  80,  80, 255);
  static final Color YELLOW     = Color( 53, 249,   0, 255);
  static final Color GOLD       = Color(255, 203,   0, 255);
  static final Color ORANGE     = Color(255, 161,   0, 255);
  static final Color PINK       = Color(255, 109, 194, 255);
  static final Color RED        = Color(230,  41,  55, 255);
  static final Color MAROON     = Color(190,  33,  55, 255);
  static final Color GREEN      = Color(  0, 228,  48, 255);
  static final Color LIME       = Color(  0, 158,  47, 255);
  static final Color DARKGREEN  = Color(  0, 117,  44, 255);
  static final Color SKYBLUE    = Color(102, 191, 255, 255);
  static final Color BLUE       = Color(  0, 121, 241, 255);
  static final Color DARKBLUE   = Color(  0,  82, 172, 255);
  static final Color VIOLET     = Color(135,  60, 190, 255);
  static final Color DARKPURPLE = Color(112,  31, 126, 255);
  static final Color BEIGE      = Color(211, 176, 131, 255);
  static final Color BROWN      = Color(127, 106,  79, 255);
  static final Color DARKBROWN  = Color( 76,  63,  47, 255);
  static final Color WHITE      = Color(255, 255, 255, 255);
  static final Color BLACK      = Color(  0,   0,   0, 255);
  static final Color BLANK      = Color(  0,   0,   0,   0); // Transparent
  static final Color RAYWHITE   = Color(245, 245, 245, 255);

  Color(int r, int g, int b, int a)
  {
    Pointer<_Color> pointer = malloc.allocate<_Color>(sizeOf<_Color>());
    pointer.ref
    ..r = r
    ..g = g
    ..b = b
    ..a = a;

    _memory = NativeResource<_Color>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }
  
  static final Finalizer _finalizer = Finalizer<Pointer<_Color>>((pointer)
  {
    if (pointer.address != 0)
    {
      malloc.free(pointer);
    }
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

//------------------------------------------------------------------------------------
//                                   Image
//------------------------------------------------------------------------------------

class Image implements Disposeable
{
  NativeResource<_Image>? _memory;
  int frameCount = 0;
  int fileSize = 0;

  void _setMemory(_Image result)
  {
    if (result.data.address == 0) throw Exception("[Dart] Could not load image!");
    if (_memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_Image> pointer = malloc.allocate<_Image>(sizeOf<_Image>());
    pointer.ref = result;

    this._memory = NativeResource<_Image>(pointer);

    // Attaching the process to Dart Garbage Collector
    _finalizer.attach(this, pointer, detach: this);
  }

  _Image get ref => _memory!.pointer.ref;
  int get width => ref.width;
  int get height => ref.height;
  int get format => ref.format;
  int get mipmaps => ref.mipmaps;
  Pointer<Void> get data => ref.data;

  Image._Recieve(_Image image)
  {
    _setMemory(image);
  }

  /// Load image from file into CPU memory (RAM)
  Image(String path)
  {
    Pointer<Utf8> cPath = path.toNativeUtf8();
    try {
      _setMemory(_loadImage(cPath));
    } finally {
      malloc.free(cPath);      
    }
  }

  /// Load image from RAW file data
  Image.Raw(String path, int width, int height, int format, int headerSize)
  {
    Pointer<Utf8> cPath = path.toNativeUtf8();
    try {
      _Image result = _loadImageRaw(cPath, width, height, format, headerSize);
      _setMemory(result);
    } finally {
      malloc.free(cPath);      
    }
  }

  /// Load image sequence from file (frames appended to image.data)
  Image.Anim(String path)
  {
    Pointer<Utf8> cPath = path.toNativeUtf8();
	  Pointer<Int32> frameCount = malloc.allocate<Int32>(sizeOf<Int32>());

    try {
      this.frameCount = frameCount.value;
      _Image result = _loadImageAnim(cPath, frameCount); 
      _setMemory(result);
    } finally {
      malloc.free(cPath);
      malloc.free(frameCount);
    }
  }

  /// Load image sequence from memory buffer
  Image.AnimFromMemory(String fileType, Uint8List bytes)
  {
    if (bytes.length == 0) throw Exception("[Dart] byte array passed is empty!");
    
    Pointer<Utf8> cFileType = fileType.toNativeUtf8();
	  Pointer<Int32> frameCount = malloc.allocate<Int32>(sizeOf<Int32>());

    // Transform byte list into a pointer to pass over C
    Pointer<Uint8> data = malloc.allocate<Uint8>(bytes.length);
    data.asTypedList(bytes.length).setAll(0, bytes);

    try {
      this.frameCount = frameCount.value;
      _Image result = _loadImageAnimFromMemory(cFileType, data, bytes.length, frameCount); 
      _setMemory(result);
    } finally {
      malloc.free(cFileType);
      malloc.free(frameCount);
      malloc.free(data);
    }
  }

  /// Load image from memory buffer, fileType refers to extension: i.e. '.png'
  Image.FromMemory(String fileType, Uint8List fileData, int dataSize)
  {
    Pointer<Utf8> cFileType = fileType.toNativeUtf8();
    Pointer<Uint8> data = malloc.allocate<Uint8>(dataSize);

    try {
      _Image result = _loadImageFromMemory(cFileType, data, dataSize);
      _setMemory(result);
    } finally {
      malloc.free(cFileType);
      malloc.free(data);
    }
  }

  /// Load image from GPU texture data
	//  Texture2D shadow class not yet implemented
	//  uncommment when done
  Image.LoadFromTexture(_Texture2D texture)
  {
    _Image result = _loadImageFromTexture(texture);
    _setMemory(result);
  }

  /// Load image from screen buffer and (screenshot)
  Image.FromScreen()
  {
    _Image result = _loadImageFromScreen();
    _setMemory(result);
  }

  // Check if an image is valid (data and parameters)
  bool IsValid()
  {
    if (_memory == null || _memory!.isDisposed) return false;

    return _isImageValid(this._memory!.pointer.ref);
  }
  
  /// Export image data to file, returns true on success
  bool Export(String fileName)
  {
    if(!IsValid()) return false;

    return using ((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportImage(_memory!.pointer.ref, cFileName);
    });
  }

  Uint8List ExportToMemory(String fileType)
  {
    return using ((Arena arena) {
      final cFiletype = fileType.toNativeUtf8(allocator: arena);
      final cFileSize = arena.allocate<Int32>(sizeOf<Int32>());

      final Pointer<Uint8> data = _exportImageToMemory(
        _memory!.pointer.ref,
        cFiletype,
        cFileSize
      ).cast<Uint8>();

      if (data.address == 0) return Uint8List(0);

      try {
        fileSize = cFileSize.value;
        final Uint8List result = Uint8List.fromList(data.asTypedList(fileSize));
        return result;
      } finally {
        malloc.free(cFiletype);
        malloc.free(cFileSize);
        // Not yet implemented
        // _unloadFileData(data);
      }
    });
  }

  bool ExportAsCode(String fileName)
  {
    if(!IsValid()) return false;

    return using((Arena arena) {
      Pointer<Utf8> cFileName = fileName.toNativeUtf8(allocator: arena);

      return _exportImageAsCode(_memory!.pointer.ref, cFileName);
    });
  }

  // Garbage Colector dispose reference
  static final Finalizer<Pointer<_Image>> _finalizer = Finalizer((ptr) 
  {
    if (ptr.address == 0) return;

    _unloadImage(ptr.ref);

    malloc.free(ptr);
  });
  
  /// Unload image from CPU memory (RAM)
  // Manual dispose
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadImage(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Texture
//------------------------------------------------------------------------------------

// ToDo: Update Rect
// In case Rectangle class was implemented, continue
class Texture2D implements Disposeable
{
	NativeResource<_Texture2D>? _memory;

	void _setmemory(_Texture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (_memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_Texture2D> pointer = malloc.allocate<_Texture2D>(sizeOf<_Texture2D>());
    pointer.ref = result;
    this._memory = NativeResource<_Texture2D>(pointer);

    _finalizer.attach(this, pointer, detach: this);
	}

  //--------------------------------Constructors----------------------------------------

  // Used for TextureCubeMap constructor
  Texture2D._internal(_Texture struct)
  {
    _setmemory(struct);
  }

  _Texture2D get ref => _memory!.pointer.ref;

  /// Load texture from file into GPU memory (VRAM)
  Texture2D(String fileName)
  {
    Pointer<Utf8> cFileName = fileName.toNativeUtf8();

    try {
      _Texture2D result = _loadTexture(cFileName);
      _setmemory(result);
    } finally {
      malloc.free(cFileName);
    }
  }

  /// Load texture from image data
  Texture2D.FromImage(Image image)
  {
    if (image._memory == null) throw Exception("[Dart] Image passed is invalid!");

    _Texture2D result = _loadTextureFromImage(image._memory!.pointer.ref);
    _setmemory(result);
  }

  //---------------------------------Utilities-----------------------------------------

  /// Check if a texture is valid (loaded in GPU)
  bool isValid()
  {
    if (_memory == null) return false;
    return _isTextureValid(_memory!.pointer.ref);
  }

  /// Update GPU texture with new data (pixels should be able to fill texture)
  void Update(Pointer<Void> pixels)
  {
    if (!isValid()) return;
    _updateTexture(ref, pixels);
  }

  /// Update GPU texture rectangle with new data (pixels and rec should fit in texture)
  void UpdateRect(Rectangle rect, Pointer<Void> pixels)
  {
    if (!isValid()) return;
    _updateTextureRec(ref, rect.ref, pixels);
  }

  /// Draw a Texture2D
  static Draw(Texture2D texture,{ int posX = 0, int posY = 0, Color? tint })
  {
    tint ??= Color.WHITE;
    _drawTexture(texture.ref, posX, posY, tint.ref);
  }
  /// Draw a Texture2D with position defined as Vector2
  static DrawV(Texture2D texture,{ required Vector2 position, Color? tint })
  {
    tint ??= Color.WHITE;
    _drawTextureV(texture.ref, position.ref, tint.ref);
  }

  /// Draw a Texture2D with extended parameters
  static DrawEx(Texture2D texture,{ Vector2? position, double rotation = 0.0, double scale = 1.0, Color? tint })
  {
    tint ??= Color.WHITE;
    position ??= Vector2.Zero();
    _drawTextureEx(texture.ref, position.ref, rotation, scale, tint.ref);
  }

  /// Draw a part of a texture defined by a rectangle
  static DrawRec(Texture2D texture, Rectangle source,{ Vector2? position, Color? tint })
  {
    tint ??= Color.WHITE;
    position ??= Vector2.Zero();
    _drawTextureRec(texture.ref, source.ref, position.ref, tint.ref);
  }

  /// Draw a part of a texture defined by a rectangle with 'pro' parameters
  static DrawPro(Texture2D texture, Rectangle source, Rectangle dest,{ Vector2? origin, double rotation = 0.0, Color? tint })
  {
    tint ??= Color.WHITE;
    origin ??= Vector2.Zero();
    _drawTexturePro(texture.ref, source.ref, dest.ref, origin.ref, rotation, tint.ref);
  }

  /// Draws a texture (or part of it) that stretches or shrinks nicely
  static DrawNPatch(
    Texture2D texture, NPatchInfo nPatchInfo, Rectangle dest,
    { Vector2? origin, double rotation = 0.0, Color? tint }
  ) {
    tint ??= Color.WHITE;
    origin ??= Vector2.Zero();
    _drawTextureNPatch(texture.ref, nPatchInfo.ref, dest.ref, origin.ref, rotation, tint.ref);
  }

  //--------------------------------Deconstructors--------------------------------------

  // Garbage collector setup
  static final Finalizer<Pointer<_Texture>> _finalizer = Finalizer((ptr)
  {
    if(ptr.address == 0) return;

    _unloadTexture(ptr.ref);

    malloc.free(ptr);
  });

  /// Unload texture from GPU memory (VRAM)
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadTexture(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

class TextureCubemap extends Texture2D
{
  TextureCubemap._internal(_Texture texture) : super._internal(texture);

  /// Load cubemap from image, multiple image cubemap layouts supported
  factory TextureCubemap(Image image, int layout)
  {
    _TextureCubemap result = _loadTextureCubemap(image._memory!.pointer.ref, layout);

    return TextureCubemap._internal(result);
  }
}

//------------------------------------------------------------------------------------
//                                 RenderTexture2D
//------------------------------------------------------------------------------------

class RenderTexture2D implements Disposeable
{
  NativeResource<_RenderTexture2D>? _memory;

  _RenderTexture2D get ref => _memory!.pointer.ref;

	void _setmemory(_RenderTexture2D result)
	{
		if(result.id == 0) throw Exception("[Dart] Couldn't load Texture2D!");
    if (_memory != null) dispose();

    // Allocating memory in C heap
    Pointer<_RenderTexture2D> pointer = malloc.allocate<_RenderTexture2D>(sizeOf<_RenderTexture2D>());
    pointer.ref = result;
    this._memory = NativeResource<_RenderTexture2D>(pointer);

    _finalizer.attach(this, pointer, detach: this);
	}

  /// Load texture for rendering (framebuffer)
  RenderTexture2D(int width, int height)
  {
    _RenderTexture2D result = _loadRenderTexture(width, height);
    _setmemory(result);
  }

  /// Check if a render texture is valid (loaded in GPU)
  bool isValid()
  {
    if(_memory == null) return false;
    return _isRenderTextureValid(_memory!.pointer.ref);
  }
  
  // Garbage collector setup
  static final Finalizer<Pointer<_RenderTexture2D>> _finalizer = Finalizer((ptr)
  {
    if(ptr.address == 0) return;

    _unloadRenderTexture(ptr.ref);

    malloc.free(ptr);
  });

  /// Unload render texture from GPU memory (VRAM)
  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadRenderTexture(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                 NPatchInfo
//------------------------------------------------------------------------------------

/// NPatchInfo, n-patch layout info
class NPatchInfo implements Disposeable
{
  NativeResource<_NPatchInfo>? _memory;

  // ignore: unused_element
  void _setmemory(_NPatchInfo result)
  {
    if (_memory != null) dispose();
    Pointer<_NPatchInfo> pointer = malloc.allocate<_NPatchInfo>(sizeOf<_NPatchInfo>());
    pointer.ref = result;

    this._memory = NativeResource<_NPatchInfo>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  _NPatchInfo get ref => _memory!.pointer.ref;
  _Rectangle get source => ref.source;
  int get bottom => ref.bottom;
  int get top    => ref.top;
  int get left   => ref.left;
  int get right  => ref.right;
  int get layout => ref.layout;

  set source(_Rectangle value) => ref.source = value;
  set bottom(int value) => ref.bottom = (value > 0) ? value : 0;
  set top(int value) => ref.top = (value > 0) ? value : 0;
  set left(int value) => ref.left = (value > 0) ? value : 0;
  set right(int value) => ref.right = (value > 0) ? value : 0;
  set layout(int value) => ref.layout = (value > 0) ? value : 0;

  void Set({ Rectangle? source, int? bottom, int? top, int? left, int? right, int? layout})
  {
    if (source != null) this.source = source.ref;
    if (bottom != null) this.bottom = bottom;
    if (top != null) this.top = top;
    if (left != null) this.left = left;
    if (right != null) this.right = right;
    if (layout != null) this.layout = layout;
  }

  NPatchInfo({ required Rectangle source, required int bottom, required int top, required int left, required int right, required int layout })
  {
    Pointer<_NPatchInfo> pointer = malloc.allocate<_NPatchInfo>(sizeOf<_NPatchInfo>());
    pointer.ref
    ..source = source.ref
    ..bottom = bottom
    ..top    = top
    ..left   = left
    ..right  = right
    ..layout = layout;

    this._memory = NativeResource<_NPatchInfo>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_NPatchInfo>>((pointer) {
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

//------------------------------------------------------------------------------------
//                                 GlyphInfo
//------------------------------------------------------------------------------------

class GlyphInfo implements Disposeable
{
  NativeResource<_GlyphInfo>? _memory;

  // ignore: unused_element
  void _setmemory(_GlyphInfo result)
  {
    Pointer<_GlyphInfo> pointer = malloc.allocate<_GlyphInfo>(sizeOf<_GlyphInfo>());
    pointer.ref = result;

    this._memory = NativeResource<_GlyphInfo>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer((pointer) {
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

/*
  Font
  Shader
  MaterialMap
  BoneInfo
  Model
  ModelAnimation
  Ray
  RayCollision
  Wave
  VrDeviceInfo
  VrStereoConfig
  FilePathList
  AutomationEvent
  AutomationEventList
*/

//------------------------------------------------------------------------------------
//                                   Camera2D
//------------------------------------------------------------------------------------

class Camera2D implements Disposeable
{
  NativeResource<_Camera2D>? _memory;

  _Camera2D get camera => _memory!.pointer.ref;

  Camera2D({
    required Vector2 offset,
    required Vector2 target,
    required double rotation,
    required double zoom
  }) {
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
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
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
  int get projection => _memory!.pointer.ref.projection;

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
    required int projection
  }) {
    Pointer<_Camera3D> pointer = malloc.allocate<_Camera3D>(sizeOf<_Camera3D>());
    pointer.ref
    ..position = pos.ref
    ..target = target.ref
    ..up = up.ref
    ..fovy = fovy
    ..projection = projection;

    this._memory = NativeResource<_Camera3D>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Camera3D>>((pointer) {
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

//------------------------------------------------------------------------------------
//                                 BoundingBox
//------------------------------------------------------------------------------------

class BoundingBox implements Disposeable
{
  NativeResource<_BoundingBox>? _memory;

  _BoundingBox get ref => _memory!.pointer.ref;
  _Vector3 get min => ref.min;
  _Vector3 get max => ref.max;

  BoundingBox.Wrap(_BoundingBox result)
  {
    Pointer<_BoundingBox> pointer = malloc.allocate<_BoundingBox>(sizeOf<_BoundingBox>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_BoundingBox>>((pointer) {
    malloc.free(pointer);
  });
  
  @override
  void dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

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
  }

  Mesh._internal(Pointer<_Mesh> pointer,{ bool owner = false, int length = 1 }) : _length = length
  {
    _memory = NativeResource<_Mesh>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
  }

  //--------------------------------------Getters---------------------------------------
  
  _Mesh get ref => _memory!.pointer.ref;
  int get vertexCount => ref.vertexCount;
  int get triangleCount => ref.triagleCoung;

  // Vertex attributes data
  Pointer<Float> get vertices => ref.vertices;
  Pointer<Float> get texcoords => ref.texcoords;
  Pointer<Float> get texcoords2 => ref.texcoords2;
  Pointer<Float> get normals => ref.normals;
  Pointer<Float> get tangents => ref.tangents;
  Pointer<Uint8> get colors => ref.colors;
  Pointer<Uint16> get indices => ref.indices;

  // Animation vertex data
  Pointer<Float> get animVertices => ref.animVertices;
  Pointer<Float> get animNormals => ref.animNormals;
  Pointer<Uint8> get boneIds => ref.boneIds;
  Pointer<Float> get boneWeights => ref.boneWeights;
  Pointer<_Matrix> get boneMatrices => ref.boneMatrices;
  int get boneCount => ref.boneCount;

  int get vaoID => ref.vaoID;
  Pointer<Int32> get vboId => ref.vboId;

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
  void Unload() => dispose();

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
    return BoundingBox.Wrap(result);
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
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadMesh(_memory!.pointer.ref);
      _memory!.dispose();      
    }
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

  // ------------------------------Memory management------------------------------

  // ignore: unused_element
  void _setmemory(_Material result)
  {
    if (_memory != null) dispose();
    Pointer<_Material> pointer = malloc.allocate<_Material>(sizeOf<_Material>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource(pointer);
  }

  Material._internal(Pointer<_Material> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) dispose();

    _memory = NativeResource(pointer, IsOwner: owner);
    if (owner)
      _finalizer.attach(this, pointer, detach: this);
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
  void Unload() => dispose();

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

  static Finalizer _finalizer = Finalizer<Pointer<_Material>>((pointer) {
    _unloadMaterial(pointer.ref);
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    _finalizer.detach(this);
    _unloadMaterial(_memory!.pointer.ref);
    _memory!.dispose();
  }
}

//------------------------------------------------------------------------------------
//                                   Transform
//------------------------------------------------------------------------------------

class Transform implements Disposeable
{
  NativeResource<_Transform>? _memory;

  final int _length;
  int get length => _length;

  // ignore: unused_element
  void _setmemory(_Transform result)
  {
    Pointer<_Transform> pointer = malloc.allocate<_Transform>(sizeOf<_Transform>());
    pointer.ref = result;

    _memory = NativeResource<_Transform>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  Transform._internal(Pointer<_Transform> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) dispose();
    _memory = NativeResource<_Transform>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
  }

  Transform(Vector3 translation, Quaternion rotation, Vector3 scale) : _length = 1
  {
    Pointer<_Transform> pointer = malloc.allocate<_Transform>(sizeOf<_Transform>());
    pointer.ref
    ..translation = translation.ref
    ..rotation = rotation.ref
    ..scale = scale.ref;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_Transform>(pointer);
  }

  Transform operator [](int index)
  {
    if (index < 0 || index >= length) throw RangeError(index);
    return Transform._internal(_memory!.pointer + index, owner: false);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_Transform>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   BoneInfo
//------------------------------------------------------------------------------------

class BoneInfo implements Disposeable
{
  NativeResource<_BoneInfo>? _memory;
  final int _length;
  int get length => _length;

  BoneInfo._internal(Pointer<_BoneInfo> pointer,{ int length = 1, bool owner = true }) : _length = length
  {
    if (_memory != null) dispose();
    _memory = NativeResource<_BoneInfo>(pointer, IsOwner: owner);

    if (owner)
      _finalizer.attach(this, pointer, detach: this);
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
  void dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _memory!.dispose();
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
  Pointer<Int32> get meshMaterial => ref.meshMaterial;

  late final Mesh meshes;
  late final Material materials;
  late final BoneInfo bones;
  late final Transform bindPose;

  void _setmemory(_Model result)
  {
    Pointer<_Model> pointer = malloc.allocate<_Model>(sizeOf<_Model>());
    pointer.ref = result;

    _memory = NativeResource<_Model>(pointer);

    meshes    = Mesh._internal(pointer.ref.meshes, length: pointer.ref.meshCount);
    materials = Material._internal(pointer.ref.materials, length: pointer.ref.materialCount);
    bones     = BoneInfo._internal(pointer.ref.bones, length: pointer.ref.boneCount);
    bindPose  = Transform._internal(pointer.ref.bindPose, length: pointer.ref.boneCount);

    _finalizer.attach(this, pointer, detach: this);
  }

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
  BoundingBox GetBoundingBox() => BoundingBox.Wrap(_getModelBoundingBox(ref));
  /// Check if a model is valid (loaded in GPU, VAO/VBOs)
  bool IsValid() => _isModelValid(ref);
  /// Unload model (including meshes) from memory (RAM and/or VRAM)
  void Unload() => dispose();

  static final Finalizer _finalizer = Finalizer<Pointer<_Model>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    if (_memory != null && _memory!.isDisposed)
    {
      _finalizer.detach(this);
      _unloadModel(_memory!.pointer.ref);
      _memory!.dispose();
    }
  }
}

//------------------------------------------------------------------------------------
//                                   Draw
//------------------------------------------------------------------------------------
/// Drawing-related functions
abstract class Draw
{
  /// Set background color (framebuffer clear color)
  static void ClearBackground(Color color) => _clearBackground(color.ref);
  /// Setup canvas (framebuffer) to start drawing
  static void Begin() => _beginDrawing();
  /// End canvas drawing and swap buffers (double buffering)
  static void End() => _endDrawing();
  /// Update screen by calling `Begin()` `renderLogic()` and `End()` while also clearing the background
  static void RenderFrame({required void Function() renderLogic, required Color color})
  {
    Begin();
    ClearBackground(color);
    renderLogic();
    End();
  }

  /// Begin 2D mode with custom camera (2D)
  static void Begin2D(Camera2D camera) => _beginMode2D(camera.camera);
  /// Ends 2D mode with custom camera
  static void End2D() => _endMode2D();
  /// Update screen by calling `Begin2D()` `renderLogic()` and `End2D()` while also clearing the backgroundbackground
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderFrame2D({
    required void Function() renderLogic,
    required Camera2D camera,
    required Color background
  }) {
    Begin2D(camera);
    ClearBackground(background);
    renderLogic();
    End2D();
  }

  /// Begin 3D mode with custom camera (3D)
  static void Begin3D(Camera3D camera) => _beginMode3D(camera.ref);
  /// Ends 3D mode and returns to default 2D orthographic mode
  static void End3D() => _endMode3D();
  /// Update screen by calling `Begin3D()` `renderLogic()` and `End3D()` while also clearing the background
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderFrame3D({
    required void Function() renderLogic,
    required Camera3D camera,
    required Color background
  }) {
    Begin3D(camera);
    ClearBackground(background);
    renderLogic();
    End3D();
  }

  /// Begin drawing to render texture
  static void BeginTextureMode(RenderTexture2D render) => _beginTextureMode(render.ref);
  /// Ends drawing to render texture
  static void EndTextureMode() => _endTextureMode();
  /// Update screen by calling `BeginTextureMode()` `renderLogic()` and `EndTextureMode()` while also clearing the backgroundbackground
  /// 
  /// Use this on the main loop to work with Hot Reload
  static void RenderOnTexture({
    required void Function() renderLogic,
    required RenderTexture2D render,
    required Color background
  }) {
    BeginTextureMode(render);
    ClearBackground(background);
    renderLogic();
    EndTextureMode();
  }
}
