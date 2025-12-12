#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint duckdb.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'dart_duckdb'
  s.version          = File.read(File.join('..', 'pubspec.yaml')).match(/version:\s+(\d+\.\d+\.\d+)/)[1]
  s.summary          = 'DuckDB embedded database for Flutter iOS.'
  s.description      = <<-DESC
DuckDB is an in-process SQL OLAP database management system.
This plugin provides DuckDB support for Flutter iOS apps.
                        DESC
  s.homepage         = 'https://github.com/yharby/duckdb-dart'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DuckDB Dart Contributors' => 'github@duckdb.org' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'

  s.platform = :ios, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  # Use XCFramework for both device and simulator support
  s.ios.vendored_frameworks = 'Libraries/release/duckdb.xcframework'

  # Downloads pre-built iOS XCFramework from GitHub releases
  # The XCFramework contains both device (arm64) and simulator (arm64 + x86_64) architectures
  # Built automatically via GitHub Actions when new DuckDB versions are released
  s.prepare_command = <<-CMD
    mkdir -p Libraries/release

    if [ ! -d "Libraries/release/duckdb.xcframework" ]; then
      echo "Downloading DuckDB iOS XCFramework..."

      # Try to get latest iOS release, fallback to known working version
      RELEASE_URL=$(curl -s https://api.github.com/repos/yharby/duckdb-dart/releases | \
        grep -o 'https://github.com/yharby/duckdb-dart/releases/download/[^"]*ios[^"]*/duckdb-xcframework-ios.zip' | \
        head -1)

      if [ -z "$RELEASE_URL" ]; then
        echo "Could not find latest iOS release, using fallback..."
        RELEASE_URL="https://github.com/yharby/duckdb-dart/releases/download/v1.4.3-ios/duckdb-xcframework-ios.zip"
      fi

      echo "Downloading from: $RELEASE_URL"
      curl -L -o duckdb-xcframework-ios.zip "$RELEASE_URL"

      # Verify download succeeded (file should be > 10MB for XCFramework)
      FILE_SIZE=$(stat -f%z duckdb-xcframework-ios.zip 2>/dev/null || stat -c%s duckdb-xcframework-ios.zip 2>/dev/null || echo "0")
      if [ "$FILE_SIZE" -lt 10000000 ]; then
        echo "ERROR: Downloaded file is too small ($FILE_SIZE bytes), download may have failed"
        cat duckdb-xcframework-ios.zip
        exit 1
      fi

      unzip -o duckdb-xcframework-ios.zip -d Libraries/release/
      rm duckdb-xcframework-ios.zip
      echo "DuckDB iOS XCFramework installed successfully"
    else
      echo "DuckDB iOS XCFramework already exists."
    fi
  CMD
end
