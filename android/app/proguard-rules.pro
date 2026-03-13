# Add project specific ProGuard rules here.
# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Mobile scanner
-keep class dev.steenbakker.mobile_scanner.** { *; }
