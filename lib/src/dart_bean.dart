// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

class PropertyChangedEvent extends DiscriminatedEvent {

  static const String EVENT_TYPE = "propertyChanged.";

  final dynamic oldValue;

  final dynamic newValue;

	final bool added;

	final bool removed;

  PropertyChangedEvent(this.newValue, this.oldValue) :
			this.added = false, this.removed = false;

	PropertyChangedEvent.createAdded(this.newValue) :
			this.oldValue = null, this.added = true, this.removed = false;

	PropertyChangedEvent.createRemoved(this.oldValue) :
			this.newValue = null, this.added = false, this.removed = true;

	PropertyChangedEvent._clone(this.newValue, this.oldValue, this.added, this.removed);

  dynamic get property => discriminator;

  PropertyChangedEvent clone()
    		=> new PropertyChangedEvent._clone(newValue, oldValue, added, removed);
}

class DartBeanProxy extends DartBean
    implements EventTargetDelegatee, EventTargetDelegator {

  EventTargetDelegator _delegatorTarget;

  DartBeanProxy([this._delegatorTarget]);

  EventTargetDelegator get delegatorTarget => _delegatorTarget != null ? _delegatorTarget : this;

  EventTargetDelegatee get delegateeTarget => _delegatorTarget != null ? null : this;
}

class DartBean extends BaseTarget implements ActivableBubbleTarget {

  bool _bubbleTargetingEnabled;

  final Map<String, dynamic> _propertyValues = {};

  final LinkedHashMap<String, BubblingTarget> _bubblingTargets; // TODO use _propertyValues instead

  final Set<String> _bubbleTargetActivationCascadings;

  DiscriminatorStreams<PropertyChangedEvent> get
    onPropertyChangedEvents =>
			onToDiscriminateEvents[PropertyChangedEvent.EVENT_TYPE];

  DiscriminatorStreams<PropertyChangedEvent> get
    onBubblePropertyChangedEvents =>
			onBubbleToDiscriminateEvents[PropertyChangedEvent.EVENT_TYPE];

	Stream<PropertyChangedEvent> get onPropertyChanged =>
		onPropertyChangedEvents.stream;

  Stream<PropertyChangedEvent> get onBubblePropertyChanged =>
		onBubblePropertyChangedEvents.stream;

  DartBean() :
      this._bubbleTargetingEnabled = false,
      this._bubblingTargets = new LinkedHashMap() ,
      this._bubbleTargetActivationCascadings = new Set();

  bool isBubbleTargetActivationCascading(String property) =>
      _bubbleTargetActivationCascadings.contains(property);

  void addBubbleTargetActivationCascading(String property) {
    if (!isBubbleTargetActivationCascading(property)) {
      if (bubbleTargetingEnabled) {
        throw new StateError("Can't change bubble target activation cascading descriptors when the bean is is enabled for bubble targeting!");
      }

      _bubbleTargetActivationCascadings.add(property);
    }
  }

  void removeBubbleTargetActivationCascading(String property) {
    if (isBubbleTargetActivationCascading(property)) {
      if (bubbleTargetingEnabled) {
        throw new StateError("Can't change bubble target activation cascading descriptors when the bean is is enabled for bubble targeting!");
      }

      _bubbleTargetActivationCascadings.remove(property);
    }
  }

  bool get bubbleTargetingEnabled => _bubbleTargetingEnabled;

  void enableBubbleTargeting() {
    if (!this._bubbleTargetingEnabled) {
      this._bubbleTargetingEnabled = true;

      _bubblingTargets.forEach((bubblingId, bubblingTarget) {
        if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(bubblingId)) {
          if (bubblingTarget is DependantActivationBubbleTarget) {
            bubblingTarget.addBubbleTargetActivationCascading(bubblingId);
          }

          bubblingTarget.enableBubbleTargeting();
        }

        bubblingTarget.addBubbleTarget(bubblingId, this);
      });
    }
  }

  void disableBubbleTargeting() {
    if (this._bubbleTargetingEnabled) {
      this._bubbleTargetingEnabled = false;

      _bubblingTargets.keys.toList(growable: false).reversed.forEach((bubblingId) {
        var bubblingTarget = _bubblingTargets[bubblingId];

        _bubblingTargets[bubblingId].removeBubbleTarget(bubblingId, this);

        if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(bubblingId)) {
          bubblingTarget.disableBubbleTargeting();
        }
      });
    }
  }

  operator [](String property) => getPropertyValue(property);

  void operator []=(String property, var value) {
    setPropertyValue(property, value);
  }

  getPropertyValue(String property) =>
      _propertyValues[property];

  bool setPropertyValue(String property, var value,
      {bool forceUpdate: false,
        void onPreDispatching(PropertyChangedEvent event),
          void onPostDispatched(PropertyChangedEvent event)}) {
		var exist = _propertyValues.containsKey(property);
    var old = exist ? _propertyValues[property] : null;
    if(forceUpdate || value != old) {
			if (old is BubblingTarget) {
				_removeBubblingTarget(property, old);
			}

      _propertyValues[property] = value;

			if (value is BubblingTarget) {
			  _addBubblingTarget(property, value);
			}

      PropertyChangedEvent event = exist ? new PropertyChangedEvent(value, old)
					: new PropertyChangedEvent.createAdded(value);

      if (onPreDispatching != null) {
        onPreDispatching(event);
      }

      dispatchPropertyChanged(property, event);

      if (onPostDispatched != null) {
        onPostDispatched(event);
      }

      return true;
    } else {
      return false;
    }
  }

  void _addBubblingTarget(dynamic bubblingId, BubblingTarget bubblingTarget) {
    if (bubbleTargetingEnabled) {
      if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(bubblingId)) {
        if (bubblingTarget is DependantActivationBubbleTarget) {
          (bubblingTarget as DependantActivationBubbleTarget).addBubbleTargetActivationCascading(bubblingId);
        }

        (bubblingTarget as ActivableBubbleTarget).enableBubbleTargeting();
      }

      bubblingTarget.addBubbleTarget(bubblingId, this);
    }

    _bubblingTargets[bubblingId] = bubblingTarget;
  }

  void _removeBubblingTarget(dynamic bubblingId, BubblingTarget bubblingTarget) {
    _bubblingTargets.remove(bubblingId);

    if (bubbleTargetingEnabled) {
      bubblingTarget.removeBubbleTarget(bubblingId, this);

      if (bubblingTarget is ActivableBubbleTarget && isBubbleTargetActivationCascading(bubblingId)) {
        (bubblingTarget as ActivableBubbleTarget).disableBubbleTargeting();
      }
    }
  }

  void dispatchPropertyChanged(dynamic property,
      PropertyChangedEvent event) {
    discriminatedDispatch(PropertyChangedEvent.EVENT_TYPE, property, event);
  }

  PropertyCalculationBinder bindCalculatedProperty(String targetProperty, PropertyCalculation calculate) =>
      new PropertyCalculationBinder(this, targetProperty, calculate);

  PropertyProxionBinder bindProxiedProperty(source, String sourceProperty, {target, targetProperty}) =>
      new PropertyProxionBinder(target != null ? target : this, targetProperty != null ? targetProperty : sourceProperty, source, sourceProperty);
}

class PropertyCalculationBinder extends ActionBinder {
  final target;

  final String targetProperty;

  PropertyCalculation _calculate;

  PropertyCalculationBinder(this.target, this.targetProperty, this._calculate) : super(null) {
    _execute = () {
      var value = this._calculate();
      if (value is Future) {
        value.then((futureValue) =>
          reflect(this.target).setField(new Symbol(this.targetProperty), futureValue.reflectee));
      } else {
        return reflect(this.target).setField(new Symbol(this.targetProperty), value);
      }
    };
    if (_calculate != null) {
      runNow();
    }
  }
}

class PropertyProxionBinder extends PropertyCalculationBinder {
  final DartBean source;

  final String sourceProperty;

  PropertyProxionBinder(target, targetProperty, this.source, this.sourceProperty) : super(target, targetProperty, null) {
    _calculate = () => reflect(this.source).getField(new Symbol(this.sourceProperty)).reflectee;
    this.listen(this.source.onToDiscriminateEvents[PropertyChangedEvent.EVENT_TYPE][targetProperty]);
    runNow();
  }
}