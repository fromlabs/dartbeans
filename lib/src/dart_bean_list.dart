// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

class DartBeanList<E extends DartBean> extends ListBase<E>
    implements DartBeanTarget, DependantActivationBubbleTarget, EventTargetDelegator {

  // property names
  static const LENGTH = "_length";

  static const EMPTY = "_empty";

	Stream<FLEvent> get onEventDispatched => _delegateeTarget.onEventDispatched;

  Stream<FLEvent> get onBubbleEventDispatched => _delegateeTarget.onBubbleEventDispatched;

  Stream<PropertyChangedEvent> get onPropertyChanged => _delegateeTarget.onPropertyChanged;

  Stream<PropertyChangedEvent> get onBubblePropertyChanged => _delegateeTarget.onBubblePropertyChanged;

  Stream<PropertyChangedEvent> get onLengthChanged =>
      onPropertyChangedEvents[LENGTH];

  Stream<PropertyChangedEvent> get onEmptyChanged =>
      onPropertyChangedEvents[EMPTY];

  Stream<PropertyChangedEvent> get onBubbleLengthChanged =>
      onBubblePropertyChangedEvents[LENGTH];

  Stream<PropertyChangedEvent> get onBubbleEmptyChanged =>
      onBubblePropertyChangedEvents[EMPTY];

  final List<E> _backingList;

  bool _bubbleTargetActivationCascading;

  DartBeanProxy _delegateeTarget;

  DartBeanList({bubbleTargetActivationCascading: false}) : _backingList = new List<E>(), _bubbleTargetActivationCascading = bubbleTargetActivationCascading {
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

  void dispatchPropertyChanged(dynamic property,
      PropertyChangedEvent event) {
    discriminatedDispatch(PropertyChangedEvent.EVENT_TYPE, property, event);
  }

  ListenerBinder bindListener(void onData(event)) =>
      _delegateeTarget.bindListener(onData);

  ActionBinder bindAction(void execute()) =>
      _delegateeTarget.bindAction(execute);

  ActionBinder bindActionAndRun(void execute()) =>
      _delegateeTarget.bindActionAndRun(execute);

  PropertyCalculationBinder bindCalculatedProperty(String targetProperty, calculate()) =>
      _delegateeTarget.bindCalculatedProperty(targetProperty, calculate);

  PropertyProxionBinder bindProxiedProperty(source, String sourceProperty, {target, targetProperty}) =>
      _delegateeTarget.bindProxiedProperty(source, sourceProperty, target: target, targetProperty: targetProperty);

  getPropertyValue(String property) =>
      _delegateeTarget.getPropertyValue(property);

  bool setPropertyValue(String property, var value, {bool forceUpdate: false}) =>
      _delegateeTarget.setPropertyValue(property, value, forceUpdate: forceUpdate);

  bool get dependantActivationEnabled => _bubbleTargetActivationCascading;

  void enableDependantActivation() {
    _bubbleTargetActivationCascading = true;
  }

  void disableDependantActivation() {
    _bubbleTargetActivationCascading = false;
  }

  bool isBubbleTargetActivationCascading(index) =>
      dependantActivationEnabled;

  void addBubbleTargetActivationCascading(index) {
    throw new UnsupportedError("Dependant activation cascading");
  }

  void removeBubbleTargetActivationCascading(index) {
    throw new UnsupportedError("Dependant activation cascading");
  }

  bool get bubbleTargetingEnabled => _delegateeTarget.bubbleTargetingEnabled;

  void enableBubbleTargeting() {
    if (!_delegateeTarget.bubbleTargetingEnabled) {
      _delegateeTarget.enableBubbleTargeting();

      int index = 0;
      _backingList.forEach((bubblingTarget) {
        if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(index)) {
          if (bubblingTarget is DependantActivationBubbleTarget) {
            bubblingTarget.enableDependantActivation();
          }

          bubblingTarget.enableBubbleTargeting();
        }

        bubblingTarget.addBubbleTarget(index++, this);
      });
    } else {
      throw new StateError("Bubble targeting already enabled");
    }
  }

  void disableBubbleTargeting() {
    if (_delegateeTarget.bubbleTargetingEnabled) {
      _delegateeTarget.disableBubbleTargeting();

      int index = _backingList.length;
      _backingList.reversed.forEach((bubblingTarget) {
        bubblingTarget.removeBubbleTarget(--index, this);

        if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(index)) {
          bubblingTarget.disableBubbleTargeting();

          if (bubblingTarget is DependantActivationBubbleTarget) {
            bubblingTarget.disableDependantActivation();
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

	void addPropertyValue(int index, E value, {bool adjustBubblingIds: true}) {
    if (this is PropertyHandlingTarget) {
      (this as PropertyHandlingTarget).onPropertyChangingInternal(index, value, null, true, false);
      (this as PropertyHandlingTarget).onPropertyChangingInternal(LENGTH, length + 1, length, false, false);
      if (length == 0) {
        (this as PropertyHandlingTarget).onPropertyChangingInternal(EMPTY, false, true, false, false);
      }
    }

		_backingList.insert(index, value);

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
      _addBubblingTarget(index, value);

      if (adjustBubblingIds) {
        _adjustBubblingIds(index, 1);
      }
    }
	}

	void updatePropertyValue(int index, E value, {bool forceUpdate: false}) {
		var previous = _backingList[index];

		if(forceUpdate || value != previous) {
      if (previous is BubblingTarget) {
        _removeBubblingTarget(index, previous);
      }

      if (this is PropertyHandlingTarget) {
        (this as PropertyHandlingTarget).onPropertyChangingInternal(index, value, previous, false, false);
      }

      _backingList[index] = value;

      if (this is PropertyHandlingTarget) {
        (this as PropertyHandlingTarget).onPropertyChangedInternal(index, value, previous, false, false);
      }

	    _delegateeTarget.dispatchPropertyChanged(index, new PropertyChangedEvent(value, previous));

      if (value is BubblingTarget) {
        _addBubblingTarget(index, value);
      }
		}
	}

	E removePropertyValue(int index, {bool adjustBubblingIds: true}) {
	  var old = _backingList[index];
	  if (old is BubblingTarget) {
      _removeBubblingTarget(index, old);

      // adjust next bubblingIds
      if (adjustBubblingIds) {
        _adjustBubblingIds(index, -1);
      }
    }

	  if (this is PropertyHandlingTarget) {
      (this as PropertyHandlingTarget).onPropertyChangingInternal(index, null, old, false, true);
      (this as PropertyHandlingTarget).onPropertyChangingInternal(LENGTH, length - 1, length, false, false);
      if (length == 1) {
        (this as PropertyHandlingTarget).onPropertyChangingInternal(EMPTY, true, false, false, false);
      }
    }

		var removed = _backingList.removeAt(index);

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

  void _addBubblingTarget(int index, BubblingTarget bubblingTarget) {
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

  void _removeBubblingTarget(int index, BubblingTarget bubblingTarget) {
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

  int get length => _backingList.length;

  E operator [](int index) =>
      _backingList[index];

  /* from List */

  void add(E element) {
    addPropertyValue(this.length, element);
  }

  void addAll(Iterable<E> iterable) {
    iterable.forEach((e) {
			addPropertyValue(this.length, e);
    });
  }

  void insert(int index, E element) {
		addPropertyValue(index, element);
  }

  void insertAll(int index, Iterable<E> iterable) {
    iterable.forEach((e) {
			addPropertyValue(index++, e);
    });
  }

  void operator []=(int index, E value) {
    updatePropertyValue(index, value);
  }

  void setAll(int index, Iterable<E> iterable) {
    iterable.forEach((e) {
      this[index++] = e;
    });
  }

  void set length(int newLength) {
    if (newLength < _backingList.length) {
      // remove
      removeRange(newLength, _backingList.length);
    } else if (newLength > _backingList.length) {
      // add
      for(var i = _backingList.length; i < newLength; i++) {
        add(null);
      }
    }
  }

  bool remove(Object value) {
    var i = indexOf(value);

    if (i != -1) {
      this.removeAt(i);
    }

    return i != -1;
  }

  E removeAt(int index) {
    return removePropertyValue(index);
  }

  E removeLast() {
    return removeAt(length - 1);
  }

  void removeRange(int start, int end) {
    for(var i = end; i >= start; i--) {
			removePropertyValue(i);
    }
  }

  void clear() {
    while(!isEmpty) {
			removePropertyValue(length - 1);
    }
  }

  void removeWhere(bool test(E element)) {
    _throwTodoError();
  }

  void retainWhere(bool test(E element)) {
    _throwTodoError();
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _throwTodoError();
  }

  void fillRange(int start, int end, [E fillValue]) {
    _throwTodoError();
  }

  void replaceRange(int start, int end, Iterable<E> iterable) {
    _throwTodoError();
  }

	void _adjustBubblingIds(int fromIndex, int delta) {
	  if (bubbleTargetingEnabled) {
	    var i = fromIndex;
	    if (delta > 0) {
	      _backingList.sublist(fromIndex + delta).forEach((nextElement) {
	        if (nextElement is BubblingTarget) {
	          nextElement.removeBubbleTarget(i , this);
	          nextElement.addBubbleTarget(i + delta, this);
	        }

	        i++;
	      });
	    } else {
	      _backingList.sublist(fromIndex - delta).forEach((nextElement) {
	        if (nextElement is BubblingTarget) {
	          nextElement.removeBubbleTarget(i - delta, this);
	          nextElement.addBubbleTarget(i, this);
	        }

	        i++;
	      });
	    }
	  }
	}

	void _throwTodoError() {
    throw new UnimplementedError("TODO");
  }
}