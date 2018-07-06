lazy val commonSettings = Seq(
  version := "0.1-SNAPSHOT",
  scalaVersion := "2.12.6",
  organization := "de.frosner",
  javacOptions ++= Seq("-source", "1.8", "-target", "1.8")
)

lazy val assemblySettings = Seq(
  artifact in (Compile, assembly) := {
    val art = (artifact in (Compile, assembly)).value
    art.withClassifier(Some("assembly"))
  },
  addArtifact(artifact in (Compile, assembly), assembly)
)

lazy val kinesis = (project in file("kinesis-consumer"))
  .settings(commonSettings: _*)
  .settings(assemblySettings: _*)
  .settings(
    name := "aws-kinesis-consumer",
    libraryDependencies ++= List(
      "com.amazonaws" % "aws-java-sdk-lambda" % "1.11.360",
      "com.amazonaws" % "aws-java-sdk-kinesis" % "1.11.360",
      "com.amazonaws" % "aws-lambda-java-core" % "1.2.0",
      "com.amazonaws" % "aws-lambda-java-events" % "2.2.2",
      "com.amazonaws" % "amazon-kinesis-client" % "1.9.1",
      "net.debasishg" %% "redisclient" % "3.7"
    ) ++ List(
      "io.circe" %% "circe-core",
      "io.circe" %% "circe-generic",
      "io.circe" %% "circe-parser").map(_ % "0.9.3")

  )

lazy val webui = (project in file("webui"))
  .settings(commonSettings: _*)
  .settings(assemblySettings: _*)
  .settings(
    name := "aws-realtime-webui",
    publishTo := Some("S3" at s"s3://s3-eu-central-1.amazonaws.com/awsrealtimeseries-webui-artifacts"),
    mainClass in assembly := Some("de.frosner.aws.iot.Main"),
    libraryDependencies ++= List(
      "com.typesafe.akka" %% "akka-actor" % "2.5.12",
      "com.typesafe.akka" %% "akka-stream" % "2.5.11",
      "com.typesafe.akka" %% "akka-http" % "10.1.1",
      "net.debasishg" %% "redisclient" % "3.7"
    )
  )
