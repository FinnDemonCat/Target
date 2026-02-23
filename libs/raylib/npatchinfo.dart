part of 'raylib.dart';

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
