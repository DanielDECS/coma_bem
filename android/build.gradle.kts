allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Eleva com segurança o compileSdk para 36 em todos os módulos/plugins Android (incluindo geocoding_android)
subprojects {
    plugins.withId("com.android.library") {
        (project.extensions.findByName("android") as? com.android.build.api.dsl.LibraryExtension)?.apply {
            compileSdk = 36
        }
    }
    plugins.withId("com.android.application") {
        (project.extensions.findByName("android") as? com.android.build.api.dsl.ApplicationExtension)?.apply {
            compileSdk = 36
        }
    }
}