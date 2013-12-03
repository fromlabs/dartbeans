// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import "package:dartbeans/dartbeans.dart";

import "dart:async";

class Person extends DartBean {
	// property names
	static const NAME = "name";

	// custom event types
	static const REFRESHED_EVENT_TYPE = "refreshed";

	Stream<FLEvent> get onRefreshed => onEvents[REFRESHED_EVENT_TYPE];
  Stream<PropertyChangedEvent> get onNameChanged =>
		onPropertyChangedEvents[NAME];

	Person();

  String get name => this[NAME];

  void set name(String name) {
    this[NAME] = name;
  }

	void refresh() {
		dispatch(REFRESHED_EVENT_TYPE);
	}

  String toString() => "[Person: $name]";
}

void main() {
  Person person = new Person();

	person.onNameChanged.listen((PropertyChangedEvent event) {
		print("Property change ${event.property} = ${event.newValue}"
			+ " on ${event.target}");
	});

	person.onRefreshed.listen((event) {
		print("Refresh on ${event.target}");
	});

	person.name = "Hans";

	person.refresh();
}