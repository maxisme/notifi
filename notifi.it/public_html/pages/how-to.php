<!-- Highlight  -->
<link rel="stylesheet" href="css/highlight/railscasts.css">
<script src="js/highlight/highlight.pack.js"></script>
<script>hljs.initHighlightingOnLoad();</script>

<?php
// dynamic credentials
$credentials = !empty($_GET['c']) ? $_GET['c'] : "&lt;your_credentials&gt;";

$title = "Lorem ipsum dolor.";
$message = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
$link = "https://notifi.it";
$image = "https://notifi.it/images/logo.png";
?>

<h3>CURL</h3>
<pre>
    <code class="bash">
curl -d "credentials=<?php echo $credentials?>" \
-d "title=<?php echo $title?>" \
-d "message=<?php echo $message?>" \
-d "link=<?php echo $link?>" \
-d "image=<?php echo $image?>" \
https://notifi.it/api
    </code>
</pre>

<h3>Python</h3>
<pre>
    <code class="python">
import requests
data = {
  'credentials': '<?php echo $credentials?>',
  'title': '<?php echo $title?>',
  'message': '<?php echo $message?>',
  'link': '<?php echo $link?>',
  'image': '<?php echo $image?>'
}

requests.post(('https://notifi.it/api', data=data))
    </code>
</pre>

<h3>PHP</h3>
<pre>
    <code class="php">
curl_setopt_array(
  $chpush = curl_init(),
  array(
    CURLOPT_URL => "https://notifi.it/api",
    CURLOPT_POSTFIELDS => array(
      "credentials" => '<?php echo $credentials?>',
      "title" => '<?php echo $title?>',
      "message" => '<?php echo $message?>',
      "link" => '<?php echo $link?>',
      "image" => '<?php echo $image?>',
    )
  )
);
curl_exec($chpush);
curl_close($chpush);
    </code>
</pre>

