// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

/// Interface used by types that are targets for event notification.
abstract class FLEventTarget {}

/// Interface used by types that bubble events to parent targets.
abstract class BubblingTarget implements FLEventTarget {
	void addBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget);
	void removeBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget);
}

/// Interface used by types that proxy targets for event notification.
abstract class EventTargetProxy implements FLEventTarget {
  /// The proxied target.
  FLEventTarget get target;
}

abstract class EventTargetDelegator implements FLEventTarget {
	FLEventTarget get delegate;
}

class ProxyBaseTarget extends BaseTarget
    implements EventTargetProxy {

  FLEventTarget _target;

  ProxyBaseTarget([FLEventTarget target]) {
    this._target = target != null ? target : this;
  }

  FLEventTarget get target => _target;
}

abstract class BaseTarget implements BubblingTarget {
  final ToRouteEventStreamProvider _eventProvider =
      new ToRouteEventStreamProvider();

  Stream<FLEvent> get onEventDispatched => _eventProvider.stream;

  Stream<FLEvent> get onBubbleEventDispatched =>
      _eventProvider.bubbleStream;

  ToRouteStreams get onEvents => _eventProvider.onEvents;

  ToRouteStreams get onBubbleEvents => _eventProvider.onBubbleEvents;

  ToDiscriminateStreams get onToDiscriminateEvents =>
      _eventProvider.onToDiscriminateEvents;

  ToDiscriminateStreams get onBubbleToDiscriminateEvents =>
      _eventProvider.onBubbleToDiscriminateEvents;

  BaseTarget() {
    _eventProvider.target = this;
  }

  FLEventTarget get target => this;

  void notifyEvent(String eventType, [FLEvent event]) {
    _eventProvider[eventType].notify(event);
  }

  void addBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		if (bubbleTarget is BaseTarget) {
			_eventProvider.addBubbleProvider(bubblingId, (bubbleTarget as BaseTarget)._eventProvider);
		} else if (bubbleTarget is EventTargetDelegator) {
			addBubbleTarget(bubblingId, (bubbleTarget as EventTargetDelegator).delegate);
		} else {
			throw new ArgumentError("Event target ${bubbleTarget.runtimeType} not supported for bubbling!");
		}
  }

  void removeBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		if (bubbleTarget is BaseTarget) {
			_eventProvider.removeBubbleProvider(bubblingId, (bubbleTarget as BaseTarget)._eventProvider);
		} else if (bubbleTarget is EventTargetDelegator) {
			removeBubbleTarget(bubblingId, (bubbleTarget as EventTargetDelegator).delegate);
		} else {
			throw new ArgumentError("Event target ${bubbleTarget.runtimeType} not supported for bubbling!");
		}
  }

  ListenerBinder bindListener(void onData(event)) =>
      new ListenerBinder(onData);

  ActionBinder bindAction(ActionExecution execute) =>
      new ActionBinder(execute);

  ActionBinder bindActionAndRun(ActionExecution execute) =>
      new ActionBinder.runImmediately(execute);
}