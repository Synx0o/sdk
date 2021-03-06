// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Helper to test compilation equivalence between source and .dill based
// compilation.
library dart2js.kernel.compile_from_dill_test_helper;

import 'dart:async';

import 'package:compiler/compiler_new.dart';
import 'package:compiler/src/commandline_options.dart';
import 'package:compiler/src/common.dart';
import 'package:compiler/src/compiler.dart';
import 'package:compiler/src/elements/elements.dart';
import 'package:compiler/src/elements/types.dart';
import 'package:compiler/src/kernel/element_map.dart';
import 'package:compiler/src/kernel/kernel_backend_strategy.dart';
import 'package:compiler/src/kernel/kernel_strategy.dart';
import 'package:compiler/src/universe/world_builder.dart';
import 'package:compiler/src/world.dart';
import 'package:expect/expect.dart';
import '../memory_compiler.dart';
import '../equivalence/check_functions.dart';
import '../equivalence/check_helpers.dart';
import '../equivalence/equivalence_helper.dart';

import 'arguments.dart';
import 'compiler_helper.dart';
import 'test_helpers.dart';

class Test {
  final Uri uri;
  final Map<String, String> sources;
  final bool expectIdenticalOutput;

  const Test(this.sources, {this.expectIdenticalOutput: true}) : uri = null;

  Test.fromUri(this.uri, {this.expectIdenticalOutput: true})
      : sources = const {};

  Uri get entryPoint => uri ?? Uri.parse('memory:main.dart');

  String toString() => uri != null ? '$uri' : sources.values.first;
}

const List<Test> TESTS = const <Test>[
  const Test(const {
    'main.dart': '''
import 'dart:html';
import 'package:expect/expect.dart';

foo({named}) => 1;
bar(a) => !a;
class Class {
  var field;
  static var staticField;

  Class();
  Class.named(this.field) {
    staticField = 42;
  }

  method() {}
}

class SubClass extends Class {
  method() {
    super.method();
  }
}

class Generic<T> {
  method(o) => o is T;
}

var toplevel;

typedef Typedef();

class Mixin1 {
  var field1;
}

class Mixin2 {
  var field2;
}

class MixinSub1 extends Object with Mixin1 {
}

class MixinSub2 extends Object with Mixin1, Mixin2 {
}

main() {
  foo();
  bar(true);
  [];
  <int>[];
  {};
  new Object();
  new Class.named('');
  new SubClass().method();
  Class.staticField;
  var x = null;
  var y1 = x == null;
  var y2 = null == x;
  var z1 = x?.toString();
  var z2 = x ?? y1;
  var z3 = x ??= y2;
  var w = x == null ? null : x.toString();
  for (int i = 0; i < 10; i++) {
    if (i == 5) continue;
    x = i;
    if (i == 5) break;
  }
  int i = 0;
  while (i < 10) {
    if (i == 5) continue;
    x = i;
    if (i == 7) break;
    i++;
  }
  for (var v in [3, 5]) {
    if (v == 5) continue;
    x = v;
    if (v == 7) break;
  }
  do {
    x = i;
    if (i == 7) break;
    i++;
  } while (i < 10);
  switch (x) {
  case 0:
    x = 7;
    break;
  case 1:
    x = 9;
    break;
  default:
    x = 11;
    break;
  }
  x = toplevel;
  x = testIs(x);
  x = new Generic<int>().method(x);
  x = testAsGeneric(x);
  x = testAsFunction(x);
  print(x);
  var f = (x) {
    return 400 + x;
  };
  x = f(x);
  x = Object;
  x = Typedef;
  new MixinSub2();
  new MixinSub1();
  return x;
}
typedef NoArg();
@NoInline()
testIs(o) => o is Generic<int> || o is NoArg;
@NoInline()
testAsGeneric(o) => o as Generic<int>;
@NoInline()
testAsFunction(o) => o as NoArg;
'''
  }),
  const Test(const {
    'main.dart': '''

main() {
  var x;
  int i = 0;
  do {
    if (i == 5) continue;
    x = i;
    if (i == 7) break;
    i++;
  } while (i < 10);
  outer1: for (var a in [3, 5]) {
    for (var b in [2, 4]) {
      if (a == b) break outer1;
    }
  }
  outer2: for (var a in [3, 5]) {
    for (var b in [2, 4]) {
      if (a != b) continue outer2;
    }
  }
  outer3: for (var a in [3, 5]) {
    for (var b in [2, 4]) {
      if (a == b) break outer3;
      if (a != b) continue outer3;
    }
  }
  print(x);
}
'''
  }, expectIdenticalOutput: false),
  const Test(const {
    'main.dart': '''
main() {
  var x = 42;
  int i = 0;
  switch (i) {
  case 0:
     print(x);
     continue label1;
  label1:
     case 1:
     print(x);
     break;
  }
}    
'''
  }, expectIdenticalOutput: false),
  const Test(const {
    'main.dart': '''
main() {
    int x = 1;
  switch(x) {
    case 1:
      print('spider');
      continue world;
    case 5:
      print('beetle');
      break;
    world:
    case 6:
      print('cricket');
      break;
    default:
      print('bat');
  }
}
'''
  }, expectIdenticalOutput: false),
  const Test(const {
    'main.dart': '''
main() {
    int x = 1;
  switch(x) {
    case 1:
      print('spider');
      continue world;
    world:
    case 5:
      print('beetle');
      break;
    case 6:
      print('cricket');
      break;
    default:
      print('bat');
  }
}'''
  }, expectIdenticalOutput: false),
  const Test(const {
    'main.dart': '''
main() {
    int x = 1;
  switch(x) {
    case 1:
      print('spider');
      continue world;
    world:
    case 5:
      print('beetle');
      break;
    case 6:
      print('cricket');
      break;
  }
}'''
  }, expectIdenticalOutput: false),
  const Test(const {
    'main.dart': '''
main() {
    int x = 8;
  switch(x) {
    case 1:
      print('spider');
      continue world;
    world:
    case 5:
      print('beetle');
      break;
    case 6:
      print('cricket');
      break;
  }
}'''
  }, expectIdenticalOutput: false),
  const Test(const {
    'main.dart': '''
class A<U,V> {
  var a = U;
  var b = V;
}
class B<Q, R> extends A<R, W<Q>> {
}
class C<Y> extends B<Y, W<Y>> {
}
class W<Z> {}
main() {
  print(new C<String>().a);
}
'''
  }, expectIdenticalOutput: true),
  const Test(const {
    'main.dart': '''
class _Marker { const _Marker(); }
const _MARKER = const _Marker();
class Thing<X> {
  Thing([length = _MARKER]);
}
foo(x) {
  print(new List(x).length);
}
main() {
  print(new Thing<String>(100));

  print(new List());
  print(new List(4));
  foo(3);
  foo(4);
}
'''
  }, expectIdenticalOutput: true),
];

enum ResultKind { crashes, errors, warnings, success, failure }

const List<String> commonOptions = const <String>[
  Flags.disableTypeInference,
  Flags.disableInlining,
  Flags.enableAssertMessage
];

Future runTests(List<String> args,
    {bool skipWarnings: false,
    bool skipErrors: false,
    List<String> options: const <String>[]}) async {
  Arguments arguments = new Arguments.from(args);
  List<Test> tests = TESTS;
  if (arguments.start != null) {
    int start = arguments.start;
    int end = arguments.end ?? 0; // Default 'end' to single test.
    if (end > tests.length) end = tests.length; // Large 'end' means all.
    if (end <= start) end = start + 1; // Always at least one test (else Error).
    tests = tests.sublist(start, end);
  } else if (arguments.uri != null) {
    tests = <Test>[new Test.fromUri(arguments.uri)];
  }
  for (Test test in tests) {
    if (test.uri != null) {
      print('--- running test uri ${test.uri} -------------------------------');
    } else {
      print(
          '--- running test code -------------------------------------------');
      print(test.sources.values.first);
      print('----------------------------------------------------------------');
    }
    await runTest(test.entryPoint, test.sources,
        verbose: arguments.verbose,
        skipWarnings: skipWarnings,
        skipErrors: skipErrors,
        options: options,
        expectIdenticalOutput: test.expectIdenticalOutput);
  }
}

Future<ResultKind> runTest(
    Uri entryPoint, Map<String, String> memorySourceFiles,
    {bool skipWarnings: false,
    bool skipErrors: false,
    bool verbose: false,
    List<String> options: const <String>[],
    bool expectAstEquivalence: false,
    bool expectIdenticalOutput: true}) async {
  enableDebugMode();
  Elements.useCFEOrder = true;

  print('---- compile from ast ----------------------------------------------');
  DiagnosticCollector collector = new DiagnosticCollector();
  OutputCollector collector1 = new OutputCollector();
  ElementResolutionWorldBuilder.useInstantiationMap = true;
  CompilationResult result = await runCompiler(
      entryPoint: entryPoint,
      memorySourceFiles: memorySourceFiles,
      diagnosticHandler: collector,
      outputProvider: collector1,
      options: <String>[]..addAll(commonOptions)..addAll(options),
      beforeRun: (compiler) {
        compiler.impactCacheDeleter.retainCachesForTesting = true;
      });
  Compiler compiler1 = result.compiler;
  if (collector.crashes.isNotEmpty) {
    print('Skipping due to crashes.');
    return ResultKind.crashes;
  }
  if (collector.errors.isNotEmpty && skipErrors) {
    print('Skipping due to errors.');
    return ResultKind.errors;
  }
  if (collector.warnings.isNotEmpty && skipWarnings) {
    print('Skipping due to warnings.');
    return ResultKind.warnings;
  }
  Expect.isFalse(compiler1.compilationFailed);
  ClosedWorld closedWorld1 =
      compiler1.resolutionWorldBuilder.closedWorldForTesting;

  OutputCollector collector2 = new OutputCollector();
  Compiler compiler2 = await compileWithDill(
      entryPoint: entryPoint,
      memorySourceFiles: memorySourceFiles,
      options: <String>[]..addAll(commonOptions)..addAll(options),
      printSteps: true,
      compilerOutput: collector2);

  // Print the middle section of the outputs if they are not line-wise
  // identical.
  collector1.outputMap
      .forEach((OutputType outputType, Map<String, BufferedOutputSink> map1) {
    if (outputType == OutputType.sourceMap) {
      return;
    }
    Map<String, BufferedOutputSink> map2 = collector2.outputMap[outputType];
    checkSets(map1.keys, map2.keys, 'output', equality);
    map1.forEach((String name, BufferedOutputSink output1) {
      BufferedOutputSink output2 = map2[name];
      if (output1.text == output2.text) return;
      List<String> lines1 = output1.text.split('\n');
      List<String> lines2 = output2.text.split('\n');
      int prefix = 0;
      while (prefix < lines1.length && prefix < lines2.length) {
        if (lines1[prefix] != lines2[prefix]) {
          break;
        }
        prefix++;
      }
      if (prefix > 0) prefix--;
      int suffix1 = lines1.length - 1;
      int suffix2 = lines2.length - 1;
      while (suffix1 >= 0 && suffix2 >= 0) {
        if (lines1[suffix1] != lines2[suffix2]) {
          break;
        }
        suffix1--;
        suffix2--;
      }
      if (suffix1 + 1 < lines1.length) suffix1++;
      if (suffix2 + 1 < lines2.length) suffix2++;
      print('--- from source, lines [${prefix}-${suffix1}] ------------------');
      lines1.sublist(prefix, suffix1 + 1).forEach(print);
      print('--- from dill, lines [${prefix}-${suffix2}] --------------------');
      lines2.sublist(prefix, suffix2 + 1).forEach(print);
    });
  });

  KernelFrontEndStrategy frontendStrategy = compiler2.frontendStrategy;
  KernelToElementMap elementMap = frontendStrategy.elementMap;

  Expect.isFalse(compiler2.compilationFailed);

  KernelEquivalence equivalence1 = new KernelEquivalence(elementMap);

  ClosedWorld closedWorld2 =
      compiler2.resolutionWorldBuilder.closedWorldForTesting;

  checkBackendUsage(closedWorld1.backendUsage, closedWorld2.backendUsage,
      equivalence1.defaultStrategy);

  print('--- checking resolution enqueuers ----------------------------------');
  checkResolutionEnqueuers(closedWorld1.backendUsage, closedWorld2.backendUsage,
      compiler1.enqueuer.resolution, compiler2.enqueuer.resolution,
      elementEquivalence: (a, b) => equivalence1.entityEquivalence(a, b),
      typeEquivalence: (DartType a, DartType b) {
        return equivalence1.typeEquivalence(unalias(a), b);
      },
      elementFilter: elementFilter,
      verbose: verbose);

  print('--- checking closed worlds -----------------------------------------');
  checkClosedWorlds(closedWorld1, closedWorld2,
      strategy: equivalence1.defaultStrategy,
      verbose: verbose,
      // TODO(johnniwinther,efortuna): Require closure class equivalence when
      // these are supported.
      allowMissingClosureClasses: true);

  // TODO(johnniwinther): Perform equivalence tests on the model: codegen world
  // impacts, program model, etc.

  print('--- checking codegen enqueuers--------------------------------------');

  KernelBackendStrategy backendStrategy = compiler2.backendStrategy;
  KernelEquivalence equivalence2 =
      new KernelEquivalence(backendStrategy.elementMap);

  checkCodegenEnqueuers(compiler1.enqueuer.codegenEnqueuerForTesting,
      compiler2.enqueuer.codegenEnqueuerForTesting,
      elementEquivalence: (a, b) => equivalence2.entityEquivalence(a, b),
      typeEquivalence: (DartType a, DartType b) {
        return equivalence2.typeEquivalence(unalias(a), b);
      },
      elementFilter: elementFilter,
      verbose: verbose);

  checkEmitters(compiler1.backend.emitter, compiler2.backend.emitter,
      equivalence2.defaultStrategy,
      elementEquivalence: (a, b) => equivalence2.entityEquivalence(a, b),
      typeEquivalence: (DartType a, DartType b) {
        return equivalence2.typeEquivalence(unalias(a), b);
      },
      verbose: verbose);

  if (expectAstEquivalence) {
    checkGeneratedCode(compiler1.backend, compiler2.backend,
        elementEquivalence: (a, b) => equivalence2.entityEquivalence(a, b));
  }

  if (expectIdenticalOutput) {
    print('--- checking output------- ---------------------------------------');
    collector1.outputMap
        .forEach((OutputType outputType, Map<String, BufferedOutputSink> map1) {
      if (outputType == OutputType.sourceMap) {
        // TODO(johnniwinther): Support source map from .dill.
        return;
      }
      Map<String, BufferedOutputSink> map2 = collector2.outputMap[outputType];
      checkSets(map1.keys, map2.keys, 'output', equality);
      map1.forEach((String name, BufferedOutputSink output1) {
        BufferedOutputSink output2 = map2[name];
        Expect.stringEquals(output1.text, output2.text);
      });
    });
  }
  return ResultKind.success;
}
