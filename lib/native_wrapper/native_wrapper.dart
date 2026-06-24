import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

export 'dart:ffi';
export 'package:ffi/ffi.dart';
export 'package:meta/meta.dart';

/// Simple Dart FFI helper utilities.
///
/// Use [RaylibArena] to group temporary native allocations and free them
/// automatically when the arena is released. Use [NativeWrapper] to attach
/// ownership metadata to native pointers and avoid accidental double-free.
class RaylibArena {
  final List<NativeWrapper> _registry;

  RaylibArena([List<NativeWrapper>? instances]) : _registry = instances ?? [];

  /// Registers a [NativeWrapper] instance with the arena, ensuring that it will be automatically released when the arena is released.
  T register<T extends NativeWrapper<NativeType>>(T instance) {
    _registry.add(instance);
    return instance;
  }

  void registerAll(List<NativeWrapper> instances) => _registry.addAll(instances);

  /// Releases all registered [NativeWrapper] instances, freeing their associated native resources.
  void release() {
    for (var instance in _registry) instance.Free();
  }

  /// Runs a callback function within the context of a [RaylibArena], ensuring that
  /// all native resources allocated during the callback are automatically released when the arena is released.
  T run<T extends NativeWrapper<NativeType>>(void Function(RaylibArena arena) rayArena) {
    final arena = RaylibArena();
    final result = rayArena.call(arena);

    try {
      return result as T;
    }
    finally {
      arena.release();
    }
  }
}

/// A utility function that executes a callback within the context of a [RaylibArena].
T rayCompute<T extends NativeWrapper?>(T Function(RaylibArena arena) rayArena) {
  final arena = RaylibArena();
  final result = rayArena.call(arena);

  try {
    return result;
  }
  finally {
    arena.release();
  }
}

/// A base utility class designed to manage the lifecycle and allocation 
/// of native C memory resources through Dart FFI.
///
/// It acts as a wrapper around raw pointers, ensuring safe memory deallocation
/// and preventing memory leaks.
class NativeWrapper<T extends NativeType> {
  /// The raw physical address pointer pointing to the native heap memory.
  final Pointer<T> pointer;
  /// The number of sequential elements of type [T] allocated in memory (useful for arrays).
  final int length;

  bool _disposed = false;
  /// Indicates whether the native memory has already been deallocated.
  bool get IsDisposed => _disposed;
  /// Determines if this Dart instance is responsible for freeing the native memory.
  /// 
  /// If `true`, the memory will be released when [Free] is called. If `false`, 
  /// the memory is treated as an external reference managed elsewhere.
  bool IsOwner = true;

  /// An iterable helper getter set as a standard for the user to implement
  /// the necessary iterator when the pointer acts as an array
  Iterable<NativeWrapper<T>> get values => [this];

  /// Default constructor that allocates a fresh block of native memory on the C heap.
  /// 
  /// The total size allocated is calculated as `size * length`.
  NativeWrapper(int size,{ this.IsOwner = true, this.length = 1, RaylibArena? arena }) :
    pointer = malloc.allocate<T>(size * length) {
    if (IsOwner) arena?.register(this);
  }
  
  /// Alternative constructor to wrap an existing native pointer without reallocating memory.
  /// 
  /// Defaults [IsOwner] to `false` to prevent accidental double-free bugs.
  NativeWrapper.fromAddress(Pointer<T> pointer,{ this.IsOwner = false, this.length = 1, RaylibArena? arena }) :
    pointer = .fromAddress(pointer.address) {
    if (IsOwner) arena?.register(this);
  }

  /// Releases the allocated native memory associated with [pointer].
  /// 
  /// This operation will only execute if the object is the [IsOwner] and 
  /// has not been [IsDisposed] yet.
  @mustCallSuper
  void Free() {
    if (IsDisposed)
      return;
    if (!IsOwner)
      return;
    
    _disposed = true;
    malloc.free(this.pointer);
  }
}

String fromCharArray(Array<Uint8> name, int size) {
  List<int> array = [];

  for (int x = 0; x < size && name[x] != 0; x++)
    array.add(name[x]);

  return String.fromCharCodes(array);
}

extension ListToPointer on Uint8List {
  Pointer<Utf8> toUTF8Pointer({Allocator allocator = malloc}) {
    final ptr = allocator.allocate<Uint8>(this.length + 1);
    final nativeList = ptr.asTypedList(this.length + 1);
  
    nativeList.setAll(0, this);
    nativeList[this.length] = 0;
    return ptr.cast<Utf8>();
  }
}

extension PointerCompare on Pointer {
  bool get IsNull {
    if (this.address == 0) return true;
    else return false;
  }

  bool get IsNotNull {
    if (this.address != 0) return true;
    else return false;
  }
}