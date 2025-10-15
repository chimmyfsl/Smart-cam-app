import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isFlashSupported = false;
  CameraLensDirection _currentDirection = CameraLensDirection.back;
  String? _errorText;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoomOnScaleStart = 1.0;
  Offset? _lastFocusPoint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameras();
  }

  // Initialize available cameras
  Future<void> _initializeCameras() async {
    try {
      // Request camera permission first
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        setState(() {
          _isCameraInitialized = false;
        });
        return;
      }
      
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _errorText = 'No cameras found on this device.';
          _isCameraInitialized = false;
        });
        return;
      }
      await _setCamera(_currentDirection);
    } catch (e) {
      // Handle camera errors
      setState(() {
        _isCameraInitialized = false;
        _errorText = 'Failed to initialize cameras: $e';
      });
    }
  }

  // Set the camera based on direction
  Future<void> _setCamera(CameraLensDirection direction) async {
    setState(() {
      _isCameraInitialized = false;
      _errorText = null;
    });

    final CameraDescription? camera = _findCameraForDirection(direction) ?? (_cameras.isNotEmpty ? _cameras.first : null);
    if (camera == null) {
      setState(() {
        _isCameraInitialized = false;
        _errorText = 'No suitable camera available.';
      });
      return;
    }

    await _disposeController();
    final ResolutionPreset preset = camera.lensDirection == CameraLensDirection.front
        ? ResolutionPreset.medium
        : ResolutionPreset.high;
    _controller = CameraController(
      camera,
      preset,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    try {
      await _controller!.initialize();

      // Determine flash support safely
      _isFlashSupported = false;
      if (camera.lensDirection != CameraLensDirection.front) {
        try {
          await _controller!.setFlashMode(FlashMode.off);
          _isFlashSupported = true;
        } catch (_) {
          _isFlashSupported = false;
        }
      }
      if (!_isFlashSupported) {
        _isFlashOn = false;
      } else if (_isFlashOn) {
        try {
          await _controller!.setFlashMode(FlashMode.torch);
        } catch (_) {
          _isFlashOn = false;
        }
      }

      // Initialize zoom limits
      try {
        _minZoom = await _controller!.getMinZoomLevel();
        _maxZoom = await _controller!.getMaxZoomLevel();
        _currentZoom = _currentZoom.clamp(_minZoom, _maxZoom);
        await _controller!.setZoomLevel(_currentZoom);
      } catch (_) {}

      setState(() {
        _isCameraInitialized = true;
        _currentDirection = camera!.lensDirection;
      });
    } catch (e) {
      setState(() {
        _isCameraInitialized = false;
        _errorText = 'Camera failed to start: $e';
      });
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _baseZoomOnScaleStart = _currentZoom;
  }

  Future<void> _onScaleUpdate(ScaleUpdateDetails details) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final double target = (_baseZoomOnScaleStart * details.scale).clamp(_minZoom, _maxZoom);
    try {
      await _controller!.setZoomLevel(target);
      setState(() {
        _currentZoom = target;
      });
    } catch (_) {}
  }

  Future<void> _onTapToFocus(TapUpDetails details, BuildContext context) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset local = box.globalToLocal(details.globalPosition);
    final Size size = box.size;
    final Offset normalized = Offset(
      (local.dx / size.width).clamp(0.0, 1.0),
      (local.dy / size.height).clamp(0.0, 1.0),
    );
    try {
      await _controller!.setFocusPoint(normalized);
      await _controller!.setExposurePoint(normalized);
      setState(() {
        _lastFocusPoint = local;
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _lastFocusPoint = null;
          });
        }
      });
    } catch (_) {}
  }

  CameraDescription? _findCameraForDirection(CameraLensDirection direction) {
    try {
      return _cameras.firstWhere((c) => c.lensDirection == direction);
    } catch (_) {
      return null;
    }
  }

  Future<void> _disposeController() async {
    final CameraController? oldController = _controller;
    _controller = null;
    if (oldController != null) {
      try {
        await oldController.dispose();
      } catch (_) {}
    }
  }

  // Toggle between front and back camera
  void _toggleCamera() {
    final desired = _currentDirection == CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final CameraDescription? target = _findCameraForDirection(desired) ?? _findAlternateCamera();
    if (target == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No alternate camera available.')),
        );
      }
      return;
    }
    _setCamera(target.lensDirection);
  }

  CameraDescription? _findAlternateCamera() {
    if (_cameras.isEmpty) return null;
    if (_cameras.length == 1) return null;
    try {
      return _cameras.firstWhere((c) => c.lensDirection != _currentDirection);
    } catch (_) {
      return _cameras.length > 1 ? _cameras[1] : null;
    }
  }

  // Toggle flash (only for back camera)
  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_isFlashSupported) return;
    try {
      await _controller!.setFlashMode(_isFlashOn ? FlashMode.off : FlashMode.torch);
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      // Optionally show error
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _disposeController();
    } else if (state == AppLifecycleState.resumed) {
      _setCamera(_currentDirection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Camera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isCameraInitialized && _controller != null && _controller!.value.isInitialized
          ? Stack(
              children: [
                // Fullscreen preview using horizontal scaling to avoid squish
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Size screen = Size(constraints.maxWidth, constraints.maxHeight);
                      final double deviceRatio = screen.width / screen.height;
                      final CameraValue v = _controller!.value;
                      final double previewRatio = v.aspectRatio; // landscape ratio (w/h)

                      Widget preview = CameraPreview(_controller!);
                      if (_currentDirection == CameraLensDirection.front) {
                        preview = Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: preview,
                        );
                      }

                      final double scaleX = previewRatio / deviceRatio;
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: _onScaleStart,
                        onScaleUpdate: _onScaleUpdate,
                        onTapUp: (d) => _onTapToFocus(d, context),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: screen.width,
                            height: screen.height,
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.diagonal3Values(scaleX, 1.0, 1.0),
                              child: preview,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_lastFocusPoint != null)
                  Positioned(
                    left: _lastFocusPoint!.dx - 18,
                    top: _lastFocusPoint!.dy - 18,  
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          color: _isFlashSupported ? Colors.white : Colors.grey,
                          size: 32,
                        ),
                        onPressed: _isFlashSupported ? _toggleFlash : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.cameraswitch, color: Colors.white, size: 36),
                        onPressed: _toggleCamera,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _errorText ?? 'Initializing camera...',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
} 