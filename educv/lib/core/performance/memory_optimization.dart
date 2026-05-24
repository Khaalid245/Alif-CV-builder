import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Memory-optimized image cache manager
class MemoryOptimizedImageCache {
  static const int _maxCacheSize = 100; // Maximum number of cached images
  static const int _maxMemoryUsage = 50 * 1024 * 1024; // 50MB max memory usage
  
  static final Map<String, ImageProvider> _cache = {};
  static int _currentMemoryUsage = 0;
  
  static ImageProvider? getCachedImage(String key) {
    return _cache[key];
  }
  
  static void cacheImage(String key, ImageProvider image, int estimatedSize) {
    // Remove old images if cache is full
    if (_cache.length >= _maxCacheSize || 
        _currentMemoryUsage + estimatedSize > _maxMemoryUsage) {
      _evictOldestImages();
    }
    
    _cache[key] = image;
    _currentMemoryUsage += estimatedSize;
  }
  
  static void _evictOldestImages() {
    // Remove 25% of cached images (FIFO)
    final keysToRemove = _cache.keys.take(_cache.length ~/ 4).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    // Estimate memory reduction (rough calculation)
    _currentMemoryUsage = (_currentMemoryUsage * 0.75).round();
  }
  
  static void clearCache() {
    _cache.clear();
    _currentMemoryUsage = 0;
  }
}

// Performance-optimized widget that manages its own lifecycle
class LifecycleAwareWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onInit;
  final VoidCallback? onDispose;
  final VoidCallback? onResume;
  final VoidCallback? onPause;

  const LifecycleAwareWidget({
    super.key,
    required this.child,
    this.onInit,
    this.onDispose,
    this.onResume,
    this.onPause,
  });

  @override
  State<LifecycleAwareWidget> createState() => _LifecycleAwareWidgetState();
}

class _LifecycleAwareWidgetState extends State<LifecycleAwareWidget>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.onInit?.call();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.onDispose?.call();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.onResume?.call();
        break;
      case AppLifecycleState.paused:
        widget.onPause?.call();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Debounced callback for performance optimization
class DebouncedCallback {
  final Duration delay;
  final VoidCallback callback;
  Timer? _timer;

  DebouncedCallback({
    required this.delay,
    required this.callback,
  });

  void call() {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

// Performance monitoring and optimization utilities
class PerformanceUtils {
  static const Duration _frameThreshold = Duration(milliseconds: 16); // 60fps
  static int _slowFrameCount = 0;
  static int _totalFrameCount = 0;
  
  static void startFrameMonitoring() {
    WidgetsBinding.instance.addTimingsCallback(_onFrameTiming);
  }
  
  static void stopFrameMonitoring() {
    WidgetsBinding.instance.removeTimingsCallback(_onFrameTiming);
  }
  
  static void _onFrameTiming(List<FrameTiming> timings) {
    for (final timing in timings) {
      _totalFrameCount++;
      if (timing.totalSpan > _frameThreshold) {
        _slowFrameCount++;
      }
    }
  }
  
  static double get frameDropPercentage {
    if (_totalFrameCount == 0) return 0.0;
    return (_slowFrameCount / _totalFrameCount) * 100;
  }
  
  static void resetFrameStats() {
    _slowFrameCount = 0;
    _totalFrameCount = 0;
  }
  
  // Memory optimization helpers
  static void optimizeMemory() {
    // Clear image cache if memory usage is high
    MemoryOptimizedImageCache.clearCache();
    
    // Force garbage collection (use sparingly)
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
  
  // Widget rebuild optimization
  static bool shouldRebuild<T>(T oldValue, T newValue) {
    return oldValue != newValue;
  }
}

// Optimized scroll controller with performance enhancements
class OptimizedScrollController extends ScrollController {
  final Duration _debounceDelay;
  Timer? _debounceTimer;
  VoidCallback? _onScrollEnd;
  
  OptimizedScrollController({
    Duration debounceDelay = const Duration(milliseconds: 100),
    VoidCallback? onScrollEnd,
  }) : _debounceDelay = debounceDelay,
       _onScrollEnd = onScrollEnd {
    addListener(_onScroll);
  }
  
  void _onScroll() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      _onScrollEnd?.call();
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Performance-optimized state management
mixin PerformanceOptimizedState<T extends StatefulWidget> on State<T> {
  bool _isMounted = false;
  final List<Timer> _timers = [];
  final List<DebouncedCallback> _debouncedCallbacks = [];
  
  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }
  
  @override
  void dispose() {
    _isMounted = false;
    
    // Clean up timers
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    
    // Clean up debounced callbacks
    for (final callback in _debouncedCallbacks) {
      callback.dispose();
    }
    _debouncedCallbacks.clear();
    
    super.dispose();
  }
  
  // Safe setState that checks if widget is still mounted
  void safeSetState(VoidCallback fn) {
    if (_isMounted && mounted) {
      setState(fn);
    }
  }
  
  // Add timer with automatic cleanup
  Timer addTimer(Duration duration, VoidCallback callback) {
    final timer = Timer(duration, callback);
    _timers.add(timer);
    return timer;
  }
  
  // Add periodic timer with automatic cleanup
  Timer addPeriodicTimer(Duration duration, void Function(Timer) callback) {
    final timer = Timer.periodic(duration, callback);
    _timers.add(timer);
    return timer;
  }
  
  // Add debounced callback with automatic cleanup
  DebouncedCallback addDebouncedCallback(Duration delay, VoidCallback callback) {
    final debouncedCallback = DebouncedCallback(delay: delay, callback: callback);
    _debouncedCallbacks.add(debouncedCallback);
    return debouncedCallback;
  }
}

// Optimized future builder that prevents unnecessary rebuilds
class OptimizedFutureBuilder<T> extends StatefulWidget {
  final Future<T>? future;
  final T? initialData;
  final Widget Function(BuildContext context, AsyncSnapshot<T> snapshot) builder;

  const OptimizedFutureBuilder({
    super.key,
    this.future,
    this.initialData,
    required this.builder,
  });

  @override
  State<OptimizedFutureBuilder<T>> createState() => _OptimizedFutureBuilderState<T>();
}

class _OptimizedFutureBuilderState<T> extends State<OptimizedFutureBuilder<T>> {
  AsyncSnapshot<T> _snapshot = const AsyncSnapshot.nothing();
  Future<T>? _activeFuture;

  @override
  void initState() {
    super.initState();
    _snapshot = widget.initialData == null
        ? const AsyncSnapshot.nothing()
        : AsyncSnapshot.withData(ConnectionState.none, widget.initialData as T);
    _subscribeTo(widget.future);
  }

  @override
  void didUpdateWidget(OptimizedFutureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) {
      _subscribeTo(widget.future);
    }
  }

  void _subscribeTo(Future<T>? future) {
    if (_activeFuture == future) return;
    
    _activeFuture = future;
    if (future == null) {
      _snapshot = widget.initialData == null
          ? const AsyncSnapshot.nothing()
          : AsyncSnapshot.withData(ConnectionState.none, widget.initialData as T);
    } else {
      _snapshot = _snapshot.inState(ConnectionState.waiting);
      future.then<void>((T data) {
        if (_activeFuture == future && mounted) {
          setState(() {
            _snapshot = AsyncSnapshot.withData(ConnectionState.done, data);
          });
        }
      }, onError: (Object error, StackTrace stackTrace) {
        if (_activeFuture == future && mounted) {
          setState(() {
            _snapshot = AsyncSnapshot.withError(ConnectionState.done, error, stackTrace);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _snapshot);
  }
}

// Timer import for DebouncedCallback