package de.frosner.aws.iot

import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.ws.{BinaryMessage, Message, TextMessage}
import akka.http.scaladsl.server.Directives._
import akka.stream.ActorMaterializer
import akka.stream.scaladsl.{Flow, Sink, Source}
import com.typesafe.config.ConfigFactory

import scala.util.{Failure, Success, Try}

object Main extends App {

  implicit val system = ActorSystem("my-system")
  implicit val materializer = ActorMaterializer()
  // needed for the future flatMap/onComplete in the end
  implicit val executionContext = system.dispatcher

  val handler: Flow[Message, Message, Any] =
    Flow[Message].mapConcat {
      case tm: TextMessage =>
        TextMessage(Source.single("Hello ") ++ tm.textStream ++ Source.single("!")) :: Nil
      case bm: BinaryMessage =>
        // ignore binary messages but drain content to avoid the stream being clogged
        bm.dataStream.runWith(Sink.ignore)
        Nil
    }

  val route =
    path("ws") {
      handleWebSocketMessages(handler)
    }

  val config = ConfigFactory.load()
  val interface = Option(System.getenv("INTERFACE")).getOrElse("0.0.0.0")
  val port = Try(System.getenv("PORT").toInt) match {
    case Success(i) => i
    case Failure(t) =>
      println("Failed to read $PORT: " + t)
      println(s"Using default port: 80")
      80
  }
  val bindingFuture = Http().bindAndHandle(route, interface, port)
  println(s"Server online at http://$interface:$port/")

}
