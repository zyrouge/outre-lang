import '../ast/exports.dart';
import '../lexer/exports.dart';
import '../node/exports.dart';
import 'context.dart';
import 'environment.dart';
import 'statement.dart';

typedef OutreExpressionEvaluatorEvaluateFn = Future<OutreValue> Function(
  OutreEvaluatorContext context,
  OutreEnvironment environment,
  OutreExpression expression,
);

typedef OutreExpressionEvaluatorCustomBinaryOperationFn = Future<OutreValue>
    Function(
  OutreEvaluatorContext context,
  OutreEnvironment environment,
  OutreBinaryExpression expression,
);

abstract class OutreExpressionEvaluator {
  static final Map<OutreNodes, OutreExpressionEvaluatorEvaluateFn>
      evaluateExpressionFns = <OutreNodes, OutreExpressionEvaluatorEvaluateFn>{
    OutreNodes.assignExpr: evaluateAssignExpression,
    OutreNodes.declareExpr: evaluateDeclareExpression,
    OutreNodes.arrayExpr: evaluateArrayExpression,
    OutreNodes.callExpr: evaluateCallExpression,
    OutreNodes.functionExpr: evaluateFunctionExpression,
    OutreNodes.groupExpr: evaluateGroupExpression,
    OutreNodes.identifierExpr: evaluateIdentifierExpression,
    OutreNodes.stringExpr: evaluateStringExpression,
    OutreNodes.numberExpr: evaluateNumberExpression,
    OutreNodes.booleanExpr: evaluateBooleanExpression,
    OutreNodes.nullExpr: evaluateNullExpression,
    OutreNodes.objectExpr: evaluateObjectExpression,
    OutreNodes.unaryExpr: evaluateUnaryExpression,
    OutreNodes.binaryExpr: evaluateBinaryExpression,
    OutreNodes.ternaryExpr: evaluateTernaryExpression,
    OutreNodes.indexAccessExpr: evaluateIndexAccessGetExpression,
    OutreNodes.memberAccessExpr: evaluateMemberAccessExpression,
    OutreNodes.nullMemberAccessExpr: evaluateNullMemberAccessExpression,
  };

  static Future<T> evaluateExpressionAndCast<T extends OutreValue>(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async =>
      (await evaluateExpression(context, environment, expression)).cast<T>();

  static Future<OutreValue> evaluateExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    context.pushStackFrame(
      environment.createStackFrameFromOutreNode(expression),
    );
    final OutreValue result = await evaluateExpressionFns[expression.kind]!(
      context,
      environment,
      expression,
    );
    context.popStackFrame();
    return result;
  }

  static Future<List<OutreValue>> evaluateExpressions(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final List<OutreExpression> expressions,
  ) async {
    final List<OutreValue> elements = <OutreValue>[];
    for (final OutreExpression x in expressions) {
      elements.add(await evaluateExpression(context, environment, x));
    }
    return elements;
  }

  static Future<OutreValue> evaluateAssignExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreAssignExpression casted = expression.cast();
    if (casted.left is OutreIndexAccessExpression) {
      return evaluateIndexAccessSetExpression(
        context,
        environment,
        casted.left.cast(),
        casted.right,
      );
    }
    final OutreIdentifierExpression name = casted.left.cast();
    final OutreValue value = await evaluateExpression(
      context,
      environment,
      casted.right,
    );
    environment.assign(name.value, value);
    return value;
  }

  static Future<OutreValue> evaluateIndexAccessSetExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreIndexAccessExpression left,
    final OutreExpression right,
  ) async {
    final OutreValue lValue = await evaluateExpression(
      context,
      environment,
      left.left,
    );
    final OutreValue iValue = await evaluateExpression(
      context,
      environment,
      left.index,
    );
    final OutreValue rValue = await evaluateExpression(
      context,
      environment,
      right,
    );
    lValue
        .getPropertyOfKey(OutreValueProperties.kIndexAccessSet)
        .cast<OutreFunctionValue>()
        .call(OutreFunctionValueCall(<OutreValue>[iValue, rValue]));
    return rValue;
  }

  static Future<OutreValue> evaluateDeclareExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreDeclareExpression casted = expression.cast();
    final OutreIdentifierExpression name = casted.left.cast();
    final OutreValue value = await evaluateExpression(
      context,
      environment,
      casted.right,
    );
    environment.declare(name.value, value);
    return value;
  }

  static Future<OutreValue> evaluateArrayExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreArrayExpression casted = expression.cast();
    final List<OutreValue> elements = await evaluateExpressions(
      context,
      environment,
      casted.elements,
    );
    return OutreArrayValue(elements);
  }

  static Future<OutreValue> evaluateGroupExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async =>
      evaluateExpression(
        context,
        environment,
        expression.cast<OutreGroupingExpression>().expression,
      );

  static Future<OutreValue> evaluateIdentifierExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreIdentifierExpression casted = expression.cast();
    return environment.get(casted.value);
  }

  static Future<OutreValue> evaluateStringExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreStringLiteralExpression casted = expression.cast();
    return OutreStringValue(casted.value);
  }

  static Future<OutreValue> evaluateNumberExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreNumberLiteralExpression casted = expression.cast();
    return OutreNumberValue(casted.value);
  }

  static Future<OutreValue> evaluateBooleanExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreBooleanLiteralExpression casted = expression.cast();
    return OutreBooleanValue(casted.value);
  }

  static Future<OutreValue> evaluateNullExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreNullLiteralExpression _ = expression.cast();
    return OutreNullValue();
  }

  static Future<OutreValue> evaluateObjectExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreObjectExpression casted = expression.cast();
    final Map<OutreValuePropertyKey, OutreValue> properties =
        <OutreValuePropertyKey, OutreValue>{};
    for (final OutreObjectExpressionProperty x in casted.properties) {
      final OutreValuePropertyKey key = OutreValue.getKeyFromOutreValue(
        await evaluateExpression(context, environment, x.key),
      );
      final OutreValue value =
          await evaluateExpression(context, environment, x.value);
      properties[key] = value;
    }
    return OutreObjectValue(properties);
  }

  static Future<OutreValue> evaluateCallExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreCallExpression casted = expression.cast();
    final OutreFunctionValue callee =
        await evaluateExpressionAndCast(context, environment, casted.callee);
    final List<OutreValue> arguments = await evaluateExpressions(
      context,
      environment,
      casted.arguments.arguments,
    );
    return callee.call(OutreFunctionValueCall(arguments));
  }

  static Future<OutreValue> evaluateFunctionExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreFunctionExpression casted = expression.cast();
    return OutreFunctionValue(
      (final OutreFunctionValueCall call) async {
        final OutreEnvironment nEnvironment = environment.wrap(
          frameName: '<${casted.keyword.type.code}>',
          isInsideFunction: true,
        );
        if (casted.hasParameters) {
          final List<OutreIdentifierExpression> parameters =
              casted.parameters!.parameters.cast();

          int i = 0;
          for (final OutreIdentifierExpression x in parameters) {
            nEnvironment.declare(x.value, call.argAt(i));
            i++;
          }
        }

        final OutreValue result =
            await OutreStatementEvaluator.evaluateStatement(
          context,
          nEnvironment,
          casted.body,
        );
        return result is OutreReturnValue ? result.value : OutreNullValue();
      },
    );
  }

  static Future<OutreValue> evaluateIndexAccessGetExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreIndexAccessExpression casted = expression.cast();
    final OutreValue left = await evaluateExpression(
      context,
      environment,
      casted.left,
    );
    final OutreValue right = await evaluateExpression(
      context,
      environment,
      casted.index,
    );
    return left
        .getPropertyOfKey(OutreValueProperties.kIndexAccessGet)
        .cast<OutreFunctionValue>()
        .call(OutreFunctionValueCall(<OutreValue>[right]));
  }

  static Future<OutreValue> evaluateMemberAccessExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreMemberAccessExpression casted = expression.cast();
    final OutreValue left = await evaluateExpression(
      context,
      environment,
      casted.left,
    );
    final OutreIdentifierExpression right = casted.right.cast();
    return left.getPropertyOfKey(right.value);
  }

  static Future<OutreValue> evaluateNullMemberAccessExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreNullMemberAccessExpression casted = expression.cast();
    final OutreValue left = await evaluateExpression(
      context,
      environment,
      casted.left,
    );
    if (left is OutreNullValue) {
      return OutreNullValue();
    }

    final OutreIdentifierExpression right = casted.right.cast();
    return left.getPropertyOfKey(right.value);
  }

  static final Map<OutreValuePropertyKey, OutreValuePropertyKey>
      unaryOperationProperties = <OutreTokens, OutreValuePropertyKey>{
    OutreTokens.plus: OutreValueProperties.kUnaryPlus,
    OutreTokens.minus: OutreValueProperties.kUnaryMinus,
    OutreTokens.bang: OutreValueProperties.kUnaryNegate,
    OutreTokens.tilde: OutreValueProperties.kBitwiseInvert,
  };

  static Future<OutreValue> evaluateUnaryExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreUnaryExpression casted = expression.cast();
    final OutreValue right =
        await evaluateExpression(context, environment, casted.right);
    return right
        .getPropertyOfKey(unaryOperationProperties[casted.operator.type])
        .cast<OutreFunctionValue>()
        .call(OutreFunctionValueCall.empty);
  }

  static final Map<OutreTokens, OutreValuePropertyKey>
      binaryOperationProperties = <OutreTokens, OutreValuePropertyKey>{
    OutreTokens.plus: OutreValueProperties.kAdd,
    OutreTokens.minus: OutreValueProperties.kSubtract,
    OutreTokens.asterisk: OutreValueProperties.kMultiply,
    OutreTokens.exponent: OutreValueProperties.kPow,
    OutreTokens.slash: OutreValueProperties.kDivide,
    OutreTokens.floor: OutreValueProperties.kFloorDivide,
    OutreTokens.modulo: OutreValueProperties.kModulo,
    OutreTokens.ampersand: OutreValueProperties.kBitwiseAnd,
    OutreTokens.logicalAnd: OutreValueProperties.kLogicalAnd,
    OutreTokens.pipe: OutreValueProperties.kBitwiseOr,
    OutreTokens.logicalOr: OutreValueProperties.kLogicalOr,
    OutreTokens.caret: OutreValueProperties.kBitwiseXor,
    OutreTokens.equal: OutreValueProperties.kLogicalEqual,
    OutreTokens.notEqual: OutreValueProperties.kLogicalNotEqual,
    OutreTokens.lesserThan: OutreValueProperties.kLesserThan,
    OutreTokens.lesserThanEqual: OutreValueProperties.kLesserThanEqual,
    OutreTokens.greaterThan: OutreValueProperties.kGreaterThan,
    OutreTokens.greaterThanEqual: OutreValueProperties.kGreaterThanEqual,
  };

  static final Map<OutreTokens, OutreExpressionEvaluatorCustomBinaryOperationFn>
      binaryCustomOperations =
      <OutreTokens, OutreExpressionEvaluatorCustomBinaryOperationFn>{
    OutreTokens.nullOr: evaluateNullOrExpression,
  };

  static Future<OutreValue> evaluateBinaryExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreBinaryExpression casted = expression.cast();
    if (binaryCustomOperations.containsKey(casted.operator.type)) {
      return binaryCustomOperations[casted.operator.type]!(
        context,
        environment,
        casted,
      );
    }

    final OutreValue left = await evaluateExpression(
      context,
      environment,
      casted.left,
    );
    final OutreValue right = await evaluateExpression(
      context,
      environment,
      casted.right,
    );
    return left
        .getPropertyOfKey(binaryOperationProperties[casted.operator.type])
        .cast<OutreFunctionValue>()
        .call(OutreFunctionValueCall(<OutreValue>[right]));
  }

  static Future<OutreValue> evaluateNullOrExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreBinaryExpression expression,
  ) async {
    final OutreValue left = await evaluateExpression(
      context,
      environment,
      expression.left,
    );
    if (left is! OutreNullValue) {
      return left;
    }

    return evaluateExpression(
      context,
      environment,
      expression.right,
    );
  }

  static Future<OutreValue> evaluateTernaryExpression(
    final OutreEvaluatorContext context,
    final OutreEnvironment environment,
    final OutreExpression expression,
  ) async {
    final OutreTernaryExpression casted = expression.cast();
    final OutreBooleanValue condition = await evaluateExpressionAndCast(
      context,
      environment,
      casted.condition,
    );

    return evaluateExpression(
      context,
      environment,
      condition.value ? casted.whenTrue : casted.whenFalse,
    );
  }
}