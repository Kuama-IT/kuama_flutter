import 'dart:convert';

import 'package:kuama_flutter/src/shared/utils/logger.dart';

final lg = Logger('kuama.Flutter');

final prettyJson = JsonEncoder.withIndent(' ', (o) => '$o');
