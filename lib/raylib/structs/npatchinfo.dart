part of '../raylib.dart';

//------------------------------------------------------------------------------------
//                                 NPatchInfo
//------------------------------------------------------------------------------------

typedef _FreeNPatchInfoC    = Void Function(Pointer<Void> token);
// typedef _FreeNPatchInfoDart = void Function(Pointer<Void> token);
final _freeNPatchInfo = _dyReleaseLib.lookup<NativeFunction<_FreeNPatchInfoC>>('FreeNPatchInfo');

/// NPatchInfo, n-patch layout info
class NPatchInfo extends NativeWrapper<_NPatchInfo> implements Finalizable {
	_NPatchInfo get ref => pointer.ref;
	set ref(_NPatchInfo value) => pointer.ref = value;

	/// Texture source rectangle
	_Rectangle get source => ref.source;
	/// Left border offset
	int get left => ref.left;
	/// Top border offset
	int get top => ref.top;
	/// Right border offset
	int get right => ref.right;
	/// Bottom border offset
	int get bottom => ref.bottom;
	/// Layout of the n-patch: 3x3, 1x3 or 3x1
	int get layout => ref.layout;

	set source(Rectangle value) => ref.source = value.ref;
	set left(int value) => ref.left = value;
	set top(int value) => ref.top = value;
	set right(int value) => ref.right = value;
	set bottom(int value) => ref.bottom = value;
	set layout(NPatchLayout value) => ref.layout = value.index;

  void Set({ Rectangle? source, int? bottom, int? top, int? left, int? right, NPatchLayout? layout})
  {
    if (source != null) this.source = source;
    if (bottom != null) this.bottom = bottom;
    if (top != null) this.top = top;
    if (left != null) this.left = left;
    if (right != null) this.right = right;
    if (layout != null) this.layout = layout;
  }

	NPatchInfo({
    required Rectangle source,
    int left = 0,
    int top = 0,
    int right = 0,
    int bottom = 0,
    NPatchLayout layout = .NPATCH_NINE_PATCH}
  ) : super(sizeOf<_NPatchInfo>()) {
		ref
			..source = source.ref
			..left = left
			..top = top
			..right = right
			..bottom = bottom
			..layout = layout.index;

		_nativeFinalizer.attach(this, pointer.cast(), detach: this);
	}

	// =================================== Deconstructor ====================================

	static final _nativeFinalizer = NativeFinalizer(_freeNPatchInfo);
  
  @override
  void Free() {
    _nativeFinalizer.detach(this);
    super.Free();
  }
}
