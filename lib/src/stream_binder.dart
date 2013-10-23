// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

typedef void ActionExecution();

typedef PropertyCalculation();

class ListenerBinder {
  List<StreamSubscription> _subscriptions = [];
  var _onData;

  ListenerBinder(this._onData);

  void listen(Stream stream) {
    var subscription = stream.listen(_notifyToListener);
    _subscriptions.add(subscription);
  }

  void listens(Iterable<Stream> streams) =>
      streams.forEach((stream) => listen(stream));

  void pause() {
    this._subscriptions.forEach((subscription) =>
        subscription.pause());
  }

  void resume() {
    this._subscriptions.forEach((subscription) =>
        subscription.resume());
  }

  void cancel() {
    this._subscriptions.reversed.forEach((subscription) =>
        subscription.cancel());
    this._subscriptions.clear();
  }

  void _notifyToListener(var event) {
    _onData(event);
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
    _notifyToListener(null);
  }
}