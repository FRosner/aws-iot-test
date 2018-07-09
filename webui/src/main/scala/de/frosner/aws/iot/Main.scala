package de.frosner.aws.iot

import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.http.scaladsl.model.ws.TextMessage
import akka.http.scaladsl.server.Directives._
import akka.stream.scaladsl.{BroadcastHub, Keep, Sink, Source}
import akka.stream.{ActorMaterializer, OverflowStrategy}
import com.redis.{M, RedisClient, S}

import scala.util.{Failure, Success, Try}

object Main extends App {

  implicit val system = ActorSystem("my-system")
  implicit val materializer = ActorMaterializer()
  implicit val executionContext = system.dispatcher

  System.getenv().forEach((x, y) => println(s"$x=$y"))

  private val redis_port = System.getenv("redis_port").toInt
  private val redis_url = System.getenv("redis_url")
  println(s"Connecting to Redis at $redis_url:$redis_port")
  private val redis = new RedisClient(redis_url, redis_port)
  private val redisPubSub = new RedisClient(redis_url, redis_port)

  // https://stackoverflow.com/questions/49028905/whats-the-simplest-way-to-use-sse-with-redis-pub-sub-and-akka-streams
  val (redisActor, redisSource) =
    Source.actorRef[String](1000, OverflowStrategy.dropTail)
      .map(s => TextMessage(s))
      .toMat(BroadcastHub.sink[TextMessage])(Keep.both)
      .run()

  redisPubSub.subscribe("sensors") {
    case M(channel, message) =>
      println(s"Received message '$message'")
      val latest = redis.get("sensorLatest")
      val count = redis.get("sensorCount")
      redisActor ! s"""{ "latest": "${latest.getOrElse("0")}", "count": "${count.getOrElse("0")}" }"""
    case S(channel, noSubscribed) => println(s"Successfully subscribed to channel $channel")
    case other => println(s"Ignoring message from redis: $other")
  }

  val route =
    path("ws") {
      extractUpgradeToWebSocket { upgrade =>
        complete(upgrade.handleMessagesWithSinkSource(Sink.ignore, redisSource))
      }
    } ~ path("") {
      getFromResource("index.html")
    }

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
