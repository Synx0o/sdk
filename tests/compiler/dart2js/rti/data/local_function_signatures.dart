// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';

class Class1 {
  method1() {
    /*ast.*/
    /*kernel.*/
    /*strong.needsSignature*/
    /*omit.needsSignature*/
    num local(num n) => null;
    return local;
  }

  method2() {
    num local(int n) => null;
    return local;
  }

  method3() {
    Object local(num n) => null;
    return local;
  }
}

/*!strong.class: Class2:needsArgs*/
/*strong.class: Class2:direct,explicit=[Class2.T],needsArgs*/
class Class2<T> {
  method4() {
    /*needsSignature*/
    num local(T n) => null;
    return local;
  }
}

/*class: Class3:needsArgs*/
class Class3<T> {
  method5() {
    /*needsSignature*/
    T local(num n) => null;
    return local;
  }
}

/*!strong.class: Class4:*/
/*strong.class: Class4:direct,explicit=[Class4.T],needsArgs*/
class Class4<T> {
  method6() {
    /**/
    num local(num n, T t) => null;
    return local;
  }
}

@NoInline()
test(o) => o is num Function(num);

main() {
  Expect.isTrue(test(new Class1().method1()));
  Expect.isFalse(test(new Class1().method2()));
  Expect.isFalse(test(new Class1().method3()));
  Expect.isTrue(test(new Class2<num>().method4()));
  Expect.isTrue(test(new Class3<num>().method5()));
  Expect.isFalse(test(new Class4<num>().method6()));
}
