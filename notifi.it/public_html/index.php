<?php
($settings = yaml_parse_file("../config.yaml")) || die("YAML file not found");
if(!is_file("images/og_logo.png")) die("no og logo");
if(!is_file("images/icon.ico")) die("no ico");

/* FUNCTIONS */
function addHyph($str)
{
    return str_replace(" ", "-", $str);
}

function removeHyph($str)
{
    return str_replace("-", " ", $str);
}

/* SETUP ARRAY OF PAGES */
$dir = "pages/";
$pages = array();
foreach (array_diff(scandir($dir), array('..', '.')) as $p) {
    // remove .html and .php and hyphens from string and uppercase words.
    $p_name = preg_replace("/\d*_/", "", $p);
    $p_name = ucwords(removeHyph(str_replace(".html", "", str_replace(".php", "", $p_name))));
    if ($p_name != ".keep") $pages[$p_name] = $p;
}
?>
<head>
    <!-- Info META -->
    <title><?php echo $settings["title"]; ?></title>
    <meta property="og:title" content="<?php echo $settings["title"]; ?>" />
    <meta name="keywords" content="<?php echo $settings["meta"]["keywords"]; ?>">
    <meta name="description" content="<?php echo $settings["meta"]["description"];?>">
    <meta property="og:description" content="<?php echo $settings["meta"]["description"];?>"/>
    <meta property="og:image" content="<?php echo "https://".$_SERVER['HTTP_HOST']?>/images/og_logo.png" />
    <link rel="shortcut icon" href="images/icon.ico">

    <!-- Mobile Meta -->
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0"/>

    <!-- jQuery -->
    <script src="js/jquery.min.js"></script>

    <!-- Materialize -->
    <script src="js/materialize.min.js"></script>
    <link rel="stylesheet" href="css/materialize/materialize.css">

    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css?family=Montserrat:200,300,400,500,600,700" rel="stylesheet">
    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

    <!-- Font Awesome -->
    <script src="/js/all.js"></script>

    <!-- Custom CSS -->
    <link rel="stylesheet" type="text/css" href="css/style.min.css"/>

    <!-- Custom JS -->
    <script src="js/script.js"></script>
</head>
<body>
<page id="welcome" class="welcome">
    <div class="valign-wrapper">
        <div align="center" class="valign">
            <p>
                <img class="logo" src="images/logo.png">
            </p>
            <h1><?php echo $settings["title"]; ?></h1>
            <div class="info">
                <?php echo $settings["meta"]["description"]; ?>
            </div>
            <a href="download" class="download">DOWNLOAD<i class="fab fa-apple"></i></a>
            <p class="nav">
                <?php
                foreach ($pages as $name => $page) echo "<a href=\"#" . addHyph($name) . "\">$name</a>";
                ?>
                <a href="#contact">Contact</a>
            </p>
        </div>
    </div>
</page>

<!-- pages -->
<?php
foreach ($pages as $name => $page) {
    echo "<page id='" . addHyph($name) . "'><div align='center'><h2>$name</h2></div>";
    include $dir . $page;
    echo "</page>";
}
?>

<!-- contact -->
<page id="contact">
    <div align='center'><h2>Contact</h2></div>
    <p>
        Please feel free to drop us an email. We would absolutely ❤️ to hear from you.
    </p>

    <?php
    if (isset($_SESSION["email"])) echo "<i class='success'>" . $_SESSION["email"] . "</i>";
    if (isset($_SESSION["error"])) echo "<i class='error'>" . $_SESSION["error"] . "</i>";
    ?>

    <!-- form -->
    <form method="post" action="backend/send-email.php">
        <div class="row">
            <div class="col s12 m12 l6 input-field">
                <input id="name" name="name" type="text" value="<?php echo $_SESSION["name"] ?>">
                <label for="name">Name</label>
            </div>

            <div class="col s12 m12 l6 input-field">
                <input id="email" name="from" value="<?php echo $_SESSION["from"] ?>" type="text">
                <!-- not type="email" as that makes submission fail -->
                <label for="email">Email</label>
            </div>
        </div>

        <div class="row">
            <div class="col s12 input-field">
                    <textarea id="mess" name="body"
                              class="materialize-textarea"><?php echo $_SESSION["body"] ?></textarea>
                <label for="mess">Message</label>
            </div>
        </div>
        <div align="center" id="captcha"></div>
        <!-- hidden submit button -->
        <input id="submit" type="submit" style="visibility: hidden" disabled="disabled">
    </form>
    <div align="center" class="sub">Designed, maintained and built by <a href="https://max.me.uk">Maximilian Mitchell</a><br>© <?php echo date("Y");?></div>
    <!-- recaptcha import -->
    <script>
		var SITEKEY = "<?php echo $settings["recaptcha"]["pub"]?>";

		var correctCaptcha = function (response) {
			$("form").attr("action", $("form").attr("action") + "?g-recaptcha-response=" + response);
			$("#submit").removeAttr("disabled");
			$("#submit").click();
		};

		var onloadCallback = function () {
			grecaptcha.render('captcha', {
				'sitekey': SITEKEY,
				'callback': correctCaptcha
			});
		};
    </script>
    <script src="https://www.google.com/recaptcha/api.js?onload=onloadCallback&render=explicit" async
            defer></script>
</page>
</body>