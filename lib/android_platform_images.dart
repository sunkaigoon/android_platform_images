//import 'dart:async';
//import 'dart:typed_data';
//
//import 'package:flutter/services.dart';
//
//class AndroidPlatformImages {
//  static const MethodChannel _channel =
//      const MethodChannel('com.sunkai/android_platform_images');
//
////  static Future<String> get platformVersion async {
////    final String version = await _channel.invokeMethod('getPlatformVersion');
////    return version;
////  }
//
//  Future<Uint8List> loadImage(String name) async {
//    try {
//      Uint8List bytes = await _channel.invokeMethod('loadImage', name);
//      return bytes;
//    } catch (e) {
//      print(e);
//      return null;
//    }
//  }
//}

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart'
    show SynchronousFuture, describeIdentity;

class _FutureImageStreamCompleter extends ImageStreamCompleter {
  final InformationCollector informationCollector;

  _FutureImageStreamCompleter(
      {Future<ui.Codec> codec, this.informationCollector})
      : assert(codec != null) {
    codec.then<void>(_onCodecReady, onError: (dynamic error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving a single-frame image stream'),
        exception: error,
        stack: stack,
        informationCollector: informationCollector,
        silent: true,
      );
    });
  }

  Future<void> _onCodecReady(ui.Codec codec) async {
    try {
      ui.FrameInfo nextFrame = await codec.getNextFrame();
      setImage(ImageInfo(image: nextFrame.image));
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: this.informationCollector,
        silent: true,
      );
    }
  }
}

class _FutureMemoryImage extends ImageProvider<_FutureMemoryImage> {
  const _FutureMemoryImage(this._futureBytes)
      : assert(_futureBytes != null);

  final Future<Uint8List> _futureBytes;

  /// See [ImageProvider.obtainKey].
  @override
  Future<_FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FutureMemoryImage>(this);
  }

  /// See [ImageProvider.load].
  @override
  ImageStreamCompleter load(_FutureMemoryImage key, DecoderCallback decode) {
    return _FutureImageStreamCompleter(
      codec: _loadAsync(key, decode)
    );
  }

  Future<ui.Codec> _loadAsync(
      _FutureMemoryImage key, DecoderCallback decode) async {
    assert(key == this);
    return _futureBytes.then((Uint8List bytes) {
      return decode(bytes);
    });
  }

  /// See [ImageProvider.operator==].
  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final _FutureMemoryImage typedOther = other;
    return _futureBytes == typedOther._futureBytes;
  }

  /// See [ImageProvider.hashCode].
  @override
  int get hashCode => hashValues(_futureBytes.hashCode, 1);

  /// See [ImageProvider.toString].
  @override
  String toString() =>
      '$runtimeType(${describeIdentity(_futureBytes)}';
}

/// Class to help loading of Android platform images into Flutter.
///
/// For example, loading an image that is in `drawable`.
class AndroidPlatformImages {
  static const MethodChannel _channel =
  MethodChannel('com.sunkai/android_platform_images');
  static ImageProvider load(String name) {
    Future<Uint8List> loadInfo = _channel.invokeMethod('loadImage', name);
    Completer<Uint8List> bytesCompleter = Completer<Uint8List>();
    loadInfo.then((bytes) {
      bytesCompleter.complete(bytes);
    });
    return _FutureMemoryImage(bytesCompleter.future);
  }

//  static Future<String> resolveURL(String name, [String ext]) {
//    return _channel.invokeMethod<String>('resolveURL', [name, ext]);
//  }
}
