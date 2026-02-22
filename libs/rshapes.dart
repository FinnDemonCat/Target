part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Shapes3D
//------------------------------------------------------------------------------------

abstract class Shapes3D
{
  /// Draw a line in 3D world space
  static void DrawLine3D(Vector3 startPos, Vector3 endPos, Color color) => _drawLine3D(startPos.ref, endPos.ref, color.ref);
  /// Draw a point in 3D space, actually a small line
  static void DrawPoint3D(Vector3 position, Color color) => _drawPoint3D(position.ref, color.ref);
  /// Draw a circle in 3D world space
  static void DrawCircle3D(
    Vector3 center, double radius,
    Vector3 rotationAxis, double rotationAngle,
    Color color
  ) => _drawCircle3D(center.ref, radius, rotationAxis.ref, rotationAngle, color.ref);
  /// Draw a color-filled triangle (vertex in counter-clockwise order!)
  static void DrawTriangle3D(Vector3 v1, Vector3 v2, Vector3 v3, Color color) => _drawTriangle3D(v1.ref, v2.ref, v3.ref, color.ref);
  /// Draw a triangle strip defined by points
  static void DrawTriangleStrip3D(List<Vector3> points, int pointCount, Color color)
  {
    using ((Arena arena) {
      Pointer<_Vector3> cpoints = arena.allocate<_Vector3>(sizeOf<_Vector3>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x]._ptr.ref;
      }

      _drawTriangleStrip3D(cpoints, points.length, color.ref);
    });
  }
  /// Draw cube
  static void DrawCube(Vector3 position, double width, double height, double length, Color color) => _drawCube(position.ref, width, height, length, color.ref);
  /// Draw cube (Vector version)
  static void DrawCubeV(Vector3 position, Vector3 size, Color color) => _drawCubeV(position.ref, size.ref, color.ref);
  /// Draw cube wires
  static void DrawCubeWires(Vector3 position, double width, double height, double length, Color color) => _drawCubeWires(position.ref, width, height, length, color.ref);
  /// Draw cube wires (Vector version)
  static void DrawCubeWiresV(Vector3 position, Vector3 size, Color color) => _drawCubeWiresV(position.ref, size.ref, color.ref);
  /// Draw sphere
  static void DrawSphere(Vector3 centerPos, double radius, Color color) => _drawSphere(centerPos.ref, radius, color.ref);
  /// Draw sphere with extended parameters
  static void DrawSphereEx(Vector3 centerPos, double radius, int rings, int slices, Color color) => _drawSphereEx(centerPos.ref, radius, rings, slices, color.ref);
  /// Draw sphere wires
  static void DrawSphereWires(Vector3 centerPos, double radius, int rings, int slices, Color color) => _drawSphereWires(centerPos.ref, radius, rings, slices, color.ref);
  /// Draw a cylinder/cone
  static void DrawCylinder(Vector3 position, double radiusTop, double radiusBottom, double height, int slices, Color color) => _drawCylinder(position.ref, radiusTop, radiusBottom, height, slices, color.ref);
  /// Draw a cylinder with base at startPos and top at endPos
  static void DrawCylinderEx(Vector3 startPos, Vector3 endPos, double startRadius, double endRadius, int sides, Color color) => _drawCylinderEx(startPos.ref, endPos.ref, startRadius, endRadius, sides, color.ref);
  /// Draw a cylinder/cone wires
  static void DrawCylinderWires(Vector3 position, double radiusTop, double radiusBottom, double height, int slices, Color color) => _drawCylinderWires(position.ref, radiusTop, radiusBottom, height, slices, color.ref);
  /// Draw a cylinder wires with base at startPos and top at endPos
  static void DrawCylinderWiresEx(Vector3 startPos, Vector3 endPos, double startRadius, double endRadius, int sides, Color color) => _drawCylinderWiresEx(startPos.ref, endPos.ref, startRadius, endRadius, sides, color.ref);
  /// Draw a capsule with the center of its sphere caps at startPos and endPos
  static void DrawCapsule(Vector3 startPos, Vector3 endPos, double radius, int slices, int rings, Color color) => _drawCapsule(startPos.ref, endPos.ref, radius, slices, rings, color.ref);
  /// Draw capsule wireframe with the center of its sphere caps at startPos and endPos
  static void DrawCapsuleWires(Vector3 startPos, Vector3 endPos, double radius, int slices, int rings, Color color) => _drawCapsuleWires(startPos.ref, endPos.ref, radius, slices, rings, color.ref);
  /// Draw a plane XZ
  static void DrawPlane(Vector3 centerPos, Vector2 size, Color color) => _drawPlane(centerPos.ref, size.ref, color.ref);
  /// Draw a ray line
  static void DrawRay(Ray ray, Color color) => _drawRay(ray.ref, color.ref);
  /// Draw a grid (centered at (0, 0, 0))
  static void DrawGrid(int slices, double spacing) => _drawGrid(slices, spacing);
}

//------------------------------------------------------------------------------------
//                                   Shapes
//------------------------------------------------------------------------------------

/// Basic shapes drawing functions
abstract class Shapes
{
  /// Draw a pixel using geometry [Can be slow, use with care]
  static void DrawPixel(int posX, int posY,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawPixel(posX, posY, finalcolor.ref);
  }
  /// Draw a pixel using geometry (Vector version) [Can be slow, use with care]
  static void DrawPixelV(Vector2 position,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawPixelV(position.ref, finalcolor.ref);
  }

  static void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawLine(startPosX, startPosY, endPosX, endPosY, finalcolor.ref);
  }
  /// Draw a line (using gl lines)
  static void DrawLineV(Vector2 startPos, Vector2 endPos,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawLineV(startPos.ref, endPos.ref, finalcolor.ref);
  }
  /// Draw a line (using triangles/quads)
  static void DrawLineEx(Vector2 startPos, Vector2 endPos, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawLineEx(startPos.ref, endPos.ref, thick, finalcolor.ref);
  }
  /// Draw lines sequence (using gl lines)
  static void DrawLineStrip(List<Vector2> points,{ Color? color })
  {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x]._ptr.ref;
      }

      _drawLineStrip(cpoints, points.length, finalcolor.ref);
    });
  }
  /// Draw line segment cubic-bezier in-out interpolation
  static void DrawLineBezier(Vector2 startPos, Vector2 endPos, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawLineBezier(startPos.ref, endPos.ref, thick, finalcolor.ref);
  }
  /// Draw a dashed line
  static void DrawLineDashed(Vector2 startPos, Vector2 endPos, int dashSize, int spaceSize,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawLineDashed(startPos.ref, endPos.ref, dashSize, spaceSize, finalcolor.ref);
  }
  /// Draw a color-filled circle
  static void DrawCircle(int centerX, int centerY, double radius,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawCircle(centerX, centerY, radius, finalcolor.ref);
  }
  /// Draw a piece of a circle
  static void DrawCicleSector(Vector2 center, double radius,{ required double startAngle, required double endAngle, required int segments, Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawCircleSector(center.ref, radius, startAngle, endAngle, segments, finalcolor.ref);
  }
  /// Draw circle sector outline
  static void DrawCircleSectorLines(Vector2 center, double radius,{ required double startAngle, required double endAngle, required int segments, Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawCircleSectorLines(center.ref, radius, startAngle, endAngle, segments, finalcolor.ref);
  }
  /// Draw a gradient-filled circle
  static void DrawCircleGradient(int centerX, int centerY, double radius,{ required Color inner, required Color outer }) {
    _drawCircleGradient(centerX, centerY, radius, inner.ref, outer.ref);
  }
  /// Draw a color-filled circle (Vector version)
  static void DrawCircleV(Vector2 center, double radius,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawCircleV(center.ref, radius, finalcolor.ref);
  }
  /// Draw circle outline
  static void DrawCircleLines(int centerX, int centerY, double radius,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawCircleLines(centerX, centerY, radius, finalcolor.ref);
  }
  /// Draw circle outline (Vector version)
  static void DrawCircleLinesV(Vector2 center, double radius,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawCircleLinesV(center.ref, radius, finalcolor.ref);
  }
  /// Draw ellipse
  static void DrawEllipse(int centerX, int centerY, double radiusH, double radiusV,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawEllipse(centerX, centerY, radiusH, radiusV, finalcolor.ref);
  }
  /// Draw ellipse (Vector version)
  static void DrawEllipseV(Vector2 center, double radiusH, double radiusV,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;
    
    _drawEllipseV(center.ref, radiusH, radiusV, finalcolor.ref);
  }
  /// Draw ellipse outline
  static void DrawEllipseLines(int centerX, int centerY, double radiusH, double radiusV,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawEllipseLines(centerX, centerY, radiusH, radiusV, finalcolor.ref);
  }
  /// Draw ellipse outline (Vector version)
  static void DrawEllipseLinesV(Vector2 center, double radiusH, double radiusV,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawEllipseLinesV(center.ref, radiusH, radiusV, finalcolor.ref);
  }
  /// Draw ring
  static void DrawRing(Vector2 center, double innerRadius, double outerRadius,{ required double startAngle, required double endAngle, required int segments, Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRing(center.ref, innerRadius, outerRadius, startAngle, endAngle, segments, finalcolor.ref);
  }
  /// Draw ring outline
  static void DrawRingLines(Vector2 center, double innerRadius, double outerRadius,{ required double startAngle, required double endAngle, required int segments, Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRingLines(center.ref, innerRadius, outerRadius, startAngle, endAngle, segments, finalcolor.ref);
  }
  /// Draw a color-filled rectangle
  static void DrawRectangle(int posX, int posY, int width, int height,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangle(posX, posY, width, height, finalcolor.ref);
  }
  /// Draw a color-filled rectangle (Vector version)
  static void DrawRectangleV(Vector2 position, Vector2 size,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangleV(position.ref, size.ref, finalcolor.ref);
  }
  /// Draw a color-filled rectangle
  static void DrawRectangleRec(Rectangle rec,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangleRec(rec.ref, finalcolor.ref);
  }
  /// Draw a color-filled rectangle with pro parameters
  static void DrawRectanglePro(Rectangle rec, Vector2 origin,{ double rotation = 0.0, Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectanglePro(rec.ref, origin.ref, rotation, finalcolor.ref);
  }
  /// Draw a vertical-gradient-filled rectangle
  static void DrawRectangleGradientV(int posX, int posY, int width, int height,{ required Color top, required Color bottom }) {
    _drawRectangleGradientV(posX, posY, width, height, top.ref, bottom.ref);
  }
  /// Draw a horizontal-gradient-filled rectangle
  static void DrawRectangleGradientH(int posX, int posY, int width, int height,{ required Color left, required Color right }) {
    _drawRectangleGradientH(posX, posY, width, height, left.ref, right.ref);
  }
  /// Draw a gradient-filled rectangle with custom vertex colors
  static void  DrawRectangleGradientEx(Rectangle rec,{ required Color topLeft, required Color bottomLeft, required Color bottomRight, required Color topRight }) {
    _drawRectangleGradientEx(rec.ref, topLeft.ref, bottomLeft.ref, bottomRight.ref, topRight.ref);
  }
  /// Draw rectangle outline
  static void DrawRectangleLines(int posX, int posY, int width, int height,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;
    
    _drawRectangleLines(posX, posY, width, height, finalcolor.ref);
  }
  /// Draw rectangle outline with extended parameters
  static void DrawRectangleLinesEx(Rectangle rec, double lineThick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangleLinesEx(rec.ref, lineThick, finalcolor.ref);
  }
  /// Draw rectangle with rounded edges
  static void DrawRectangleRounded(Rectangle rec, double roundness, int segments,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangleRounded(rec.ref, roundness, segments, finalcolor.ref);
  }
  /// Draw rectangle lines with rounded edges
  static void DrawRectangleRoundedLines(Rectangle rec, double roundness, int segments,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangleRoundedLines(rec.ref, roundness, segments, finalcolor.ref);
  }
  /// Draw rectangle with rounded edges outline
  static void DrawRectangleRoundedLinesEx(Rectangle rec, double roundness, int segments, double lineThick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawRectangleRoundedLinesEx(rec.ref, roundness, segments, lineThick, finalcolor.ref);
  }
  /// Draw a color-filled triangle (vertex in counter-clockwise order!)
  static void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawTriangle(v1.ref, v2.ref, v3.ref, finalcolor.ref);
  }
  /// Draw triangle outline (vertex in counter-clockwise order!)
  static void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawTriangleLines(v1.ref, v2.ref, v3.ref, finalcolor.ref);
  }
  /// Draw a triangle fan defined by points (first vertex is the center)
  static void DrawTriangleFan(List<Vector2> points,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x]._ptr.ref;
      }

      _drawTriangleFan(cpoints, points.length, finalcolor.ref);
    }); 
  }
  /// Draw a regular polygon (Vector version)
  static void DrawTriangleStrip(List<Vector2> points,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x]._ptr.ref;
      }

      _drawTriangleStrip(cpoints, points.length, finalcolor.ref);
    }); 
  }
  /// Draw a regular polygon (Vector version)
  static void DrawPoly(Vector2 center, int sides, double radius, double rotation,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawPoly(center.ref, sides, radius, rotation, finalcolor.ref);
  }
  /// Draw a polygon outline of n sides
  static void DrawPolyLines(Vector2 center, int sides, double radius, double rotation,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawPolyLines(center.ref, sides, radius, rotation, finalcolor.ref);
  }
  /// Draw a polygon outline of n sides with extended parameters
  static void DrawPolyLinesEx(Vector2 center, int sides, double radius, double rotation, double lineThick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawPolyLinesEx(center.ref, sides, radius, rotation, lineThick, finalcolor.ref);
  }
}
