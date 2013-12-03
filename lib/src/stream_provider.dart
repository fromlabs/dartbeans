// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

class ToRouteStreams {

  final bool _bubbled;

  ToRouteEventStreamProvider _provider;

  ToRouteStreams._notBubbled() : this._bubbled = false;

  ToRouteStreams._alsoBubbled() : this._bubbled = true;

  /**
   *  Returns the stream for the given [eventType] or
   *  null if [eventType] is not managed.
   */
  Stream operator [](String eventType) =>
      _bubbled ? _provider[eventType].bubbleStream :
        _provider[eventType].stream;
}

class ToDiscriminateStreams<T extends DiscriminatedEvent> {

  final bool _bubbled;

  ToRouteEventStreamProvider _provider;

  ToDiscriminateStreams._notBubbled() : this._bubbled = false;

  ToDiscriminateStreams._alsoBubbled() : this._bubbled = true;

  /**
   *  Returns the stream map for the given [discriminatedEventType] or
   *  null if [discriminatedEventType] is not managed.
   */
  DiscriminatorStreams<T> operator [](String discriminatedEventType) =>
      this._bubbled ? (_provider[discriminatedEventType] as
            ToDiscriminateEventStreamProvider)
              .onBubbleDiscriminatorEvents :
          (_provider[discriminatedEventType] as
            ToDiscriminateEventStreamProvider)
              .onDiscriminatorEvents;
}

class DiscriminatorStreams<T extends DiscriminatedEvent> {

  final bool _bubbled;

  ToDiscriminateEventStreamProvider _provider;

  DiscriminatorStreams._notBubbled() : this._bubbled = false;

  DiscriminatorStreams._alsoBubbled() : this._bubbled = true;

  /// Returns the stream for all the managed discriminators.
  Stream<T> get stream =>
      _bubbled ? _provider.bubbleStream : _provider.stream;

  /**
   *  Returns the stream for the given [discriminator] or
   *  null if [discriminator] is not managed.
   */
  Stream<T> operator [](String discriminator) =>
      _bubbled ? _provider[discriminator].bubbleStream :
        _provider[discriminator].stream;
}

class BubbleProviderReference<T extends FLEvent> {
	final bubblingId;

	final StreamProvider<T> bubbleProvider;

	BubbleProviderReference(this.bubblingId, this.bubbleProvider);

	bool operator ==(other) {
		return bubblingId == other.bubblingId
			&& identical(bubbleProvider, other.bubbleProvider);
	}

	int get hashCode {
		return bubblingId.hashCode + bubbleProvider.hashCode;
	}
}

class BubbleTargetReference<T extends FLEvent> {
	final bubblingId;

	final FLEventTarget bubbleTarget;

	BubbleTargetReference(this.bubblingId, this.bubbleTarget);

	bool operator ==(other) {
		return bubblingId == other.bubblingId
			&& identical(bubbleTarget, other.bubbleTarget);
	}

	int get hashCode {
		return bubblingId.hashCode + bubbleTarget.hashCode;
	}
}

abstract class StreamProvider<T extends FLEvent> {

  final StreamController<T> _controller =
      new StreamController.broadcast(sync: true);

  final StreamProvider _hostProvider;

  FLEventTarget _target;

	List<BubbleProviderReference<T>> _bubbleProviders;

  StreamProvider([FLEventTarget target]) :
    this._target = target, this._hostProvider = null;

  StreamProvider._forHostProvider(this._hostProvider);

  FLEventTarget get target => _hostProvider != null ?
      _hostProvider.target : _target;

  void set target(FLEventTarget target) {
    if (_hostProvider != null) {
      throw new UnsupportedError("Setting target " +
          "on hosted provider not allowed");
    } else if (_target == null) {
      _target = target;
    } else if (target == null) {
      throw new ArgumentError("Target can't be null");
    } else if (!identical(target, _target)) {
      throw new StateError("Target already set");
    }
  }

  StreamProvider<T> forTarget(FLEventTarget target) {
    this.target = target;
    return this;
  }

  void addBubbleTargetProvider(dynamic bubblingId, StreamProvider<T> bubbleProvider) {
    var reference = new BubbleProviderReference(bubblingId, bubbleProvider);
		if (_hostProvider != null) {
      throw new UnsupportedError("Adding bubble target provider to hosted" +
          " provider not allowed");
    } else if (_bubbleProviders == null) {
	    _bubbleProviders = [reference];
		} else if (!_bubbleProviders.contains(reference)) {
				_bubbleProviders.add(reference);
		} else {
			throw new StateError("Bubble target provider was already added");
		}
  }

  void removeBubbleTargetProvider(dynamic bubblingId, StreamProvider<T> bubbleProvider) {
		var reference = new BubbleProviderReference(bubblingId, bubbleProvider);
		if (_hostProvider != null) {
      throw new UnsupportedError("Removing bubble target provider from hosted" +
          " provider not allowed");
    } else if (_bubbleProviders != null && _bubbleProviders.contains(reference)) {
			_bubbleProviders.remove(reference);
			if (_bubbleProviders.isEmpty) {
				_bubbleProviders = null;
			}
    } else {
      throw new StateError("Bubble target provider to remove is not present");
    }
  }

  Stream<T> get bubbleStream {
    _checkTarget();

    return _controller.stream;
  }

  Stream<T> get stream => bubbleStream.where((event) => !event.bubbled);

  void _dispatchEvent(FLEvent event, StreamProvider<T> _targetProvider) {
    _controller.add(event);

    // dispatch to host provider if defined
    if (_hostProvider != null) {
      _hostProvider._dispatchEvent(event, _targetProvider);
    } else {
      _dispatchBubbleEvent(event, _targetProvider);
    }
  }

  void _dispatchBubbleEvent(FLEvent event,
      StreamProvider<T> _targetProvider) {
    // TODO check if bubbling is enabled here!
    if (_bubbleProviders != null) {
      _bubbleProviders.forEach((BubbleProviderReference reference) {
				var targetReference = new BubbleTargetReference(reference.bubblingId, reference.bubbleProvider.target);
				if (!event._contains(targetReference)) {
	        var targetBubbleProvider =
	            _targetProvider._getBubbleProvider(reference.bubbleProvider);

	        FLEvent clonedEvent = event.clone();
	        if (clonedEvent.runtimeType != event.runtimeType) {
	          throw new UnimplementedError("Implement clone method " +
	              "${event.runtimeType}.clone()");
	        }

					clonedEvent._target = event._target;
					clonedEvent._bubbleReferences = new List.from(event._bubbleReferences);

					clonedEvent._bubbleReferences.add(targetReference);

	        (targetBubbleProvider as FLEventStreamProvider).dispatch(clonedEvent);
				}
      });
    }
  }

  void _complete(FLEvent event) {
    if (event._bubbleReferences == null) {
			event._target = this.target;
			event._bubbleReferences = [];
    }
  }

  StreamProvider<T> _getBubbleProvider(StreamProvider<T> provider);

  void _checkTarget() {
    if (target == null) {
      throw new StateError("Target not set");
    }
  }
}

class ToRouteEventStreamProvider extends StreamProvider {
  final Map<String, FLEventStreamProvider> _providers = {};

  final ToRouteStreams onBubbleEvents = new ToRouteStreams._alsoBubbled();

  final ToRouteStreams onEvents = new ToRouteStreams._notBubbled();

  final ToDiscriminateStreams onBubbleToDiscriminateEvents =
      new ToDiscriminateStreams._alsoBubbled();

  final ToDiscriminateStreams onToDiscriminateEvents =
      new ToDiscriminateStreams._notBubbled();

  ToRouteEventStreamProvider([FLEventTarget target]) : super(target) {
    onBubbleEvents._provider = this;
    onEvents._provider = this;
    onBubbleToDiscriminateEvents._provider = this;
    onToDiscriminateEvents._provider = this;
  }

  FLEventStreamProvider operator [](String key) {
    int indexOf = key.indexOf(DiscriminatedEvent.DISCRIMINATOR_POSTFIX);
    if (indexOf != -1) {
      String eventType = key.substring(0, indexOf + 1);
      String discriminator = key.substring(indexOf + 1);
      ToDiscriminateEventStreamProvider provider =
          _providers.putIfAbsent(eventType, () =>
              new ToDiscriminateEventStreamProvider
                ._forHostProvider(eventType, this));
      return discriminator.isEmpty ? provider : provider[discriminator];
    } else {
      return _providers.putIfAbsent(key, () =>
          new FLEventStreamProvider._forHostProvider(key, this));
    }
  }

  StreamProvider _getBubbleProvider(StreamProvider provider) =>
      provider;
}

class FLEventStreamProvider<T extends FLEvent>
    extends StreamProvider<T> {
  final String _eventType;

  FLEventStreamProvider(this._eventType,
      [FLEventTarget target]) : super(target);

  FLEventStreamProvider._forHostProvider(this._eventType,
      StreamProvider hostProvider) :
        super._forHostProvider(hostProvider);

  FLEventTarget get target =>
      _hostProvider != null ? _hostProvider.target : _target;

  void set target(FLEventTarget target) {
    if (_hostProvider != null) {
      throw new UnsupportedError("Setting target " +
          "on hosted provider not allowed");
    } else if (_target == null) {
      _target = target;
    } else if (target == null) {
      throw new ArgumentError("Target can't be null");
    } else if (!identical(target, _target)) {
      throw new StateError("Target already set");
    }
  }

  void dispatch(T event) {
/*
    if (target != null &&
		    (target is! ActivableTarget || (target as ActivableTarget).dispatchingActive)) {
*/
    if (target != null) {
			_complete(event);

			_dispatchEvent(event, this);
		}
  }

  StreamProvider _getBubbleProvider(StreamProvider provider) {
    if (_hostProvider != null) {
      return (_hostProvider._getBubbleProvider(provider) as
          ToRouteEventStreamProvider)[_eventType];
    } else {
      return provider;
    }
  }

  void _complete(FLEvent event) {
    super._complete(event);

    event._type = this._eventType;
  }
}

class ToDiscriminateEventStreamProvider<T extends DiscriminatedEvent>
    extends FLEventStreamProvider<T> {

  final Map<String, DiscriminatedEventStreamProvider<T>> _providers = {};

  final DiscriminatorStreams<T> onBubbleDiscriminatorEvents =
      new DiscriminatorStreams._alsoBubbled();

  final DiscriminatorStreams<T> onDiscriminatorEvents =
      new DiscriminatorStreams._notBubbled();

  ToDiscriminateEventStreamProvider(String eventType,
      [FLEventTarget target]) : super(eventType, target) {

    onBubbleDiscriminatorEvents._provider = this;
    onDiscriminatorEvents._provider = this;

    if (!eventType.endsWith(DiscriminatedEvent.DISCRIMINATOR_POSTFIX)) {
      throw new ArgumentError("Discriminated event type '" +
          eventType + "' must end with '" +
          DiscriminatedEvent.DISCRIMINATOR_POSTFIX +
          "' postfix like '" +
          (eventType + DiscriminatedEvent.DISCRIMINATOR_POSTFIX) + "'");
    }
  }

  ToDiscriminateEventStreamProvider._forHostProvider(String eventType,
      ToRouteEventStreamProvider hostProvider) :
        super._forHostProvider(eventType, hostProvider) {

    onBubbleDiscriminatorEvents._provider = this;
    onDiscriminatorEvents._provider = this;
  }

  DiscriminatedEventStreamProvider<T>
    operator [](dynamic discriminator) =>
      _providers.putIfAbsent(discriminator, () =>
          new DiscriminatedEventStreamProvider
            ._forHostProvider(_eventType, discriminator, this));

  void dispatch(T event) {
    throw new UnsupportedError("Dispatch event from " +
      "host provider not allowed");
  }
}

class DiscriminatedEventStreamProvider<T extends DiscriminatedEvent>
    extends FLEventStreamProvider<T> {

  final dynamic _discriminator;

  DiscriminatedEventStreamProvider(String eventType, this._discriminator,
      [FLEventTarget target]) : super(eventType, target) {

    if (!eventType.endsWith(DiscriminatedEvent.DISCRIMINATOR_POSTFIX)) {
      throw new ArgumentError("Discriminated event type '" +
          eventType + "' must end with '" +
          DiscriminatedEvent.DISCRIMINATOR_POSTFIX +
          "' postfix like '" +
          (eventType + DiscriminatedEvent.DISCRIMINATOR_POSTFIX) + "'");
    }
  }

  DiscriminatedEventStreamProvider._forHostProvider(String eventType,
      this._discriminator,
        ToDiscriminateEventStreamProvider<T> hostProvider) :
          super._forHostProvider(eventType, hostProvider);

  StreamProvider _getBubbleProvider(StreamProvider provider) {
    if (_hostProvider != null) {
      return (_hostProvider._getBubbleProvider(provider) as
          ToDiscriminateEventStreamProvider<T>)[_discriminator];
    } else {
      return provider;
    }
  }

  void _complete(DiscriminatedEvent event) {
    super._complete(event);

    event._discriminator = this._discriminator;
  }
}