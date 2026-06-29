# Raylib Bindings Manual
Raylib structs are mapped to shadow classes (Rectangle, Vector, Image, etc.) or wrapper and utility classes (Draw, Window, etc.). Due to `dart:ffi` limitations, all Raylib data struct implementations extend `NativeWrapper<T extends NativeType>`, which manages allocation and deallocation of the native memory pointer.

```dart
class NativeWrapper<T extends NativeType> {
  /// The raw physical address pointer pointing to the native heap memory.
  final Pointer<T> pointer;
  /// The number of sequential elements of type [T] allocated in memory (useful for arrays).
  final int length;
  [...]
}
```

All classes that use `NativeResource<T>` and inherit from `Disposable` implement a `Free()` method. This function calls the respective native `Unload` functions, detaches the instance from the `Dart Garbage Collector`, and frees the `pointer` from the native heap.

```dart
@override
void Free() {
	if (_memory != null && !_memory!.isDisposed) {
		_finalizer.detach(this);
		_unloadTexture(ref);
		_memory!.Free(); // Calls in function free()
	}
}  
```
### Memory Safety Net
All NativeWrapper inheritance classes implement a `static final _finalizer` which adds the instance to Dart Garbage Collector, calling `malloc.free()` on the pointer. However, due to the umpredictability of the Garbage Collector, a helper class was implemented, the `RayArena`
```dart
class RaylibArena {
  final List<NativeWrapper> _registry;

  RaylibArena([List<NativeWrapper>? instances]) : _registry = instances ?? [];
  [...]
}
```

RayArena implements three methods:
- **register/registerAll**: take the input, adds to the registry and, for `register`, returns. registerAll can be used as a deconstructor to be called on global variables at `main` before closing the program.
- **release**: calls `Free()` on all instances in the `registry` list.
- **run**: simply calls the anonymous function passed.

To avoid creating a new variable for every use of `RayArena`, its recomended the use of this another method, the rayCompute that mirrors the `ffi` package.
```dart
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
```
### Example:
```dart
prop.Draw(); // Calling Draw method assigned to for its Model member

// Drawing the BoundingBox cube wires. rayCompute.
// It returns the result inside the anonymous function, however in the operator
// subtraction, we use [register] method to add it to the arena
rayCompute((rayArena) {
  var size = rayArena.register(prop.boundingBox.max - prop.boundingBox.min);
  Shapes3D.DrawCubeWiresV(prop.position, size, .WHITE);
});
```
**Developer Note:** Most constructors define an optional `RayArena` parameter to automatically add it to the arena. In cases were is isn't viable we call rayArena.register on it manually. 

## Extending and Composing Classes
In Dart, `extends` creates an inheritance relationship, while `implements` defines a obrigatory method.

When composing classes that contain Raylib types, its important to add `Disposeable` as the class inheritance and `override` the `Free()` to free these members.

```dart
class Prop implements Disposeable {
  /// Prop respective model
  final Model model;
  /// Prop user defined collision box
  late final BoundingBox boundingBox;
  /// Prop transform for drawing and collision computations
  late final Transform transform;

  [...]

  @override
  void Free() {
    model.Free();
    transform.Free();
    position.Free();
  }
}

```

## Text & Textcodepoint Classes
To maximize performance, these utility classes were created to syncronize a `C string` pointer to it's `string` twin member.
```dart
class Text implements Disposeable
{
  StringBuffer _buffer = StringBuffer();
  late Pointer<Uint8> _array;

  [...]

  Pointer<Utf8> get ref
  {
    if (_isDirt) {
      final units = utf8.encode(_buffer.toString());
      _EnsureCapacity(units.length);
      _array.asTypedList(_length).setAll(0, units);
      _array[units.length] = 0;
      _isDirt = false;
    }

    return _array.cast<Utf8>();
  }
}
```
### Key Features:
* **Lazy Syncronization**: The array pointer only expands its memory when `ref` getter is called.
* **Memory Safety**: `Disposeable` and `Finalizer` are integrated to give the user a safety nest if `dispose()` isn't called.
* **Exponential Allocation**: The array is automatically resized by doubling it's capacity. Achieving more efficiency for big texts.