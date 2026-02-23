part of 'raylib.dart';

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
  
  Matrix._recieve(_Matrix result)
  {
    _setMemory(result);
  }

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
