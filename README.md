# 🎯**Target** - Raylib Powered Engine
Dart is a high level, strongly typed, OOP language that offers minimum symbol noise in favor of an intuitive syntax.

This project aims to bring powerfull C libraries to Dart ecosystem with seamless integration, taking advantage of its QoL featues, such as `constructors`, `named constructors` and `factories`, to instance variables with an intuitive formatting, while maintaining minimal overhead on the FFI bridge.

## 📦 Core Modules
- **[Raylib](https://github.com/raysan5/raylib/tree/master)**: The core library for windowing and graphics.

### 🖥️ Raylib Core Features
- **Intuitive Syntax**: Idiomatic instancing of Raylib types (Rectangles, Colors, Matrices).
- **Memory Safety**: Seamless integration with Dart GC and native `Unload` functions.
- **High Performance**: Minimal FFI overhead.

### Official C Example
```
#include "raylib.h"

int main(void)
{
    InitWindow(800, 450, "raylib [core] example - basic window");

    while (!WindowShouldClose())
    {
        BeginDrawing();
            ClearBackground(RAYWHITE);
            DrawText("Congrats! You created your first window!", 190, 200, 20, LIGHTGRAY);
        EndDrawing();
    }

    CloseWindow();

    return 0;
}
```
### Basic Dart Example
```
void main()
{
	Window.Init(width: 800, height: 450, title: "raylib [core] example - basic window");

	while(!Window.ShouldClose())
	{
		Draw.Begin();
			Draw.ClearBackground(Color.RAYWHITE);
			Text.Draw("Congrats! You created your first window!", 20, posX: 190, posY: 200, color: Color.LIGHTGRAY);
		Draw.End();
	}

	Window.Close()
}
```

## 📄Planned Cores Integrations
- **[JoltC](https://github.com/amerkoleci/joltc)**: Jolt Physics C bindings, a popular game physics simulation library.
- **[RAudio](https://github.com/raysan5/raudio)**: Raylib audio module for audio managemente
