gradle.startParameter.excludedTaskNames += "licenseMain"
gradle.startParameter.excludedTaskNames += "licenseTest"

plugins {
    application
    kotlin("jvm") version "1.2.61"
    id ("com.github.hierynomus.license") version "0.15.0"
}

application {
    mainClassName = "hello.HelloWorldKt"
}

dependencies {
    compile(kotlin("stdlib"))
    testCompile ("junit:junit:4.11")
    compile("org.springframework:spring-jdbc:5.0.7.RELEASE")
    compile("org.postgresql:postgresql:42.2.2")
}

repositories {
    jcenter()
}

tasks.withType<Wrapper> {
    gradleVersion = "4.10.2"
}