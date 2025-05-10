# Preserve the entire KaraokeMediaHelper class and all its members
-keep class com.itgsa.opensdk.mediaunit.KaraokeMediaHelper { *; }

# Preserve everything under the mediaunit package
-keep class com.itgsa.opensdk.mediaunit.** { *; }

# Preserve interfaces and other nested or reflective references
-keep interface com.itgsa.opensdk.** { *; }
-dontwarn com.itgsa.opensdk.**

-keep class im.zego.** { *; }
-dontwarn im.zego.**
