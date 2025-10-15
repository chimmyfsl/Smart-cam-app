import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';

class InferenceService {
  Interpreter? _interpreter;
  List<int>? _inputShape; // e.g., [1, 224, 224, 3]
  List<int>? _outputShape; // e.g., [1, 1]

  Future<void> load({String assetPath = 'assets/models/model.tflite', int threads = 2}) async {
    if (_interpreter != null) return;
    final options = InterpreterOptions()..threads = threads;
    final interpreter = await Interpreter.fromAsset(assetPath, options: options);
    _interpreter = interpreter;
    _inputShape = interpreter.getInputTensor(0).shape;
    _outputShape = interpreter.getOutputTensor(0).shape;
  }

  bool get isReady => _interpreter != null;

  List<int>? get inputShape => _inputShape;
  List<int>? get outputShape => _outputShape;

  // Expects preprocessed input matching the model's input shape and type.
  // For a binary classifier, returns a probability in [0,1].
  double inferFloat32(List<List<List<List<double>>>> inputBatch) {
    if (_interpreter == null) return 0.0;
    final output = List.filled(1, 0.0).reshape([1, 1]);
    _interpreter!.run(inputBatch, output);
    final val = output[0][0];
    return val is double ? val.clamp(0.0, 1.0) : 0.0;
  }

  // Alternate variant for models expecting uint8 input
  double inferUint8(List<List<List<List<int>>>> inputBatch) {
    if (_interpreter == null) return 0.0;
    final output = List.filled(1, 0).reshape([1, 1]);
    _interpreter!.run(inputBatch, output);
    final num val = output[0][0];
    final double f = val.toDouble();
    if (f.isNaN) return 0.0;
    return f.clamp(0.0, 1.0);
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _inputShape = null;
    _outputShape = null;
  }
}


