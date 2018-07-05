package de.frosner.aws.iot

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.services.lambda.runtime.events.KinesisEvent
import scala.collection.JavaConverters._

class Handler extends RequestHandler[KinesisEvent, Void] {

  override def handleRequest(input: KinesisEvent, context: Context): Void = {
    val logger = context.getLogger
    for {
      record <- input.getRecords.asScala
    } {
      logger.log(record.toString)
      logger.log(s"data: ${new String(record.getKinesis.getData.array())}")
    }
    null
  }

}