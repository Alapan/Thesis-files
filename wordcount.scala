import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.hadoop.io.{LongWritable, NullWritable}
import org.apache.spark.SparkConf
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat

object SimpleApp {

	def main(args: Array[String]) {
		val conf = new SparkConf().setAppName("SimpleApp")
    		val sc = new SparkContext(conf)
		val file = sc.textFile("hdfs://master-full:54310/tera-output")
		//val file = sc.textFile("tachyon://master-full:19998/tera-output")
		//val file = sc.textFile("s3n://test/tera-output")
		val splits = file.map(word => word.toLong)
		splits.map(row => (NullWritable.get(), new LongWritable(row))).saveAsNewAPIHadoopFile("hdfs://master-full:54310/output/",classOf[NullWritable],classOf[LongWritable],classOf[TextOutputFormat[NullWritable,LongWritable]])
  	}
}
