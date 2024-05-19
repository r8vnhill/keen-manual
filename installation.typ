
= Installation

This section guides you through the process of setting up the Keen framework and the EvolutionPlotter in your Kotlin project using Gradle Kotlin DSL.

== Gradle Kotlin DSL Setup

=== Step 1: Specify Versions if `gradle.properties`

First, define the versions of Keen and Compose in your `gradle.properties` file.
Make sure to replace these with the latest versions available.

```kotlin
// gradle.propertis
// Keen framework version. Replace with the latest version.
keen.version=1.1.0
// Compose version for the EvolutionPlotter. Replace at your discretion.
compose.version=1.5.11
```

=== Step 2: Configure Plugin Management in `settings.gradle.kts`

This step is essential only if you plan to use the EvolutionPlotter. Here, you configure the plugin management for the
Compose plugin.

```kotlin
// settings.gradle.kts
pluginManagement {
    repositories {
        // Standard Gradle plugin repository.
        gradlePluginPortal()
        // Repository for JetBrains Compose.
        maven("https://maven.pkg.jetbrains.space/public/p/compose/dev")
        // Google's Maven repository, sometimes needed for dependencies.
        google()
    }

    plugins {
        // Apply the Compose plugin with the specified version.
        id("org.jetbrains.compose") version extra["compose.version"] as String
    }
}
```

=== Step 3: Configure Project Plugins, Repositories, and Dependencies
In your build script, configure the necessary plugins, repositories, and dependencies.

```kotlin
// Retrieve the Keen version defined earlier.
val keenVersion: String by extra["keen.version"] as String

plugins {
    /* ... */
    // Include this only if using the EvolutionPlotter.
    id("org.jetbrains.compose")
}

repositories {
    // Maven Central repository for most dependencies.
    mavenCentral()
    /* ... */
}

dependencies {
    // Keen core library dependency.
    implementation("cl.ravenhill:keen-core:$keenVersion")
    // Compose dependency, required for the EvolutionPlotter.
    implementation(compose.desktop.currentOs)
    /* ... */
}
```

== Additional Notes:

- Ensure that the versions specified in `gradle.properties` are compatible with your project setup.
- The `pluginManagement` block in `settings.gradle.kts` is crucial for resolving the Compose plugin, especially if you're using features like the EvolutionPlotter.
- Remember to sync your Gradle project after making changes to these files to apply the configurations.