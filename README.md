# smart_cam_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Deep learning model integration (TensorFlow Lite)

Place your model file under `assets/models/` and ensure it is listed in `pubspec.yaml` under `flutter.assets`.

Example expected layout:

```
assets/
  models/
    model.tflite
```

Install dependencies (already added in pubspec): `tflite_flutter`, `tflite_flutter_helper`.

### Preprocessing expectations
- The app does not enforce a specific input shape. After loading, check `InferenceService.inputShape` to see `[batch, height, width, channels]`.
- Convert camera frames (YUV) to RGB, resize to the model's height/width, and normalize according to your model training (e.g., float32 in [0,1] or [-1,1]).
- If your model expects `uint8`, feed integer pixel values 0–255 using `inferUint8`. For float models, use `inferFloat32` with normalized floats.

### Using the service
```dart
final svc = InferenceService();
await svc.load(assetPath: 'assets/models/model.tflite');
// Prepare a tensor matching svc.inputShape, e.g. [1,H,W,3] floats
final prob = svc.inferFloat32(inputBatch);
```

### Next steps
- Wire `CameraController.startImageStream` to produce frames, throttle to ~5–10 fps, preprocess, call `InferenceService`, and log detections via `DetectionRepository`.
- Tune thresholding to convert probability to `isStroke` and `confidencePercent`.