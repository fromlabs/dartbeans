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

///
abstract class ActivableBubbleTarget implements FLEventTarget {

  bool get bubbleTargetingEnabled;

  void enableBubbleTargeting();

  void disableBubbleTargeting();

  bool isBubbleTargetActivationCascading(dynamic bubblingId);

  void addBubbleTargetActivationCascading(dynamic bubblingId);

  void removeBubbleTargetActivationCascading(dynamic bubblingId);
}

///
abstract class DependantActivationBubbleTarget implements ActivableBubbleTarget {}

/// Interface used by types that proxy targets for event notification.
abstract class EventTargetDelegatee implements FLEventTarget {
  /// The proxied target.
  EventTargetDelegator get delegatorTarget;
}

abstract class EventTargetDelegator implements FLEventTarget {
  EventTargetDelegatee get delegateeTarget;
}

class EventTargetProxy extends BaseTarget
    implements EventTargetDelegatee, EventTargetDelegator {

  EventTargetDelegator _delegatorTarget;

  EventTargetProxy([this._delegatorTarget]);

  EventTargetDelegator get delegatorTarget => _delegatorTarget != null ? _delegatorTarget : this;

  EventTargetDelegatee get delegateeTarget => _delegatorTarget != null ? null : this;
}

abstract class BaseTarget implements BubblingTarget {

  final ToRouteEventStreamProvider _eventProvider =
      new ToRouteEventStreamProvider();

  ToRouteStreams get onEvents => _eventProvider.onEvents;

  ToRouteStreams get onBubbleEvents => _eventProvider.onBubbleEvents;

  ToDiscriminateStreams get onToDiscriminateEvents =>
      _eventProvider.onToDiscriminateEvents;

  ToDiscriminateStreams get onBubbleToDiscriminateEvents =>
      _eventProvider.onBubbleToDiscriminateEvents;

  Stream<FLEvent> get onEventDispatched => _eventProvider.stream;

  Stream<FLEvent> get onBubbleEventDispatched =>
      _eventProvider.bubbleStream;

  BaseTarget() {
    _eventProvider.target = this;
  }

  FLEventTarget get target => this;

  void onPreDispatching(FLEvent event) {}

  void onPostDispatched(FLEvent event) {}

  void dispatch(String eventType, [FLEvent event]) {
		if (event == null) {
			event = new FLEvent();
		}

		onPreDispatching(event);

    _eventProvider[eventType].dispatch(event);

    onPostDispatched(event);
  }

  void discriminatedDispatch(String eventType, dynamic discriminator, DiscriminatedEvent event) {
		if (event == null) {
			event = new DiscriminatedEvent();
		}

		onPreDispatching(event);

    (_eventProvider[eventType] as ToDiscriminateEventStreamProvider)[discriminator].dispatch(event);

    onPostDispatched(event);
  }

  void addBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		if (bubbleTarget is BaseTarget) {
			_eventProvider.addBubbleTargetProvider(bubblingId, bubbleTarget._eventProvider);
		} else if (bubbleTarget is EventTargetDelegator && bubbleTarget.delegateeTarget != null) {
			addBubbleTarget(bubblingId, bubbleTarget.delegateeTarget);
		} else {
			throw new ArgumentError("Event target ${bubbleTarget.runtimeType} not supported for bubbling!");
		}
  }

  void removeBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		if (bubbleTarget is BaseTarget) {
			_eventProvider.removeBubbleTargetProvider(bubblingId, bubbleTarget._eventProvider);
		} else if (bubbleTarget is EventTargetDelegator) {
			removeBubbleTarget(bubblingId, bubbleTarget.delegateeTarget);
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