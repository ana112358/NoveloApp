import 'package:logger/logger.dart';

class LogService {
  static final LogService _instance = LogService._internal();

  factory LogService() {
    return _instance;
  }

  LogService._internal();

  // estilos
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // DEBUG - ícone: 🐛
  void d(String message) {
    _logger.d(message);
  }

  //  INFO - ícone: 💡
  void i(String message) {
    _logger.i(message);
  }

  //  WARNING - ícone: ⚠️ .
  void w(String message) {
    _logger.w(message);
  }

  //  ERROR - ícone: ⛔
  void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}
