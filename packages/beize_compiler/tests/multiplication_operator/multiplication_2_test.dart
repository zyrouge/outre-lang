import 'package:beize_compiler/beize_compiler.dart';
import 'package:test/test.dart';
import '../utils.dart';

Future<void> main() async {
  const String title = '[Operator] Multiplication (2)';
  final BeizeProgramConstant program =
      await compileTestScript('multiplication_operator', 'multiplication_2.beize');

  test('$title - Bytecode', () async {
    final BeizeChunk chunk = extractChunk(program);
    final BeizeTestChunk expectedChunk = BeizeTestChunk();
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(1, 'Number');
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(2, 'infinity');
expectedChunk.addOpCode(BeizeOpCodes.opGetProperty);
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(3, 2.0);
expectedChunk.addOpCode(BeizeOpCodes.opMultiply);
expectedChunk.addOpCode(BeizeOpCodes.opDeclare);
expectedChunk.addConstant(0, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opPop);
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(4, 'out');
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(5, '');
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(0, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opAdd);
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(1);
expectedChunk.addOpCode(BeizeOpCodes.opPop);
    expect(tcpc(chunk), tcptc(expectedChunk));
  });

  test('$title - Channel', () async {
    final List<String> expected = <String>['Infinity'];
    final List<String> actual = await executeTestScript(program);
    expect(actual, orderedEquals(expected));
  });
}