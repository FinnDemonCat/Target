# Raylib Bindings Manual
Raylib structs are mapped to Shadow Classes (Rectangle, Vector, Image, etc.) or Utility Classes (Draw, Window, etc.). Due to `dart:ffi` limitations, these classes allocate pointers on the **native heap**:

```dart
// NativeResource<T> is a convenience class to house the native pointer
NativeResource<_Vector2>? memory;
```

All classes that use `NativeResource<T>` and inherit from `Disposable` implement a `dispose()` method. This function calls the respective native `Unload` functions, detaches the instance from the `Dart Garbage Collector`, and frees the `pointer` from the native heap.

```dart
@override
void dispose() {
	if (_memory != null && !_memory!.isDisposed) {
		_finalizer.detach(this);
		_unloadTexture(ref);
		_memory!.dispose(); // Calls in function free()
	}
}  
```
### Finalizer Safety Net
Complementing the `dispose()` method, these classes include a `Finalizer`. This acts as a destructor that is triggered when the instance is collected by the Dart Garbage Collector.

However, since the allocated memory lies outside the Dart Environment (Native Heap), the Dart GC is unpredictable regarding when it will trigger these finalizers. In high-performance scenarios like game loops, relying solely on the GC can lead to VRAM or RAM exhaustion before a collection occurs.

## Extending and Composing Classes
In Dart, `extends` creates an inheritance relationship, while `implements` defines a contract. 

When creating custom classes that house Raylib resources (e.g., a `Player` class with a `Texture2D`), it is best practice to:
1. **Implement `Disposable`**: Signifies that your class requires manual cleanup.
2. **Override `dispose()`**: Explicitly call `.dispose()` on all internal Raylib members.

```dart
class Player implements Disposable {
  final Texture2D sprite;
  final Vector2 position;

  Player(this.sprite, this.position);

  @override
  void dispose() {
    sprite.dispose(); // Cleanup native VRAM
    position.dispose();    // Cleanup native Vector2 instance
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