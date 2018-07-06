package de.frosner.aws.iot

import java.util.{Date, UUID}

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.KinesisEvent

import scala.collection.JavaConverters._
import com.redis._

class Handler extends RequestHandler[KinesisEvent, Void] {

  private val port = System.getenv("redis_port").toInt
  private val url = System.getenv("redis_url")
  require(port != null && url != null, "Invalid redis endpoint (format $redis_url:$redis_port): '" + s"$url:$port" + "'")

  override def handleRequest(input: KinesisEvent, context: Context): Void = {
    val logger = context.getLogger
    logger.log(s"Connecting to redis at $url:$port")
    val redis = new RedisClient(url, port)
    val recordsWritten = input.getRecords.asScala.map { record =>
      logger.log(record.toString)
      val data = new String(record.getKinesis.getData.array())
      logger.log(s"data: $data")
      val uuid = UUID.randomUUID()
      redis.set(
        key = s"${System.currentTimeMillis()}-$uuid",
        value = data
      )
    }
    val successAndFailure = recordsWritten.groupBy(identity).mapValues(_.length)
    logger.log(s"Successful writes: ${successAndFailure.getOrElse(true, 0)}")
    logger.log(s"Failed writes: ${successAndFailure.getOrElse(false, 0)}")
    null
  }

}