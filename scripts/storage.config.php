<?php
    $CONFIG = array (
        "objectstore" => array(
            "class" => "OC\\Files\\ObjectStore\\S3",
            "arguments" => array(
                "bucket" => "${bucket_name}",
                "key" => "${s3_key}",
                "secret" => "${s3_secret}",
                "use_ssl" => true,
                "region" => "${region}"
            ),
        ),
    );