<?php
session_start();
$title = "notifi";
$meta_description = "A minimal api notification app for your Mac";
$meta_keywords = "OSX, Mac, Notify, Notifi, notifi, notification, app, api, curl, http, request";

?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<head>
    <!-- tab icons - https://realfavicongenerator.net/ -->
    <link rel="apple-touch-icon" sizes="180x180" href="/favicons/apple-touch-icon.png">
    <link rel="icon" type="image/png" href="/favicons/favicon-32x32.png" sizes="32x32">
    <link rel="icon" type="image/png" href="/favicons/favicon-16x16.png" sizes="16x16">
    <link rel="manifest" href="/favicons/manifest.json">
    <link rel="mask-icon" href="/favicons/safari-pinned-tab.svg" color="#5bbad5">
    <link rel="shortcut icon" href="/favicons/favicon.ico">
    <meta name="msapplication-config" content="/favicons/browserconfig.xml">
    <meta name="theme-color" content="#ffffff">
    <meta name="og:image" content="https://notifi.it/logo.png"/>
    <!-- meta stuff -->
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="description" content="<?php echo $meta_description ?>">
    <meta name="keywords" content="<?php echo $meta_keywords ?>">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>
    <!-- google fonts -->
    <link href='https://fonts.googleapis.com/css?family=Muli' rel='stylesheet' type='text/css'>
    <link href='https://fonts.googleapis.com/css?family=Montserrat' rel='stylesheet' type='text/css'>
    <!-- google recaptcha -->
    <script src='https://www.google.com/recaptcha/api.js'></script>
    <!-- jquery -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
    <!-- maxis.me css -->
    <link rel="stylesheet" type="text/css" href="https://maxis.me/template/css/style.css"/>
    <!-- maxis.me scripts -->
    <script type="text/javascript" src="https://maxis.me/template/scripts/jquery.easing.min.js"></script>
    <script type="text/javascript" src="https://maxis.me/template/scripts/script.js"></script>

    <title><?php echo $title ?></title>
</head>

<body>
<!-- HOME -->
<page>
    <div align="center">
        <br/><br/><img height="350" src="logo.png"><br/><br/><br/>
        <h1>notifi</h1>
        <div id="navMenu">
            <a class="page-scroll" href="#howitworks">How It Works</a> | <a class="page-scroll" href="#contact">Contact</a> | <a class="page-scroll" href="#tsandcs">Ts & Cs</a>
        </div>
        <br/><br/><br/>
        <a id="down" href="download">download</a><br/><br/>
    </div>
</page>

<!-- HOW IT WORKS -->
<page id="howitworks">
    <h2>How It Works</h2>
    <div>
        <p class="info">
            notifi is a <strong>FREE</strong>, minimal <strong>Push Notification app</strong> that sits in your menu bar
            on your Mac. When opening the app for the first time you are given <i>credentials</i> these are used to
            uniquely identify you.
        </p>
        <p>
            <img style="zoom:98.6%" src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Menubar.png">
        </p>
        <p class="info">
            With this key you can send <a target="_blank"
                                          href="https://github.com/maxisme/notifi#http-request-examples">HTTP requests
                (curl)</a> to receive notifications on your mac.
        </p>
        <p>
            <img style="zoom:98.6%" src="https://github.com/maxisme/notifi/raw/master/Screen%20Shots/Window.png">
        </p>
        <h3>Okay I have downloaded it. Now what?</h3>
        <p class="info">
            First click on notifi which will appear on your menu bar at the top of your Mac. Here you can open your
            notifications and get your unique <strong>Credentials</strong>.<br/><br/> Send a notification with your
            desired programming language or through the terminal - <a target="_blank"
                                                                      href="https://github.com/maxisme/notifi#http-request-examples">See
                examples</a>.
        <p>
            <img style="zoom:98.6%"
                 src="https://raw.githubusercontent.com/maxisme/notifi/master/Screen%20Shots/Notification.png">
        </p>
        </p>
        <h3>Want to know more?</h3>
        <p class="info">
            notifi is open source on <a target="_blank" href="https://github.com/maxisme/notifi">GitHub</a>.
        </p>
    </div>
</page>

<!-- Contact -->
<page id="contact">
    <h2>contact</h2>
    <span id='info'>
        <span id="contactForm">
        <div align="center">
        <?php
        if ($_SESSION["error"] > 0 && $_SESSION["error"] < 5) {
            echo "<span class='box' style='color:#6C0207'>";
            if ($_SESSION["error"] == 1) {
                echo "Error: No Email Address";
            } else if ($_SESSION["error"] == 2) {
                echo "Error: No Name";
            } else if ($_SESSION["error"] == 3) {
                echo "Error: No Message";
            } else if ($_SESSION["error"] == 4) {
                echo "Error: Invalid Email";
            }
            echo "</span>
		";
            $_SESSION["error"] = NULL;
        } else if ($_SESSION["success"] == 1) {
            echo "<span class='box' style='color:#2A682E'>Success! We will get back to you as soon as possible!</span>";
            $_SESSION["success"] = NULL;
        } ?>
		</div>
		<form action="email/send.php" method="post">
			Name<br/>
			<input name="name" type="text" required><br/><br/> Email
			<br/>
			<input name="email" type="email" required><br/><br/> Message
			<br/>
			<textarea style="resize: vertical;" name="message" required="required" rows="5"></textarea><br/><br/>
            <!--<div class="g-recaptcha" data-theme="dark" data-sitekey="6LfzGhITAAAAANBon7DeBgx2TSfch3i85zmxJOcw"></div><br /> -->
			<input id="sendEmail" value="Send" type="submit"/>
		</form>
		</span>
</page>

<!-- Ts & Cs -->
<page id="tsandcs">
    <h2>Ts & Cs</h2>

    <div class="info">
        By using the notifi application you are agreeing to these terms:<br/><br/> Use of the Service is at your own
        risk. The Service is provided on an "AS IS" and "AS AVAILABLE" basis without any representation or endorsement
        made and without warranty of any kind whether expressed or implied, including but not limited to the implied
        warranties of satisfactory quality, fitness for a particular purpose, non-infringement, compatibility, security
        and accuracy.<br/><br/>To the extent permitted by law, the Service, will not be liable for any indirect or
        consequential loss or damage whatsoever (including without limitation, loss of business, opportunity, data,
        profits) arising out of or in connection with the use of the Service.
        <p><sub>icon from flaticon.com</sub></p>
    </div>
</page>

<!-- weird element to add shaddow to images... don't ask -->
<svg height="0" xmlns="http://www.w3.org/2000/svg">
    <filter id="drop-shadow">
        <feGaussianBlur in="SourceAlpha" stdDeviation="4"/>
        <feOffset dx="0" dy="0" result="offsetblur"/>
        <feFlood flood-color="rgba(0,0,0,0.5)"/>
        <feComposite in2="offsetblur" operator="in"/>
        <feMerge>
            <feMergeNode/>
            <feMergeNode in="SourceGraphic"/>
        </feMerge>
    </filter>
</svg>
</body>

</html>