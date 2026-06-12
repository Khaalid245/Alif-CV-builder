import re

with open('lib/core/config/app_config.dart', 'r') as f:
    content = f.read()

# Replace dotenv import
content = content.replace("import 'package:flutter_dotenv/flutter_dotenv.dart';", "import 'env.dart';")

# Replace Env.apiBaseUrl, appName, appVersion, environment
content = content.replace("dotenv.env['API_BASE_URL']", "Env.apiBaseUrl")
content = content.replace("dotenv.env['ENVIRONMENT'] ?? 'development'", "Env.environment")
content = content.replace("dotenv.env['APP_NAME'] ?? 'EduCV'", "Env.appName")
content = content.replace("dotenv.env['APP_VERSION'] ?? '1.0.0'", "Env.appVersion")

# Regex to strip other dotenv calls
# pattern: int.tryParse(dotenv.env['KEY'] ?? '') ?? VALUE
content = re.sub(r"int\.tryParse\(dotenv\.env\['[^']+'] \?\? ''\) \?\? (\d+)", r"\1", content)

# pattern: dotenv.env['KEY'] ?? 'VALUE'
content = re.sub(r"dotenv\.env\['[^']+'] \?\? ('[^']+')", r"\1", content)

# pattern: (dotenv.env['KEY'] ?? 'VALUE').split(',')
content = content.replace("('jpg,jpeg,png,webp')", "'jpg,jpeg,png,webp'")
content = content.replace("('classic,modern,academic')", "'classic,modern,academic'")

# pattern for boolean: (dotenv.env['KEY'] ?? 'false').toLowerCase() == 'true'
content = re.sub(r"\(dotenv\.env\['[^']+'] \?\? ('(?:true|false)')\)\.toLowerCase\(\) == 'true'", r"\1 == 'true'", content)

# Remove initialize method body
init_replacement = """  static Future<void> initialize() async {
    try {
      validateScoringWeights();
      
      if (enableDebugLogging) {
        print('AppConfig initialized successfully');
        print('Configuration summary: ${getConfigSummary()}');
      }
    } catch (e) {
      print('AppConfig initialization error: $e');
      rethrow;
    }
  }"""
content = re.sub(r"  static Future<void> initialize\(\) async \{.*?\n  \}", init_replacement, content, flags=re.DOTALL)

with open('lib/core/config/app_config.dart', 'w') as f:
    f.write(content)

with open('lib/main.dart', 'r') as f:
    main_content = f.read()

main_content = main_content.replace("import 'package:flutter_dotenv/flutter_dotenv.dart';\n", "")
main_content = re.sub(r"  // Load local development config.*?catch \(e\) \{\n    debugPrint\('Error loading \.env file: \$e'\);\n  \}\n", "", main_content, flags=re.DOTALL)

with open('lib/main.dart', 'w') as f:
    f.write(main_content)
