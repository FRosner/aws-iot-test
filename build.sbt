lazy val projectName = "aws-kinesis-consumer"

lazy val commonSettings = Seq(
  version := "0.1-SNAPSHOT",
  scalaVersion := "2.12.6",
  organization := "de.frosner",
  name := projectName,
  javacOptions ++= Seq("-source", "1.8", "-target", "1.8")
)

lazy val assemblySettings = Seq(
  artifact in (Compile, assembly) := {
    val art = (artifact in (Compile, assembly)).value
    art.withClassifier(Some("assembly"))
  },
  addArtifact(artifact in (Compile, assembly), assembly)
)

lazy val root = (project in file("kinesis-consumer"))
  .settings(commonSettings: _*)
  .settings(assemblySettings: _*)
  .settings(
    libraryDependencies ++= List(
      "com.amazonaws" % "aws-java-sdk-lambda" % "1.11.360",
      "com.amazonaws" % "aws-java-sdk-kinesis" % "1.11.360",
      "com.amazonaws" % "aws-lambda-java-core" % "1.2.0",
      "com.amazonaws" % "aws-lambda-java-events" % "2.2.2",
      "com.amazonaws" % "amazon-kinesis-client" % "1.9.1"
    ) ++ List(
      "io.circe" %% "circe-core",
      "io.circe" %% "circe-generic",
      "io.circe" %% "circe-parser").map(_ % "0.9.3")

  )