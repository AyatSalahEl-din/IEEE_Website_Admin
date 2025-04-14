allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// Ensure the NDK path is valid or remove the dependency if not required
subprojects {
    val ndkDir = file("${System.getenv("ANDROID_HOME")}/ndk-bundle")
    val ndkSourceProperties = ndkDir.resolve("source.properties")
    if (ndkDir.exists() && ndkSourceProperties.exists()) {
        project.evaluationDependsOn(":app")
    } else {
        logger.warn("NDK is missing or invalid. Skipping evaluationDependsOn for ':app'.")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
