import 'dart:math';

import 'package:async/async.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef EmptyFunction = void Function();
typedef Callback<T> = void Function(T);

class CustomGestureRecognizer extends StatefulWidget {
  final Widget? child;

  final Callback<PointerMoveEvent>? onDragStart;
  final Callback<PointerMoveEvent>? onDragUpdate;
  final EmptyFunction? onDragEnd;

  final Callback<PointerPanZoomStartEvent>? onPanZoomStart;
  final Callback<PointerPanZoomUpdateEvent>? onPanZoomUpdate;
  final Callback<PointerPanZoomEndEvent>? onPanZoomEnd;

  final Duration mouseScrollPanEndDelay;

  final double scaleFactor = 200.0;

  const CustomGestureRecognizer(
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
  State<CustomGestureRecognizer> createState() =>
      _CustomGestureRecognizerState();
}

class _CustomGestureRecognizerState extends State<CustomGestureRecognizer> {
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
        widget.onDragUpdate?.call(event);
      } else if (activePointer == null) {
        setState(() {
          activePointer = event.pointer;
        });
        widget.onDragStart?.call(event);
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
    _onGenericScroll(
        event,
        (event, sum) =>
            event.copyWith(scale: exp(-sum.dy / widget.scaleFactor)));
  }

  void _onTrackpadScroll(PointerScrollEvent event) {
    _onGenericScroll(event, (event, sum) => event.copyWith(pan: sum));
  }

  void _onGenericScroll(
      PointerScrollEvent event,
      PointerPanZoomUpdateEvent Function(PointerPanZoomUpdateEvent, Offset)
          attachData) {
    if (activePointer == event.pointer) {
      setState(() {
        scrollSum = scrollSum + event.scrollDelta;
        var data = PointerPanZoomUpdateEvent(
          timeStamp: event.timeStamp,
          device: event.device,
          pointer: event.pointer,
          position: event.position,
          embedderId: event.embedderId,
        );
        widget.onPanZoomUpdate?.call(attachData(data, scrollSum));
        scrollTimer?.reset();
      });
    } else if (activePointer == null) {
      setState(() {
        scrollTimer = RestartableTimer(widget.mouseScrollPanEndDelay, () {
          widget.onPanZoomEnd?.call(PointerPanZoomEndEvent(
            timeStamp: event.timeStamp,
            device: event.device,
            pointer: event.pointer,
            position: event.position,
            embedderId: event.embedderId,
          ));
          setState(() {
            activePointer = null;
            scrollSum = Offset.zero;
          });
        });
        activePointer = event.pointer;
      });

      widget.onPanZoomStart?.call(PointerPanZoomStartEvent(
        timeStamp: event.timeStamp,
        device: event.device,
        pointer: event.pointer,
        position: event.position,
        embedderId: event.embedderId,
      ));
    }
  }

  void _onPointerPanZoomStart(PointerPanZoomStartEvent event) {
    if (activePointer == null) {
      setState(() {
        activePointer = event.pointer;
      });
      widget.onPanZoomStart?.call(event);
    }
  }

  void _onPointerPanZoomUpdate(PointerPanZoomUpdateEvent event) {
    if (activePointer == event.pointer) {
      widget.onPanZoomUpdate?.call(event);
    }
  }

  void _onPointerPanZoomEnd(PointerPanZoomEndEvent event) {
    if (activePointer == event.pointer) {
      setState(() {
        activePointer = null;
      });
      widget.onPanZoomEnd?.call(event);
    }
  }
}
