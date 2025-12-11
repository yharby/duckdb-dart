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

  s.ios.vendored_framework = 'Libraries/release/duckdb.framework'

  # Downloads pre-built iOS framework from GitHub releases
  # The framework is built automatically via GitHub Actions when new DuckDB versions are released
  # Falls back to v1.4.4-ios-fix if latest release lookup fails
  s.prepare_command = <<-CMD
    mkdir -p Libraries/release

    if [ ! -d "Libraries/release/duckdb.framework" ]; then
      echo "Downloading DuckDB iOS framework..."

      # Try to get latest iOS release, fallback to known working version
      RELEASE_URL=$(curl -s https://api.github.com/repos/yharby/duckdb-dart/releases | \
        grep -o 'https://github.com/yharby/duckdb-dart/releases/download/[^"]*ios[^"]*/duckdb-framework-ios.zip' | \
        head -1)

      if [ -z "$RELEASE_URL" ]; then
        echo "Could not find latest iOS release, using fallback..."
        RELEASE_URL="https://github.com/yharby/duckdb-dart/releases/download/v1.4.3-ios/duckdb-framework-ios.zip"
      fi

      echo "Downloading from: $RELEASE_URL"
      curl -L -o duckdb-framework-ios.zip "$RELEASE_URL"

      # Verify download succeeded (file should be > 1MB)
      FILE_SIZE=$(stat -f%z duckdb-framework-ios.zip 2>/dev/null || stat -c%s duckdb-framework-ios.zip 2>/dev/null || echo "0")
      if [ "$FILE_SIZE" -lt 1000000 ]; then
        echo "ERROR: Downloaded file is too small ($FILE_SIZE bytes), download may have failed"
        cat duckdb-framework-ios.zip
        exit 1
      fi

      unzip -o duckdb-framework-ios.zip -d Libraries/release/
      rm duckdb-framework-ios.zip
      echo "DuckDB iOS framework installed successfully"
    else
      echo "DuckDB iOS framework already exists."
    fi
  CMD
end
