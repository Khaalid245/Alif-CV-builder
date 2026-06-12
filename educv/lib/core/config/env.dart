import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: 'assets/env/.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'API_BASE_URL', defaultValue: 'http://localhost:8000/api/v1')
  static final String apiBaseUrl = _Env.apiBaseUrl;

  @EnviedField(varName: 'APP_NAME', defaultValue: 'EduCV')
  static final String appName = _Env.appName;

  @EnviedField(varName: 'APP_VERSION', defaultValue: '1.0.0')
  static final String appVersion = _Env.appVersion;

  @EnviedField(varName: 'ENVIRONMENT', defaultValue: 'development')
  static final String environment = _Env.environment;
}
