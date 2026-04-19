# Flutter Connectivity Plugin
-keep class dev.fluttercommunity.plus.connectivity.ConnectivityPlugin { *; }

# Keep Flutter plugin classes
-keep class io.flutter.plugins.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
