part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Collision
//------------------------------------------------------------------------------------
/// Basic shapes collision detection functions
abstract class Collision
{
  /// Check collision between two rectangles
  static bool CheckRecs(Rectangle rec1, Rectangle rec2) => _checkCollisionRecs(rec1.ref, rec2.ref);
  /// Check collision between two circles
  static bool CheckCircles(Vector2 center1, double radius1, Vector2 center2, double radius2) => _checkCollisionCircles(center1.ref, radius1, center2.ref, radius2);
  /// Check collision between circle and rectangle
  static bool CheckCircleRec(Vector2 center, double radius, Rectangle rec) => _checkCollisionCircleRec(center.ref, radius, rec.ref);
  /// Check if circle collides with a line created betweeen two points [p1] and [p2]
  static bool CheckCircleLine(Vector2 center, double radius, Vector2 p1, Vector2 p2) => _checkCollisionCircleLine(center.ref, radius, p1.ref, p2.ref);
  /// Check if point is inside rectangle
  static bool CheckPointRec(Vector2 point, Rectangle rec) => _checkCollisionPointRec(point.ref, rec.ref);
  /// Check if point is inside circle
  static bool CheckPointCircle(Vector2 point, Vector2 center, double radius) => _checkCollisionPointCircle(point.ref, center.ref, radius);
  /// Check if point is inside a triangle
  static bool CheckPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3) => _checkCollisionPointTriangle(point.ref, p1.ref, p2.ref, p3.ref);
  /// Check if point belongs to line created between two points [p1] and [p2] with defined margin in pixels [threshold]
  static bool CheckPointLine(Vector2 point, Vector2 p1, Vector2 p2, int threshold) => _checkCollisionPointLine(point.ref, p1.ref, p2.ref, threshold);
  /// Check if point is within a polygon described by array of vertices
  static bool CheckPointPoly(Vector2 point, List<Vector2> points) {
    return using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
        for (int x = 0; x < points.length; x++) {
          cpoints[x] = points[x].ref;
        }

        return _checkCollisionPointPoly(point.ref, cpoints, points.length);
    });
  }
  /// Check the collision between two lines defined by two points each, returns collision point by reference
  /// 
  /// DevNote: Pass the Vector2 out as an instance of Vector2 on [collisionPoint] as normal
  static bool CheckLines(Vector2 startPos1, Vector2 endPos1, Vector2 startPos2, Vector2 endPos2, Vector2 collisionPoint) {
    bool result = false;
    
    using ((Arena arena) {
      Pointer<_Vector2> cpointer = arena.allocate<_Vector2>(sizeOf<_Vector2>());

      result = _checkCollisionLines(startPos1.ref, startPos2.ref, endPos1.ref, endPos2.ref, cpointer);
      collisionPoint.ref = cpointer.ref;
    });

    return result;
  }
  /// Get collision rectangle for two rectangles collision
  static Rectangle GetRec(Rectangle rec1, Rectangle rec2) => Rectangle._recieve(_getCollisionRec(rec1.ref, rec2.ref));
}

//------------------------------------------------------------------------------------
//                                   Collision 3D
//------------------------------------------------------------------------------------
/// 3D Collision detection functions
abstract class Collision3D
{
  /// Check collision between two spheres
  static bool CheckSpheres(Vector3 center1, double radius1, Vector3 center2, double radius2) => _checkCollisionSpheres(center1.ref, radius1, center2.ref, radius2);
  /// Check collision between two bounding boxes
  static bool CheckBoxes(BoundingBox box1, BoundingBox box2) => _checkCollisionBoxes(box1.ref, box2.ref);
  /// Check collision between box and sphere
  static bool CheckBoxSphere(BoundingBox box, Vector3 center, double radius) => _checkCollisionBoxSphere(box.ref, center.ref, radius);
  /// Get collision info between ray and sphere
  static RayCollision GetRayCollisionSphere(Ray ray, Vector3 center, double radius) => RayCollision._recieve(_getRayCollisionSphere(ray.ref, center.ref, radius));
  /// Get collision info between ray and box
  static RayCollision GetRayCollisionBox(Ray ray, BoundingBox box) => RayCollision._recieve(_getRayCollisionBox(ray.ref, box.ref));
  /// Get collision info between ray and mesh
  static RayCollision GetRayCollisionMesh(Ray ray, Mesh mesh, Matrix transform) => RayCollision._recieve(_getRayCollisionMesh(ray.ref, mesh.ref, transform.ref));
  /// Get collision info between ray and triangle
  static RayCollision GetRayCollisionTriangle(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3) => RayCollision._recieve(_getRayCollisionTriangle(ray.ref, p1.ref, p2.ref, p3.ref));
  /// Get collision info between ray and quad
  static RayCollision GetRayCollisionQuad(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4) => RayCollision._recieve(_getRayCollisionQuad(ray.ref, p1.ref, p2.ref, p3.ref, p4.ref));
}