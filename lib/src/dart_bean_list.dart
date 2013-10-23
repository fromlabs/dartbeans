// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

class DartBeanList<E extends DartBean> extends ListBase<E> implements EventTargetDelegator, List<E> {

	Stream<FLEvent> get onEventDispatched => _delegate.onEventDispatched;

  Stream<FLEvent> get onBubbleEventDispatched => _delegate.onBubbleEventDispatched;

  Stream<PropertyChangedEvent> get onPropertyChanged => _delegate.onPropertyChanged;

  Stream<PropertyChangedEvent> get onBubblePropertyChanged => _delegate.onBubblePropertyChanged;

  List<E> _backingList;

  ProxyDartBean _delegate;

  DartBeanList() {
		_delegate = new ProxyDartBean(this);

    _backingList = new List<E>();
  }

	FLEventTarget get delegate => _delegate;

  void addBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		_delegate.addBubbleTarget(bubblingId, bubbleTarget);
  }

  void removeBubbleTarget(dynamic bubblingId, FLEventTarget bubbleTarget) {
		_delegate.removeBubbleTarget(bubblingId, bubbleTarget);
  }

	void addPropertyValue(int index, E value,
			{void onPreDispatching(PropertyChangedEvent event),
	  			void onPostDispatched(PropertyChangedEvent event),
				bool adjustBubblingIds: true}) {
		if (value is BubblingTarget) {
			value.addBubbleTarget(index, this);
		}

		_backingList.insert(index, value);

		if (adjustBubblingIds) {
			_adjustBubblingIds(index, 1);
		}

		PropertyChangedEvent event = new PropertyChangedEvent.createAdded(value);

    if (onPreDispatching != null) {
    		onPreDispatching(event);
    }

		_delegate.notifyPropertyChanged(index, event);

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
				previous.removeBubbleTarget(index, this);
			}

		  _backingList[index] = value;

			if (value is BubblingTarget) {
				value.addBubbleTarget(index, this);
			}

			PropertyChangedEvent event = new PropertyChangedEvent(value, previous);

	    if (onPreDispatching != null) {
  				onPreDispatching(event);
	    }

			_delegate.notifyPropertyChanged(index, event);

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
				removed.removeBubbleTarget(index, this);
			}

			// adjust next bubblingIds
			if (adjustBubblingIds) {
				_adjustBubblingIds(index, -1);
			}

			PropertyChangedEvent event = new PropertyChangedEvent.createRemoved(removed);

	    if (onPreDispatching != null) {
	    		onPreDispatching(event);
	    }

			_delegate.notifyPropertyChanged(index, event);

	    if (onPostDispatched != null) {
				onPostDispatched(event);
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

	void _throwTodoError() {
    throw new UnimplementedError("TODO");
  }
}