import 'package:beize_compiler/beize_compiler.dart';
import 'package:test/test.dart';
import '../utils.dart';

Future<void> main() async {
  const String title = '[Value] String (1)';
  final BeizeProgramConstant program =
      await compileTestScript('string_value', 'string_padLeft_1.beize');

  test('$title - Bytecode', () async {
    final BeizeChunk chunk = extractChunk(program);
    final BeizeTestChunk expectedChunk = BeizeTestChunk();
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(1, '1');
expectedChunk.addOpCode(BeizeOpCodes.opDeclare);
expectedChunk.addConstant(0, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opPop);
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(2, 'out');
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(3, '');
expectedChunk.addOpCode(BeizeOpCodes.opLookup);
expectedChunk.addConstant(0, 'result');
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(4, 'padLeft');
expectedChunk.addOpCode(BeizeOpCodes.opGetProperty);
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(5, 2.0);
expectedChunk.addOpCode(BeizeOpCodes.opConstant);
expectedChunk.addConstant(6, '0');
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(2);
expectedChunk.addOpCode(BeizeOpCodes.opAdd);
expectedChunk.addOpCode(BeizeOpCodes.opCall);
expectedChunk.addCode(1);
expectedChunk.addOpCode(BeizeOpCodes.opPop);
    expect(tcpc(chunk), tcptc(expectedChunk));
  });

  test('$title - Channel', () async {
    final List<String> expected = <String>['01'];
    final List<String> actual = await executeTestScript(program);
    expect(actual, orderedEquals(expected));
  });
}