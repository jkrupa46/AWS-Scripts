<?php
//conection: 

require '/home/ubuntu/vendor/autoload.php';

use Aws\Rds\RdsClient;

$rds = new Aws\Rds\RdsClient([
     'version' => 'latest',
     'region' => 'us-east-2'
 ]);

//https://docs.aws.amazon.com/aws-sdk-php/v3/api/api-rds-2014-10-31.html#describedbinstances
$result = $rds->describeDBInstances([
    'DBInstanceIdentifier' => 'itmo-444'
]);

echo "Here is the Address: ". "\n";
$rdsIP = $result['DBInstances'][0]['Endpoint']['Address'];
echo $rdsIP;

echo "Hello world"; 
$mysqli = mysqli_connect($rdsIP,"controller","ilovebunnies","dataserver") or die("Error " . mysqli_error($link));

//echo "Here is the result: " . $link;
// http://php.net/manual/en/mysqli.query.php

$sql = "CREATE TABLE comments 
(
ID INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
PosterName VARCHAR(32),
Title VARCHAR(32),
Content VARCHAR(500)
)";

if ($mysqli->query($sql)) {
    printf("Table comments successfully created.\n");
}
$mysqli->close();
?>
