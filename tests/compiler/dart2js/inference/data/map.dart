// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/*element: main:[null]*/
main() {
  emptyMap();
  nullMap();
  constMap();
  constNullMap();
  stringIntMap();
  intStringMap();
  constStringIntMap();
  constIntStringMap();
}

/*element: emptyMap:Dictionary([subclass=JsLinkedHashMap], key: [empty], value: [null], map: {})*/
emptyMap() => {};

/*element: constMap:Dictionary([subclass=ConstantMap], key: [empty], value: [null], map: {})*/
constMap() => const {};

/*element: nullMap:Map([subclass=JsLinkedHashMap], key: [null], value: [null])*/
nullMap() => {null: null};

/*element: constNullMap:Map([subclass=ConstantMap], key: [null], value: [null])*/
constNullMap() => const {null: null};

/*element: stringIntMap:Dictionary([subclass=JsLinkedHashMap], key: [exact=JSString], value: [null|exact=JSUInt31], map: {a: [exact=JSUInt31], b: [exact=JSUInt31], c: [exact=JSUInt31]})*/
stringIntMap() => {'a': 1, 'b': 2, 'c': 3};

/*element: intStringMap:Map([subclass=JsLinkedHashMap], key: [exact=JSUInt31], value: [null|exact=JSString])*/
intStringMap() => {1: 'a', 2: 'b', 3: 'c'};

/*element: constStringIntMap:Dictionary([subclass=ConstantMap], key: [exact=JSString], value: [null|exact=JSUInt31], map: {a: [exact=JSUInt31], b: [exact=JSUInt31], c: [exact=JSUInt31]})*/
constStringIntMap() => const {'a': 1, 'b': 2, 'c': 3};

/*element: constIntStringMap:Map([subclass=ConstantMap], key: [exact=JSUInt31], value: [null|exact=JSString])*/
constIntStringMap() => const {1: 'a', 2: 'b', 3: 'c'};
