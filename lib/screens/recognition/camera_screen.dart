import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter_tts/flutter_tts.dart'; // 🚀 Importar Text-to-Speech

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String _detectedObject = 'Ningún objeto detectado aún';

  final ObjectDetector _objectDetector = ObjectDetector(
    options: ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.single,
    ),
  );

  final FlutterTts _flutterTts = FlutterTts(); // 🚀 Instanciar TTS

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _configureTTS(); // 🚀 Configurar TTS al iniciar
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.medium);
      await _controller?.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  Future<void> _configureTTS() async {
    await _flutterTts.setLanguage('es-MX'); // 🇲🇽 Español México
    await _flutterTts.setSpeechRate(0.5); // Velocidad de voz
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _captureAndDetect() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    try {
      final XFile picture = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(picture.path);

      final List<DetectedObject> objects = await _objectDetector.processImage(
        inputImage,
      );

      if (objects.isNotEmpty) {
        Map<String, int> labelCounts = {};

        for (DetectedObject object in objects) {
          for (Label label in object.labels) {
            String translatedLabel = _translateLabel(label.text);
            labelCounts.update(
              translatedLabel,
              (value) => value + 1,
              ifAbsent: () => 1,
            );
          }
        }

        if (labelCounts.isNotEmpty) {
          List<String> descriptions = [];

          labelCounts.forEach((label, count) {
            if (count == 1) {
              descriptions.add('una $label'.toLowerCase());
            } else {
              descriptions.add(
                '$count ${_pluralizeLabel(label)}'.toLowerCase(),
              );
            }
          });

          setState(() {
            _detectedObject = 'Detectado: ${descriptions.join(", ")}';
          });
          _speak('He detectado: ${descriptions.join(", ")}');
        } else {
          setState(() {
            _detectedObject = 'Objetos detectados pero sin etiquetas.';
          });
          _speak('Detecté objetos pero no sé qué son.');
        }
      } else {
        setState(() {
          _detectedObject = 'No se detectaron objetos';
        });
        _speak('No se detectaron objetos');
      }
    } catch (e) {
      setState(() {
        _detectedObject = 'Error al detectar: $e';
      });
      _speak('Ocurrió un error al detectar objetos');
    }
  }

  String _translateLabel(String label) {
    switch (label.toLowerCase()) {
      case 'person':
        return 'Persona';
      case 'animal':
        return 'Animal';
      case 'plant':
        return 'Planta';
      case 'food':
        return 'Comida';
      case 'home good':
        return 'Artículo para el hogar';
      case 'fashion good':
        return 'Artículo de moda';
      case 'place':
        return 'Lugar';
      case 'vehicle':
        return 'Vehículo';
      default:
        return 'Objeto desconocido';
    }
  }

  String _pluralizeLabel(String label) {
    switch (label.toLowerCase()) {
      case 'persona':
        return 'personas';
      case 'animal':
        return 'animales';
      case 'planta':
        return 'plantas';
      case 'comida':
        return 'comidas';
      case 'artículo para el hogar':
        return 'artículos para el hogar';
      case 'artículo de moda':
        return 'artículos de moda';
      case 'lugar':
        return 'lugares';
      case 'vehículo':
        return 'vehículos';
      default:
        return '${label}s'; // Si no está en la lista, simplemente agrega "s"
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _objectDetector.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reconocimiento Numji')),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child:
                _isCameraInitialized
                    ? CameraPreview(_controller!)
                    : const Center(child: CircularProgressIndicator()),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _detectedObject,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _captureAndDetect,
                    child: const Text('Detectar objeto'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
