// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';

main() {
  /*1:main*/ test();
}

test() async /*ast.2:test*/ {
  // TODO(johnniwinther): Investigate why kernel doesn't point to the body
  // start brace.
  // ignore: UNUSED_LOCAL_VARIABLE
  var /*kernel.2:test*/ c = new /*3:test*/ Class();
}

class Class {
  @NoInline()
  /*4:Class*/ Class() {
    /*5:Class*/ throw '>ExceptionMarker<';
  }
}
