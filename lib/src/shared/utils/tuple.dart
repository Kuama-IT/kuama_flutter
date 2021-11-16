import 'dart:async';

import 'package:kuama_flutter/kuama_flutter.dart';

Tuple2<I1, I2> tuple2<I1, I2>(I1 item1, I2 item2) => Tuple2(item1, item2);

Tuple3<I1, I2, I3> tuple3<I1, I2, I3>(I1 item1, I2 item2, I3 item3) => Tuple3(item1, item2, item3);

Tuple4<I1, I2, I3, I4> tuple4<I1, I2, I3, I4>(I1 item1, I2 item2, I3 item3, I4 item4) =>
    Tuple4(item1, item2, item3, item4);

Tuple5<I1, I2, I3, I4, I5> tuple5<I1, I2, I3, I4, I5>(
        I1 item1, I2 item2, I3 item3, I4 item4, I5 item5) =>
    Tuple5(item1, item2, item3, item4, item5);

extension Tuple2FutureExtension<V1, V2> on Tuple2<FutureOr<V1>, FutureOr<V2>> {
  Future<Tuple2<V1, V2>> get done async => Tuple2(await value1, await value2);
}

extension Tuple3FutureExtension<V1, V2, V3> on Tuple3<FutureOr<V1>, FutureOr<V2>, FutureOr<V3>> {
  Future<Tuple3<V1, V2, V3>> get done async => Tuple3(await value1, await value2, await value3);
}

extension Tuple2AppExtension<I1, I2> on Tuple2<I1, I2> {
  I1 get value1 => item1;
  I2 get value2 => item2;
}

extension Tuple3AppExtension<I1, I2, I3> on Tuple3<I1, I2, I3> {
  I1 get value1 => item1;
  I2 get value2 => item2;
  I3 get value3 => item3;
}
