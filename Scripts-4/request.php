<?php

require '/home/ubuntu/vendor/autoload.php';

$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$job = $_POST['job'];
$imagename =$_FILES['pic']['name'];
$tmp_name =$_FILES['pic']['tmp_name'];

$extension = explode('.', $imagename);
$extension = strtolower(end($extension));

$key = md5(uniqid());
$tmp_file_name = "{$key}.{$extension}";
$tmp_file_path = "/var/www/html/{$tmp_file_name}";

move_uploaded_file($tmp_name, $tmp_file_path);

echo "Your name is ".$name."\n";
echo "Your email is ".$email."\n";
echo "Your phone is ".$phone."\n";
echo "Your image name is ".$imagename."\n";


$sqs = new Aws\Sqs\SqsClient([
    'version' => 'latest',
    'region'  => 'us-east-2'
]);

#list the SQS Queue URL
$listQueueresult = $sqs->listQueues([
    
]);
# print out every thing
# print_r ($listQueueresult);  
echo "Your SQS URL is: " . $listQueueresult['QueueUrls'][0]."\n";
$queueurl = $listQueueresult['QueueUrls'][0];

$message = $job;
### send message to the SQS Queue
$sendmessageresult = $sqs->sendMessage([
    'DelaySeconds' => 10,
    'MessageBody' => $message, // REQUIREDi
    'QueueUrl' => $queueurl // REQUIRED
]);
echo "The messageID is: ". $sendmessageresult['MessageId']."\n";

$s3 = new Aws\S3\S3Client([
     'version' => 'latest',
     'region' => 'us-east-1'
 ]);

 $bucket = $s3->listBuckets([
 
]);
 
 echo "Your bucket is " . $bucket['Buckets'][0]['Name'] ."\n";
 $bucketlocation = $bucket['Buckets'][0]['Name'];

 $sendobjectresult = $s3->putObject([
     'Bucket' => $bucketlocation,
     'ACL' => 'public-read',
     'Key' => $imagename,
     'Body' => $imagename
 ]);
 
 echo "The object url is is: ". $sendobjectresult['ObjectURL']."\n";

 unlink($tmp_file_path);

?>