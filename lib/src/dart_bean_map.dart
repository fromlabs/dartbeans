// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

class DartBeanMap<K, E> extends MapBase<K, E> implements DartBeanTarget, DependantActivationBubbleTarget, EventTargetDelegator {

	// property names
	static const LENGTH = "_length";

	static const EMPTY = "_empty";

	Stream<FLEvent> get onEventDispatched => _delegateeTarget.onEventDispatched;

	Stream<FLEvent> get onBubbleEventDispatched => _delegateeTarget.onBubbleEventDispatched;

	Stream<PropertyChangedEvent> get onPropertyChanged => _delegateeTarget.onPropertyChanged;

	Stream<PropertyChangedEvent> get onBubblePropertyChanged => _delegateeTarget.onBubblePropertyChanged;

	Stream<PropertyChangedEvent> get onLengthChanged => onPropertyChangedEvents[LENGTH];

	Stream<PropertyChangedEvent> get onEmptyChanged => onPropertyChangedEvents[EMPTY];

	Stream<PropertyChangedEvent> get onBubbleLengthChanged => onBubblePropertyChangedEvents[LENGTH];

	Stream<PropertyChangedEvent> get onBubbleEmptyChanged => onBubblePropertyChangedEvents[EMPTY];

	final Map<K, E> _backingMap;

	bool _bubbleTargetActivationCascading;

	DartBeanProxy _delegateeTarget;

	DartBeanMap({bubbleTargetActivationCascading: false})
			: _backingMap = new Map<K, E>(),
			  _bubbleTargetActivationCascading = bubbleTargetActivationCascading {
		_delegateeTarget = new DartBeanProxy(this);
	}

	EventTargetDelegatee get delegateeTarget => _delegateeTarget;

	ToRouteStreams get onBubbleEvents => _delegateeTarget.onBubbleEvents;

	DiscriminatorStreams<PropertyChangedEvent> get onBubblePropertyChangedEvents => _delegateeTarget.onBubblePropertyChangedEvents;

	ToDiscriminateStreams get onBubbleToDiscriminateEvents => _delegateeTarget.onBubbleToDiscriminateEvents;

	ToRouteStreams get onEvents => _delegateeTarget.onEvents;

	DiscriminatorStreams<PropertyChangedEvent> get onPropertyChangedEvents => _delegateeTarget.onPropertyChangedEvents;

	ToDiscriminateStreams get onToDiscriminateEvents => _delegateeTarget.onToDiscriminateEvents;

	FLEventTarget get target => _delegateeTarget.target;

	void onPreDispatching(FLEvent event) {}

	void onPostDispatched(FLEvent event) {}

	void dispatch(String eventType, [FLEvent event]) {
		if (event == null) {
			event = new FLEvent();
		}

		onPreDispatching(event);

		_delegateeTarget.dispatch(eventType, event);

		onPostDispatched(event);
	}

	void discriminatedDispatch(String eventType, discriminator, DiscriminatedEvent event) {
		if (event == null) {
			event = new DiscriminatedEvent();
		}

		onPreDispatching(event);

		_delegateeTarget.discriminatedDispatch(eventType, discriminator, event);

		onPostDispatched(event);
	}

	void dispatchPropertyChanged(dynamic property, PropertyChangedEvent event) {
		discriminatedDispatch(PropertyChangedEvent.EVENT_TYPE, property, event);
	}

	ListenerBinder bindListener(void onData(event)) => _delegateeTarget.bindListener(onData);

	ActionBinder bindAction(void execute()) => _delegateeTarget.bindAction(execute);

	ActionBinder bindActionAndRun(void execute()) => _delegateeTarget.bindActionAndRun(execute);

	// PropertyCalculationBinder bindCalculatedProperty(String targetProperty, calculate()) => _delegateeTarget.bindCalculatedProperty(targetProperty, calculate);

	// PropertyProxionBinder bindProxiedProperty(source, String sourceProperty, {target, targetProperty}) => _delegateeTarget.bindProxiedProperty(source, sourceProperty, target: target, targetProperty: targetProperty);

	getPropertyValue(String property) => _delegateeTarget.getPropertyValue(property);

	bool setPropertyValue(String property, var value, {bool forceUpdate: false}) => _delegateeTarget.setPropertyValue(property, value, forceUpdate: forceUpdate);

	bool get dependantActivationEnabled => _bubbleTargetActivationCascading;

	void enableDependantActivation() {
		_bubbleTargetActivationCascading = true;
	}

	void disableDependantActivation() {
		_bubbleTargetActivationCascading = false;
	}

	bool isBubbleTargetActivationCascading(K index) => dependantActivationEnabled;

	void addBubbleTargetActivationCascading(K index) {
		throw new UnsupportedError("Dependant activation cascading");
	}

	void removeBubbleTargetActivationCascading(K index) {
		throw new UnsupportedError("Dependant activation cascading");
	}

	bool get bubbleTargetingEnabled => _delegateeTarget.bubbleTargetingEnabled;

	void enableBubbleTargeting() {
		if (!_delegateeTarget.bubbleTargetingEnabled) {
			_delegateeTarget.enableBubbleTargeting();

			_backingMap.forEach((index, bubblingTarget) {
			  if (bubblingTarget is BubblingTarget) {
    				if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(index)) {
    					if (bubblingTarget is DependantActivationBubbleTarget) {
    						bubblingTarget.enableDependantActivation();
    					}

    					bubblingTarget.enableBubbleTargeting();
    				}

    				bubblingTarget.addBubbleTarget(index, this);
			  }
			});
		} else {
			throw new StateError("Bubble targeting already enabled");
		}
	}

	void disableBubbleTargeting() {
		if (_delegateeTarget.bubbleTargetingEnabled) {
			_delegateeTarget.disableBubbleTargeting();

			new List.from(_backingMap.keys).reversed.forEach((index) {
			  var bubblingTarget = _backingMap[index];
			  if (bubblingTarget is BubblingTarget) {
          bubblingTarget.removeBubbleTarget(index, this);

          if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(index)) {
            bubblingTarget.disableBubbleTargeting();

            if (bubblingTarget is DependantActivationBubbleTarget) {
              bubblingTarget.disableDependantActivation();
            }
          }
			  }
			});
		} else {
			throw new StateError("Bubble targeting already disabled");
		}
	}

	void addBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		_delegateeTarget.addBubbleTarget(bubblingId, bubbleTarget);
	}

	void removeBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		_delegateeTarget.removeBubbleTarget(bubblingId, bubbleTarget);
	}

	void addPropertyValue(K index, E value) {
		if (this is PropertyHandlingTarget) {
			(this as PropertyHandlingTarget).onPropertyChangingInternal(index, value, null, true, false);
			(this as PropertyHandlingTarget).onPropertyChangingInternal(LENGTH, length + 1, length, false, false);
			if (length == 0) {
				(this as PropertyHandlingTarget).onPropertyChangingInternal(EMPTY, false, true, false, false);
			}
		}

		_backingMap[index] = value;

		if (this is PropertyHandlingTarget) {
			(this as PropertyHandlingTarget).onPropertyChangedInternal(index, value, null, true, false);
			(this as PropertyHandlingTarget).onPropertyChangedInternal(LENGTH, length, length - 1, false, false);
			if (length == 1) {
				(this as PropertyHandlingTarget).onPropertyChangedInternal(EMPTY, false, true, false, false);
			}
		}

		_delegateeTarget.dispatchPropertyChanged(index, new PropertyChangedEvent.createAdded(value));

		_delegateeTarget.dispatchPropertyChanged(LENGTH, new PropertyChangedEvent(length, length - 1));
		if (length == 1) {
			_delegateeTarget.dispatchPropertyChanged(EMPTY, new PropertyChangedEvent(false, true));
		}

		if (value is BubblingTarget) {
			_addBubblingTarget(index, value as BubblingTarget);
		}
	}

	void updatePropertyValue(K index, E value, {bool forceUpdate: false}) {
		var previous = _backingMap[index];

		if (forceUpdate || value != previous) {
			if (previous is BubblingTarget) {
				_removeBubblingTarget(index, previous);
			}

			if (this is PropertyHandlingTarget) {
				(this as PropertyHandlingTarget).onPropertyChangingInternal(index, value, previous, false, false);
			}

			_backingMap[index] = value;

			if (this is PropertyHandlingTarget) {
				(this as PropertyHandlingTarget).onPropertyChangedInternal(index, value, previous, false, false);
			}

			_delegateeTarget.dispatchPropertyChanged(index, new PropertyChangedEvent(value, previous));

			if (value is BubblingTarget) {
				_addBubblingTarget(index, value as BubblingTarget);
			}
		}
	}

	E removePropertyValue(K index) {
		var old = _backingMap[index];
		if (old is BubblingTarget) {
			_removeBubblingTarget(index, old);
		}

		if (this is PropertyHandlingTarget) {
			(this as PropertyHandlingTarget).onPropertyChangingInternal(index, null, old, false, true);
			(this as PropertyHandlingTarget).onPropertyChangingInternal(LENGTH, length - 1, length, false, false);
			if (length == 1) {
				(this as PropertyHandlingTarget).onPropertyChangingInternal(EMPTY, true, false, false, false);
			}
		}

		var removed = _backingMap.remove(index);

		if (this is PropertyHandlingTarget) {
			(this as PropertyHandlingTarget).onPropertyChangedInternal(index, null, old, false, true);
			(this as PropertyHandlingTarget).onPropertyChangedInternal(LENGTH, length, length + 1, false, false);
			if (length == 0) {
				(this as PropertyHandlingTarget).onPropertyChangedInternal(EMPTY, true, false, false, false);
			}
		}

		_delegateeTarget.dispatchPropertyChanged(index, new PropertyChangedEvent.createRemoved(old));

		_delegateeTarget.dispatchPropertyChanged(LENGTH, new PropertyChangedEvent(length, length + 1));
		if (length == 0) {
			_delegateeTarget.dispatchPropertyChanged(EMPTY, new PropertyChangedEvent(true, false));
		}

		return removed;
	}

	void _addBubblingTarget(K index, BubblingTarget bubblingTarget) {
		if (bubbleTargetingEnabled) {
			if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(index)) {
				if (bubblingTarget is DependantActivationBubbleTarget) {
					(bubblingTarget as DependantActivationBubbleTarget).enableDependantActivation();
				}

				(bubblingTarget as ActivableBubbleTarget).enableBubbleTargeting();
			}

			bubblingTarget.addBubbleTarget(index, this);
		}
	}

	void _removeBubblingTarget(K index, BubblingTarget bubblingTarget) {
		if (bubbleTargetingEnabled) {
			bubblingTarget.removeBubbleTarget(index, this);

			if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(index)) {
				(bubblingTarget as ActivableBubbleTarget).disableBubbleTargeting();

				if (bubblingTarget is DependantActivationBubbleTarget) {
					(bubblingTarget as DependantActivationBubbleTarget).disableDependantActivation();
				}
			}
		}
	}

	/* from Map */

  bool containsValue(Object value) => _backingMap.containsValue(value);

  bool containsKey(Object key) => _backingMap.containsKey(key);

  E operator [](Object key) => _backingMap[key];

  void operator []=(K key, E value) {
    updatePropertyValue(key, value);
  }

  E putIfAbsent(K key, E ifAbsent()) {
    if (!this.containsKey(key)) {
      this[key] = ifAbsent();
    }
    return this[key];
  }

  void addAll(Map<K, E> other) {
    other.forEach((k, e) {
      this[k] = e;
    });
  }

  E remove(Object key) => removePropertyValue(key);

  void clear() {
    var reversed = new List.from(this.keys).reversed;
    reversed.forEach((k) => remove(k));
  }

  void forEach(void f(K key, E value)) {
    _backingMap.forEach(f);
  }

  Iterable<K> get keys => _backingMap.keys;

  Iterable<E> get values => _backingMap.values;

  int get length => _backingMap.length;

  bool get isEmpty => _backingMap.isEmpty;

  bool get isNotEmpty => _backingMap.isNotEmpty;

	void _throwTodoError() {
		throw new UnimplementedError("TODO");
	}
}
