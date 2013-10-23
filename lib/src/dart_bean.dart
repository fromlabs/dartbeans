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

class ProxyDartBean extends DartBean
    implements EventTargetProxy {

  FLEventTarget _target;

	ProxyDartBean([FLEventTarget target]) {
    this._target = target != null ? target : this;
  }

  FLEventTarget get target => _target;
}

abstract class DartBean extends BaseTarget {
  final Map<String, dynamic> _propertyValues = {};

  ToDiscriminateEventStreamProvider get _propertyChangedProvider =>
  			_eventProvider[PropertyChangedEvent.EVENT_TYPE];

  Stream<PropertyChangedEvent> get onPropertyChanged =>
      _propertyChangedProvider.stream;

  Stream<PropertyChangedEvent> get onBubblePropertyChanged =>
      _propertyChangedProvider.bubbleStream;

  DiscriminatorStreams<PropertyChangedEvent> get
    onPropertyChangedEvents =>
      _propertyChangedProvider.onDiscriminatorEvents;

  DiscriminatorStreams<PropertyChangedEvent> get
    onBubblePropertyChangedEvents =>
        _propertyChangedProvider.onBubbleDiscriminatorEvents;

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
				old.removeBubbleTarget(property, this);
			}

      _propertyValues[property] = value;

			if (value is BubblingTarget) {
				value.addBubbleTarget(property, this);
			}

      PropertyChangedEvent event = exist ? new PropertyChangedEvent(value, old)
					: new PropertyChangedEvent.createAdded(value);

      if (onPreDispatching != null) {
        onPreDispatching(event);
      }

      notifyPropertyChanged(property, event);

      if (onPostDispatched != null) {
        onPostDispatched(event);
      }

      return true;
    } else {
      return false;
    }
  }

  void notifyPropertyChanged(dynamic property,
      PropertyChangedEvent event) {
    _propertyChangedProvider[property].notify(event);
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