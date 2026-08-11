plugins { id("org.jetbrains.kotlin.jvm") }

kotlin { jvmToolchain(17) }

dependencies {
  testImplementation("org.jetbrains.kotlin:kotlin-test-junit:2.3.21")
}

tasks.test { useJUnit() }
