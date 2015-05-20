# Thesis-files
All resources used in my M.Sc thesis experiments

For setup_hadoop.sh:

1) setup_hadoop.sh, upload_and_start_hadoop.sh, poutakey.pem have to be in the same folder.
2) Set the driver script (upload_and_start_hadoop.sh) as executable by the command 
	chmod +x upload_and_start_hadoop.sh

  or,
        chmod 0777 upload_and_start_hadoop.sh
3) After the installation, type "start-dfs.sh" to start hadoop

For setup_tachyon.sh:

1) As before, poutakey.pem, setup_tachyon.sh and upload_and_start_tachyon.sh have to be in the same folder.
2) Same as with hadoop.
3) After the installation, type the following commands to start tachyon:

	- cd tachyon-0.5.0/bin
	- ./tachyon-start.sh all SudoMount 


Run teragen with Spark:

/home/cloud-user/spark-1.1.0/bin/spark-submit --class org.apache.spark.examples.terasort.GenSort --master spark://master-full:7077 /home/cloud-user/terasort/target/scala-2.10/simple-project_2.10-1.0.jar 1 10 hdfs://master-full:54310/tera-output

Run count job with Spark:

>> cd $HOME/SparkWordCount
>> /home/cloud-user/spark-1.1.0/bin/spark-submit --class SimpleApp --master spark://master-full:7077 /home/cloud-user/SparkWordCount/target/scala-2.10/simple-project_2.10-1.0.jar


