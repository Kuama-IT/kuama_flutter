import 'dart:async';

import 'package:kuama_flutter/kuama_flutter.dart';

Tuple2<I1, I2> tuple2<I1, I2>(I1 item1, I2 item2) => Tuple2(item1, item2);

Tuple3<I1, I2, I3> tuple3<I1, I2, I3>(I1 item1, I2 item2, I3 item3) => Tuple3(item1, item2, item3);

Tuple4<I1, I2, I3, I4> tuple4<I1, I2, I3, I4>(I1 item1, I2 item2, I3 item3, I4 item4) =>
    Tuple4(item1, item2, item3, item4);

Tuple5<I1, I2, I3, I4, I5> tuple5<I1, I2, I3, I4, I5>(
        I1 item1, I2 item2, I3 item3, I4 item4, I5 item5) =>
    Tuple5(item1, item2, item3, item4, item5);

extension Tuple2FutureKuamaExtension<I1, I2> on Tuple2<FutureOr<I1>, FutureOr<I2>> {
  Future<Tuple2<I1, I2>> get done async => Tuple2(await value1, await value2);
}

extension Tuple3FutureKuamaExtension<I1, I2, I3>
    on Tuple3<FutureOr<I1>, FutureOr<I2>, FutureOr<I3>> {
  Future<Tuple3<I1, I2, I3>> get done async => Tuple3(await value1, await value2, await value3);
}

extension Tuple4FutureKuamaExtension<I1, I2, I3, I4>
    on Tuple4<FutureOr<I1>, FutureOr<I2>, FutureOr<I3>, FutureOr<I4>> {
  Future<Tuple4<I1, I2, I3, I4>> get done async =>
      Tuple4(await item1, await item2, await item3, await item4);
}

extension Tuple5FutureKuamaExtension<I1, I2, I3, I4, I5>
    on Tuple5<FutureOr<I1>, FutureOr<I2>, FutureOr<I3>, FutureOr<I4>, FutureOr<I5>> {
  Future<Tuple5<I1, I2, I3, I4, I5>> get done async =>
      Tuple5(await item1, await item2, await item3, await item4, await item5);
}

extension Tuple2KuamaExtension<I1, I2> on Tuple2<I1, I2> {
  I1 get value1 => item1;
  I2 get value2 => item2;
}

extension Tuple3KuamaExtension<I1, I2, I3> on Tuple3<I1, I2, I3> {
  I1 get value1 => item1;
  I2 get value2 => item2;
  I3 get value3 => item3;
}
