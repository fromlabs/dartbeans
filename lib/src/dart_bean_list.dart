// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

class DartBeanList<E extends DartBean> extends ListBase<E>
    implements BubblingTarget, ActivableBubbleTarget, EventTargetDelegator, List<E> {

	Stream<FLEvent> get onEventDispatched => _delegateeTarget.onEventDispatched;

  Stream<FLEvent> get onBubbleEventDispatched => _delegateeTarget.onBubbleEventDispatched;

  Stream<PropertyChangedEvent> get onPropertyChanged => _delegateeTarget.onPropertyChanged;

  Stream<PropertyChangedEvent> get onBubblePropertyChanged => _delegateeTarget.onBubblePropertyChanged;

  List<E> _backingList;

  DartBeanProxy _delegateeTarget;

  DartBeanList() {
    _delegateeTarget = new DartBeanProxy(this);

    _backingList = new List<E>();
  }

  EventTargetDelegatee get delegateeTarget => _delegateeTarget;

  bool get bubbleTargetingActive => _delegateeTarget.bubbleTargetingActive;

  void activeBubbleTargeting() {
    if (!_delegateeTarget.bubbleTargetingActive) {
      _delegateeTarget.activeBubbleTargeting();

      int index = 0;
      _backingList.forEach((bubblingTarget) {
        print("add bubbling target lazily");
        bubblingTarget.addBubbleTarget(index++, this);
      });
    }
  }

  void deactiveBubbleTargeting() {
    if (_delegateeTarget.bubbleTargetingActive) {
      _delegateeTarget.deactiveBubbleTargeting();

      int index = _backingList.length;
      _backingList.reversed.forEach((bubblingTarget) {
        print("remove bubbling target eagerly");
        bubblingTarget.removeBubbleTarget(--index, this);
      });
    }
  }

  void addBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		_delegateeTarget.addBubbleTarget(bubblingId, bubbleTarget);
  }

  void removeBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
    _delegateeTarget.removeBubbleTarget(bubblingId, bubbleTarget);
  }

	void addPropertyValue(int index, E value,
			{void onPreDispatching(PropertyChangedEvent event),
	  			void onPostDispatched(PropertyChangedEvent event),
				bool adjustBubblingIds: true}) {
		if (value is BubblingTarget) {
			_addBubblingTarget(index, value);
		}

		_backingList.insert(index, value);

		if (adjustBubblingIds) {
			_adjustBubblingIds(index, 1);
		}

		PropertyChangedEvent event = new PropertyChangedEvent.createAdded(value);

    if (onPreDispatching != null) {
    		onPreDispatching(event);
    }

    _delegateeTarget.dispatchPropertyChanged(index, event);

    if (onPostDispatched != null) {
			onPostDispatched(event);
    }
	}

	void updatePropertyValue(int index, E value,
			{bool forceUpdate: false,
	  			void onPreDispatching(PropertyChangedEvent event),
	  				void onPostDispatched(PropertyChangedEvent event)}) {

		var previous = _backingList[index];

		if(forceUpdate || value != previous) {
			if (previous is BubblingTarget) {
				_removeBubblingTarget(index, previous);
			}

		  _backingList[index] = value;

			if (value is BubblingTarget) {
				_addBubblingTarget(index, value);
			}

			PropertyChangedEvent event = new PropertyChangedEvent(value, previous);

	    if (onPreDispatching != null) {
  				onPreDispatching(event);
	    }

	    _delegateeTarget.dispatchPropertyChanged(index, event);

	    if (onPostDispatched != null) {
				onPostDispatched(event);
	    }
		}
	}

	bool removePropertyValue(int index,
			{void onPreDispatching(PropertyChangedEvent event),
	  			void onPostDispatched(PropertyChangedEvent event),
					bool adjustBubblingIds: true}) {
		var removed = _backingList.removeAt(index);

		if (removed != null) {
			if (removed is BubblingTarget) {
				_removeBubblingTarget(index, removed);
			}

			// adjust next bubblingIds
			if (adjustBubblingIds) {
				_adjustBubblingIds(index, -1);
			}

			PropertyChangedEvent event = new PropertyChangedEvent.createRemoved(removed);

	    if (onPreDispatching != null) {
	    		onPreDispatching(event);
	    }

	    _delegateeTarget.dispatchPropertyChanged(index, event);

	    if (onPostDispatched != null) {
				onPostDispatched(event);
	    }
		}
	}

  void _addBubblingTarget(int bubblingId, E bubblingTarget) {
    if (bubbleTargetingActive) {
      print("add bubbling target");
      bubblingTarget.addBubbleTarget(bubblingId, this);
    }
  }

  void _removeBubblingTarget(int bubblingId, E bubblingTarget) {
    if (bubbleTargetingActive) {
      print("remove bubbling target");
      bubblingTarget.removeBubbleTarget(bubblingId, this);
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
	  if (bubbleTargetingActive) {
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
	      _backingList.sublist(fromIndex).forEach((nextElement) {
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