part of 'raylib.dart';

//------------------------------------------------------------------------------------
//                                   Splines
//------------------------------------------------------------------------------------

abstract class Splines
{
  /// Draw spline: Linear, minimum 2 points
  static void DrawLinear(List<Vector2> points, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x].ref;
      }

      _drawSplineLinear(cpoints, points.length, thick, finalcolor.ref);
    });
  }

  /// Draw spline: B-Spline, minimum 4 points
  static void DrawBasis(List<Vector2> points, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x].ref;
      }

      _drawSplineBasis(cpoints, points.length, thick, finalcolor.ref);
    });
  }
  
  /// Draw spline: Catmull-Rom, minimum 4 points
  static void DrawCatmullRom(List<Vector2> points, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x].ref;
      }

      _drawSplineCatmullRom(cpoints, points.length, thick, finalcolor.ref);
    });
  }
  
  /// Draw spline: Quadratic Bezier, minimum 3 points (1 control point): [p1, c2, p3, c4...]
  static void DrawBezierQuadratic(List<Vector2> points, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x].ref;
      }

      _drawSplineBezierQuadratic(cpoints, points.length, thick, finalcolor.ref);
    });
  }

  /// Draw spline: Cubic Bezier, minimum 4 points (2 control points): [p1, c2, c3, p4, c5, c6...]
  static void DrawBezierCubic(List<Vector2> points, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    using ((Arena arena) {
      Pointer<_Vector2> cpoints = arena.allocate<_Vector2>(sizeOf<_Vector2>() * points.length);
      for (int x = 0; x < points.length; x++) {
        cpoints[x] = points[x].ref;
      }

      _drawSplineBezierCubic(cpoints, points.length, thick, finalcolor.ref);
    });
  }

  /// Draw spline segment: Linear, 2 points
  static DrawSegmentLinear(Vector2 p1, Vector2 p2, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawSplineSegmentLinear(p1.ref, p2.ref, thick, finalcolor.ref);
  }

  /// Draw spline segment: B-Spline, 4 points
  static DrawSegmentBasis(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawSplineSegmentBasis(p1.ref, p2.ref, p3.ref, p4.ref, thick, finalcolor.ref);
  }
  
  /// Draw spline segment: Catmull-Rom, 4 points
  static DrawSegmentCatmullRom(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawSplineSegmentCatmullRom(p1.ref, p2.ref, p3.ref, p4.ref, thick, finalcolor.ref);
  }

  /// Draw spline segment: Quadratic Bezier, 2 points, 1 control point
  static DrawSegmentBezierQuadratic(Vector2 p1, Vector2 c2, Vector2 p3, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawSplineSegmentBezierQuadratic(p1.ref, c2.ref, p3.ref, thick, finalcolor.ref);
  }

  /// Draw spline segment: Cubic Bezier, 2 points, 2 control points  
  static DrawSegmentBezierCubic(Vector2 p1, Vector2 c2, Vector2 c3, Vector2 p4, double thick,{ Color? color }) {
    final finalcolor = color ?? Color.WHITE;

    _drawSplineSegmentBezierCubic(p1.ref, c2.ref, c3.ref, p4.ref, thick, finalcolor.ref);
  }
}