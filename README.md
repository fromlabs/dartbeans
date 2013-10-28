[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/fromlabs/dartbeans/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

DartBeans
=========

DartBeans is a Dart library that helps working with event streams.

To know something more about the released version have a look at the
[CHANGELOG][changelog].

Getting started
---------------

**1.** Add the following dependency to your `pubspec.yaml` and run `pub get`:

```yaml
dependencies:
	dartbeans: any
	
```

**2.** Add `dartbeans` to your code and run it:

```dart
import "package:dartbeans/dartbeans.dart";

void main() {
	DartBean person = new DartBean();

	person.onPropertyChangedEvents["name"]
		.listen((PropertyChangedEvent event) =>
			print("Property changed: ${event.property} = ${event.newValue}"));

	person["name"] = "Hans";
}
```

Beans
-----

The common way to use DartBeans is by extending the `DartBean` class and by adding extra code for accessing properties:

```dart
class Person extends DartBean {
	static const NAME = "name";
	static const AGE = "age";

	String get name => this[NAME];

	void set name(String name) {
		this[NAME] = name;
	}

	int get age => this[AGE];

	void set age(int age) {
		this[AGE] = age;
	}
}
```

Property changed event streams are exposed by the `onPropertyChangedEvents` getter on the `DartBean` class and can be accessed in a convenient way:

```dart
	Stream<PropertyChangedEvent> get onNameChanged => onPropertyChangedEvents[NAME];
	Stream<PropertyChangedEvent> get onAgeChanged => onPropertyChangedEvents[AGE];
```

Custom events can be easily implemented:

```dart
	static const REFRESHED_EVENT_TYPE = "refreshed";
	
	Stream<FLEvent> get onRefreshed => onEvents[REFRESHED_EVENT_TYPE];
	
	void refresh() {
		dispatch(REFRESHED_EVENT_TYPE); // dispatch an FLEvent
	}
```
Then working with our beans is very simple:

```dart
void main() {
	Person person = new Person();

	// listen to changes on name property
	person.onNameChanged.listen((PropertyChangedEvent event) {
		print("1. Property change ${event.property} = ${event.newValue} on ${event.target}");
	});

	// listen to changes on age property
	person.onAgeChanged.listen((PropertyChangedEvent event) {
		print("2. Property change ${event.property} = ${event.newValue} on ${event.target}");
	});

	// listen to refreshes
	person.onRefreshed.listen((FLEvent event) {
		print("3. Refresh on ${event.target}");
	});

	person.name = "Hans";
	person.age = 18;
	person.refresh();
}
```

Binders
-------

TODOC

Bean chains
-----------

TODOC

Under the covers
----------------

TODOC

###Event providers###

TODOC

###Discriminated events###

TODOC

###Event bubbling###

TODOC

Examples
--------

Examples that show the use of DartBeans are in the [example] folder.

Running Tests
-------------
To run the tests just run the test/dartbeans_test.dart file.

Any comment?
------------
You're welcome! Just visit the [GitHub page][site] and open a new issue or mail me.


[changelog]:https://raw.github.com/fromlabs/dartbeans/master/CHANGELOG
[example]:https://github.com/fromlabs/dartbeans/tree/master/example
[site]:https://github.com/fromlabs/dartbeans
