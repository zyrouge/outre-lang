import '../errors/exports.dart';
import 'exports.dart';

abstract class FubukiValue {
  FubukiValueKind get kind;

  String kToString();
  bool kEquals(final FubukiValue other) => other.kHashCode == kHashCode;

  T cast<T extends FubukiValue>() {
    if (T == FubukiValue) return this as T;
    if (T == FubukiPrimitiveObjectValue && this is FubukiPrimitiveObjectValue) {
      return this as T;
    }
    final FubukiValueKind to = getKindFromType(T);
    if (kind == to) return this as T;
    throw FubukiRuntimeExpection.cannotCastTo(to, kind);
  }

  bool get isTruthy;
  bool get isFalsey => !isTruthy;
  int get kHashCode;

  static final Map<Type, FubukiValueKind> _typeKindMap =
      <Type, FubukiValueKind>{
    FubukiBooleanValue: FubukiValueKind.boolean,
    FubukiFunctionValue: FubukiValueKind.function,
    FubukiListValue: FubukiValueKind.list,
    FubukiNativeFunctionValue: FubukiValueKind.nativeFunction,
    FubukiNullValue: FubukiValueKind.nullValue,
    FubukiNumberValue: FubukiValueKind.number,
    FubukiObjectValue: FubukiValueKind.object,
    FubukiStringValue: FubukiValueKind.string,
  };

  static FubukiValueKind getKindFromType(final Type type) =>
      _typeKindMap[type]!;
}