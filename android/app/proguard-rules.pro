# Keep Java collection interfaces and implementations
-keep class java.util.** { *; }
-keep interface java.util.** { *; }
-dontwarn java.util.**

# Keep specific problematic classes mentioned in the error
-keep class java.util.ArrayList { *; }
-keep class java.util.AbstractList { *; }
-keep class java.util.HashMap { *; }
-keep class java.util.Map { *; }
-keep class java.util.List { *; }
-keep class java.util.Collection { *; }
-keep class java.nio.file.** { *; }