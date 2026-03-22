import '../libs/raylib/raylib.dart';
import 'haybale.dart';

class Button extends Interactible
{
  late NPatchInfo nPatchInfo;
  static final Texture texture = Texture("C:\\Users\\Calie\\Documents\\Code\\Dart\\Target\\assets\\panel_dark.png");

  Button({HaySize? sizing, super.OnPress,}) :
    super(sizing: sizing ?? HaySize.Grow()) {
    Rectangle source = Rectangle(0.0, 0.0, texture.width.toDouble(), texture.heigth.toDouble());

    nPatchInfo = NPatchInfo(
      source: source,
      bottom: 4,
      top: 4,
      left: 4,
      right: 4,
      layout: NPatchLayout.NPATCH_NINE_PATCH
    );

    source.Dispose();
  }

  @override
  void DrawWidget() {
    Texture2D.DrawNPatch(texture, nPatchInfo, this);
    super.DrawWidget();
  }

  @override
  void Dispose() { 
    nPatchInfo.Dispose();
    super.Dispose();
  }
}