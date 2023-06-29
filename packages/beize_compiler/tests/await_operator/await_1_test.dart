import 'package:beize_compiler/beize_compiler.dart';
import 'package:test/test.dart';
import '../utils.dart';

Future<void> main() async {
  const String title = '[Operator] Await (1)';
  final BeizeProgramConstant program =
      await compileTestScript('await_operator', 'await_1.beize');

  test('$title - Bytecode', () async {
    final BeizeChunk chunk = extractChunk(program);
    final BeizeTestChunk expectedChunk = BeizeTestChunk();
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
final BeizeTestChunk expectedChunk_0 = BeizeTestChunk();
expectedChunk_0.addOpCode(BeizeOpCodes.opConstant);
expectedChunk_0.addConstant(0, 'c-0');
expectedChunk_0.addOpCode(BeizeOpCodes.opReturn);
expectedChunk.addConstant(1, expectedChunk_0);
expectedChunk.addOpCode(BeizeOpCodes.opDeclare);
expectedChunk.addConstant(0, 'fn');
expectedChunk.addOpCode(BeizeOpCodes.opPop);
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(0, 'fn');
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(0);
expectedChunk.addOpCode(BeizeOpCodes.opDeclare);
expectedChunk.addConstant(2, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opPop);
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(3, 'out');
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(4, 'typeof');
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(2, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(1);
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(1);
expectedChunk.addOpCode(BeizeOpCodes.opPop);
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(2, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opAwait);
expectedChunk.addOpCode(BeizeOpCodes.opAssign);
expectedChunk.addConstant(2, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opPop);
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(3, 'out');
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(2, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(1);
expectedChunk.addOpCode(BeizeOpCodes.opPop);
    expect(tcpc(chunk), tcptc(expectedChunk));
  });

  test('$title - Channel', () async {
    final List<String> expected = <String>['Unawaited', 'c-0'];
    final List<String> actual = await executeTestScript(program);
    expect(actual, orderedEquals(expected));
  });
}