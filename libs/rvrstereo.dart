part of 'raylib.dart';

class VrDeviceInfo implements Disposeable
{
  NativeResource<_VrDeviceInfo>? _memory;
  _VrDeviceInfo get ref => _memory!.pointer.ref;
  int get hResolution => ref.hResolution;
  int get vResolution => ref.vResolution;
  double get hScreenSize => ref.hScreenSize;
  double get vScreenSize => ref.vScreenSize;
  double get eyeToScreenDistance => ref.eyeToScreenDistance;
  double get lensSeparationDistance => ref.lensSeparationDistance;
  double get interpupillaryDistance => ref.interpupillaryDistance;

  set hResolution(int value) => ref.hResolution = value;
  set vResolution(int value) => ref.vResolution = value;
  set hScreenSize(double value) => ref.hScreenSize = value;
  set vScreenSize(double value) => ref.vScreenSize = value;
  set eyeToScreenDistance(double value) => ref.eyeToScreenDistance = value;
  set lensSeparationDistance(double value) => ref.lensSeparationDistance = value;
  set interpupillaryDistance(double value) => ref.interpupillaryDistance = value;

  List<double> _lensDistortionValues = [];
  List<double> get lensDistortionValues {
    if (_lensDistortionValues.isEmpty) {
      for (int x = 0; x < 4; x++)
        _lensDistortionValues.add(ref.lensDistortionValues[x]);
    }

    return _lensDistortionValues;
  }

  set lensDistortionValues(List<double> value) {
    if (value.length != 4) return;
    for (int x = 0; x < 4; x++) {
      ref.lensDistortionValues[x] = value[x];
    }
    _lensDistortionValues = List.from(value);
  }
  
  List<double> _chromaAbCorrection = [];
  List<double> get chromaAbCorrection {
    if (_chromaAbCorrection.isEmpty) {
      for (int x = 0; x < 4; x++)
        _chromaAbCorrection.add(ref.chromaAbCorrection[x]);
    }

    return _chromaAbCorrection;
  }

  set chromaAbCorrection(List<double> value) {
    if (value.length != 4) return;
    for (int x = 0; x < 4; x++) {
      ref.chromaAbCorrection[x] = value[x];
    }
    _chromaAbCorrection = List.from(value);
  }

  /*
  void _setmory(_VrDeviceInfo result)
  {
    Pointer<_VrDeviceInfo> pointer = malloc.allocate<_VrDeviceInfo>(sizeOf<_VrDeviceInfo>());
    pointer.ref = result;

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_VrDeviceInfo>(pointer);
  }
  */

  /// Dev Note: These default values were defined by an AI
  VrDeviceInfo({
    int hResolution = 1280,
    int vResolution = 720,
    double hScreenSize = 0.1497,
    double vScreenSize = 0.0935,
    double eyeToScreenDistance = 0.041,
    double lensSeparationDistance = 0.0635,
    double interpupillaryDistance = 0.0635,
    List<double>? lensDistortion,
    List<double>? chromaAb,
  }) {
    Pointer<_VrDeviceInfo> pointer = malloc.allocate<_VrDeviceInfo>(sizeOf<_VrDeviceInfo>());
    
    pointer.ref
      ..hResolution = hResolution
      ..vResolution = vResolution
      ..hScreenSize = hScreenSize
      ..vScreenSize = vScreenSize
      ..eyeToScreenDistance = eyeToScreenDistance
      ..lensSeparationDistance = lensSeparationDistance
      ..interpupillaryDistance = interpupillaryDistance;

    final ld = lensDistortion ?? [1.0, 0.22, 0.24, 0.0];
    for (int x = 0; x < 4; x++) {
      pointer.ref.lensDistortionValues[x] = ld[x];
    }

    final ca = chromaAb ?? [0.996, -0.004, 1.014, 0.0];
    for (int x = 0; x < 4; x++) {
      pointer.ref.chromaAbCorrection[x] = ca[x];
    }

    _finalizer.attach(this, pointer, detach: this);
    _memory = NativeResource<_VrDeviceInfo>(pointer);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_VrDeviceInfo>>((pointer) {
    malloc.free(pointer);
  });

  @override
  void dispose()
  {
    if (_memory != null && !_memory!.isDisposed) {
      _finalizer.detach(this);
      _memory!.dispose();
    }
  }
}

class VrStereoConfig implements Disposeable
{
  NativeResource<_VrStereoConfig>? _memory;
  _VrStereoConfig get ref => _memory!.pointer.ref;

  // --- Matrizes (Usa a classe sombra Matrix para expor os dados) ---
  
  Matrix getProjection(int eyeIndex) {
    if (eyeIndex < 0 || eyeIndex >= 2) throw RangeError(eyeIndex);
    return Matrix._recieve(ref.projection[eyeIndex]);
  }

  Matrix getViewOffset(int eyeIndex) {
    if (eyeIndex < 0 || eyeIndex >= 2) throw RangeError(eyeIndex);
    return Matrix._recieve(ref.viewOffset[eyeIndex]);
  }

  double getLeftLensCenter(int index) => ref.leftLensCenter[index];
  // void setLeftLensCenter(int index, double value) => ref.leftLensCenter[index] = value;

  double getRightLensCenter(int index) => ref.rightLensCenter[index];
  // void setRightLensCenter(int index, double value) => ref.rightLensCenter[index] = value;

  double getLeftScreenCenter(int index) => ref.leftScreenCenter[index];
  // void setLeftScreenCenter(int index, double value) => ref.leftScreenCenter[index] = value;

  double getRightScreenCenter(int index) => ref.rightScreenCenter[index];
  // void setRightScreenCenter(int index, double value) => ref.rightScreenCenter[index] = value;

  double getScale(int index) => ref.scale[index];
  // void setScale(int index, double value) => ref.scale[index] = value;

  double getScaleIn(int index) => ref.scaleIn[index];
  // void setScaleIn(int index, double value) => ref.scaleIn[index] = value;

  VrStereoConfig(VrDeviceInfo device)
  {
    _VrStereoConfig result = _loadVrStereoConfig(device.ref);
    Pointer<_VrStereoConfig> pointer = malloc.allocate<_VrStereoConfig>(sizeOf<_VrStereoConfig>());
    pointer.ref = result;

    _memory = NativeResource<_VrStereoConfig>(pointer);
    _finalizer.attach(this, pointer, detach: this);
  }

  static final Finalizer _finalizer = Finalizer<Pointer<_VrStereoConfig>>((pointer) {
    _unloadVrStereoConfig(pointer.ref);
    malloc.free(pointer);
  });

  void Unload() => dispose(); 

  @override
  void dispose()
  {
    _finalizer.detach(this);
    _unloadVrStereoConfig(_memory!.pointer.ref);
    _memory!.dispose();
  }
} 