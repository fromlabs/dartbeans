[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/fromlabs/dartbeans/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

DartBeans
=========

DartBeans is a Dart library that helps working with event streams.

To know something more about the released version have a look at the
[CHANGELOG][changelog].

Getting started
---------------

**1.** Add the following dependency to your pubspec.yaml and run pub get:
```yaml
dependencies:
	dartbeans: any
```

**2.** Add dartbeans to your code and run it:
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

Examples
--------

Examples that show the use of DartBeans are in the example folder.

Running Tests
-------------

To run the tests just run the test/dartbeans_test.dart file.

Any comment?
------------

You're welcome! Just visit the [GitHub page][site] and open a new issue or mail me.

[changelog]:https://raw.github.com/fromlabs/dartbeans/master/CHANGELOG
[site]:https://github.com/fromlabs/dartbeans
