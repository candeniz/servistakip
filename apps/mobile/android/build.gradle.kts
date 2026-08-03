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

// Bazı eklentiler (ör. file_picker) eski compileSdk (34) ile derleniyor;
// tüm Android modüllerini 36'ya çekerek AAR metadata uyumsuzluğunu önle.
// AGP tipi kök script classpath'inde olmadığından reflection kullanılır.
subprojects {
    // :app zaten compileSdk=36 ve erken değerlendirildiği için atlanır;
    // yalnızca eklenti modülleri (henüz değerlendirilmemiş) için afterEvaluate kaydet.
    if (name != "app") {
        afterEvaluate {
            val androidExt = extensions.findByName("android") ?: return@afterEvaluate
            try {
                androidExt.javaClass
                    .getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(androidExt, 36)
            } catch (_: Exception) {
                // Android eklentisi olmayan modülleri yok say.
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
