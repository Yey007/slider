import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef EmptyFunction = void Function();
typedef Callback<T> = void Function(T);

class DragStartDetails {
  Offset localPosition;
  PointerDeviceKind deviceKind;

  DragStartDetails({required this.localPosition, required this.deviceKind});
}

class DragUpdateDetails {
  Offset localPosition;
  PointerDeviceKind deviceKind;

  DragUpdateDetails({required this.localPosition, required this.deviceKind});
}

class DragEndDetails {
  Velocity velocity;
  PointerDeviceKind deviceKind;

  DragEndDetails({required this.velocity, required this.deviceKind});
}

class PanZoomStartDetails {
  Offset localPosition;
  PointerDeviceKind deviceKind;

  PanZoomStartDetails({required this.localPosition, required this.deviceKind});
}

class PanZoomUpdateDetails {
  Offset localPosition;
  Offset pan;
  double scale;
  PointerDeviceKind deviceKind;

  PanZoomUpdateDetails(
      {required this.localPosition,
      this.pan = Offset.zero,
      this.scale = 1.0,
      required this.deviceKind});
}

// TODO: add velocity?
class PanZoomEndDetails {
  PointerDeviceKind deviceKind;

  PanZoomEndDetails({required this.deviceKind});
}

class CustomGestureDetector extends StatefulWidget {
  final Widget? child;

  final Callback<DragStartDetails>? onDragStart;
  final Callback<DragUpdateDetails>? onDragUpdate;
  final EmptyFunction? onDragEnd; // TODO: use DragEndDetails

  final Callback<PanZoomStartDetails>? onPanZoomStart;
  final Callback<PanZoomUpdateDetails>? onPanZoomUpdate;
  final Callback<PanZoomEndDetails>? onPanZoomEnd;

  final Duration mouseScrollPanEndDelay;

  final double scaleFactor = 200.0;

  const CustomGestureDetector(
      {super.key,
      this.child,
      this.onDragStart,
      this.onDragUpdate,
      this.onDragEnd,
      this.onPanZoomStart,
      this.onPanZoomUpdate,
      this.onPanZoomEnd,
      this.mouseScrollPanEndDelay = const Duration(milliseconds: 100)});

  @override
  State<CustomGestureDetector> createState() => _CustomGestureDetectorState();
}

class _CustomGestureDetectorState extends State<CustomGestureDetector> {
  int? activePointer;
  RestartableTimer? scrollTimer;
  Offset scrollSum = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerPanZoomStart: _onPointerPanZoomStart,
      onPointerPanZoomUpdate: _onPointerPanZoomUpdate,
      onPointerPanZoomEnd: _onPointerPanZoomEnd,
      onPointerSignal: _onPointerSignal,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: widget.child,
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (event.down) {
      if (activePointer == event.pointer) {
        widget.onDragUpdate?.call(DragUpdateDetails(
          localPosition: event.localPosition,
          deviceKind: event.kind,
        ));
      } else if (activePointer == null) {
        setState(() {
          activePointer = event.pointer;
        });
        widget.onDragStart?.call(DragStartDetails(
          localPosition: event.localPosition,
          deviceKind: event.kind,
        ));
      }
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (activePointer == event.pointer) {
      setState(() {
        activePointer = null;
      });
      widget.onDragEnd?.call();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (activePointer == event.pointer) {
      setState(() {
        activePointer = null;
      });
      widget.onDragEnd?.call();
    }
  }

  void _onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      switch (event.kind) {
        case PointerDeviceKind.mouse:
          _onMouseScroll(event);
          break;
        case PointerDeviceKind.trackpad:
          _onTrackpadScroll(event);
          break;
        default:
      }
    }
  }

  void _onMouseScroll(PointerScrollEvent event) {
    // Stole exp formula from flutter themselves
    _onGenericScroll(event,
        (event, sum) => event..scale = exp(-sum.dy / widget.scaleFactor));
  }

  void _onTrackpadScroll(PointerScrollEvent event) {
    _onGenericScroll(event, (event, sum) => event..pan = sum);
  }

  void _onGenericScroll(PointerScrollEvent event,
      PanZoomUpdateDetails Function(PanZoomUpdateDetails, Offset) attachData) {
    if (activePointer == event.pointer) {
      setState(() {
        scrollSum = scrollSum + event.scrollDelta;
        var data = PanZoomUpdateDetails(
          localPosition: event.localPosition,
          deviceKind: event.kind,
        );
        widget.onPanZoomUpdate?.call(attachData(data, scrollSum));
        scrollTimer?.reset();
      });
    } else if (activePointer == null) {
      setState(() {
        scrollTimer = RestartableTimer(widget.mouseScrollPanEndDelay, () {
          widget.onPanZoomEnd?.call(PanZoomEndDetails(deviceKind: event.kind));
          setState(() {
            activePointer = null;
            scrollSum = Offset.zero;
          });
        });
        activePointer = event.pointer;
      });

      widget.onPanZoomStart?.call(PanZoomStartDetails(
        localPosition: event.localPosition,
        deviceKind: event.kind,
      ));
    }
  }

  void _onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    if (activePointer == null) {
      setState(() {
        activePointer = event.pointer;
      });
      widget.onPanZoomStart?.call(
        PanZoomStartDetails(
          localPosition: event.localPosition,
          deviceKind: event.kind,
        ),
      );
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (activePointer == event.pointer) {
      widget.onPanZoomUpdate?.call(
        PanZoomUpdateDetails(
          localPosition: event.localPosition,
          pan: event.pan,
          scale: event.scale,
          deviceKind: event.kind,
        ),
      );
    }
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (activePointer == event.pointer) {
      setState(() {
        activePointer = null;
      });
      widget.onPanZoomEnd?.call(
        PanZoomEndDetails(
          deviceKind: event.kind,
        ),
      );
    }
  }
}
