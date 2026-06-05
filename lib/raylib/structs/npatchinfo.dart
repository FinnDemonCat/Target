part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                 NPatchInfo
//------------------------------------------------------------------------------------

/// NPatchInfo, n-patch layout info
class NPatchInfo extends NativeWrapper<_NPatchInfo>
{
  // NativeResource<_NPatchInfo>? _memory;

  /*
  void _setmemory(_NPatchInfo result)
  {
    if (_memory != null) Free();
    Pointer<_NPatchInfo> pointer = malloc.allocate<_NPatchInfo>(sizeOf<_NPatchInfo>());
    pointer.ref = result;

    this._memory = NativeResource<_NPatchInfo>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }
  */

  _NPatchInfo get ref => pointer.ref;
  _Rectangle get source => ref.source;
  int get bottom => ref.bottom;
  int get top    => ref.top;
  int get left   => ref.left;
  int get right  => ref.right;
  int get layout => ref.layout;

  set source(_Rectangle value) => ref.source = value;
  set bottom(int value) => ref.bottom = value.clamp(0.0, value).toInt();
  set top(int value) => ref.top = value.clamp(0.0, value).toInt();
  set left(int value) => ref.left = value.clamp(0.0, value).toInt();
  set right(int value) => ref.right = value.clamp(0.0, value).toInt();
  set layout(NPatchLayout layout) => ref.layout = layout.index;

  void Set({ Rectangle? source, int? bottom, int? top, int? left, int? right, NPatchLayout? layout})
  {
    if (source != null) this.source = source.ref;
    if (bottom != null) this.bottom = bottom;
    if (top != null) this.top = top;
    if (left != null) this.left = left;
    if (right != null) this.right = right;
    if (layout != null) this.layout = layout;
  }

  NPatchInfo({
    required Rectangle source,
    required int bottom,
    required int top,
    required int left,
    required int right,
    required NPatchLayout layout
  }) : super(sizeOf<_NPatchInfo>())
  {
    // Pointer<_NPatchInfo> pointer = malloc.allocate<_NPatchInfo>(sizeOf<_NPatchInfo>());
    ref
    ..source = source.ref
    ..bottom = bottom
    ..top    = top
    ..left   = left
    ..right  = right
    ..layout = layout.index;

    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_NPatchInfo>>((pointer) {
    malloc.free(pointer);
  });

  
  @override
  void Free() {
    _finalizer.detach(this);
    super.Free();
  }
}
