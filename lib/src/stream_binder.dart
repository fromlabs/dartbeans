// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

typedef void ActionExecution();

typedef PropertyCalculation();

class ListenerBinding {

	var _key;

	ListenerBinding(this._key);
}

class ListenerBinder {

	Map<dynamic, StreamSubscription> _subscriptions = {};

	var _onData;

	ListenerBinder(this._onData);

	ListenerBinding listen(Stream stream, [dynamic key]) {
		var subscription = stream.listen(_onData);
		if (key == null) {
			key = identityHashCode(subscription);
		}
		_subscriptions[key] = subscription;

		return new ListenerBinding(key);
	}

	void unlisten(ListenerBinding listenerBinding) {
		var subscription = _subscriptions.remove(listenerBinding._key);
		subscription.cancel();
	}

	Iterable<ListenerBinding> listens(Iterable<Stream> streams) {
		var bindings = [];
		streams.forEach((stream) {
			bindings.add(listen(stream));
		});
		return bindings;
	}

	void pause() {
		this._subscriptions.forEach((key, subscription) => subscription.pause());
	}

	void resume() {
		this._subscriptions.forEach((key, subscription) => subscription.resume());
	}

	void cancel() {
		new List.from(this._subscriptions.values).reversed.forEach((subscription) => subscription.cancel());
		this._subscriptions.clear();
	}
}

class ActionBinder extends ListenerBinder {

	ActionExecution _execute;

	ActionBinder(this._execute) : super(null) {
		_onData = (event) => this._execute();
	}

	ActionBinder.runImmediately(this._execute) : super(null) {
		_onData = (event) => this._execute();
		runNow();
	}

	void runNow() {
		_onData(null);
	}
}
