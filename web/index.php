<!DOCTYPE html>
<html>
	<head>
		<title>Logmon</title>
		<!--Import materialize.css-->
		<link type="text/css" rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.96.1/css/materialize.min.css"  media="screen,projection"/>

		<!--Let browser know website is optimized for mobile-->
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
	</head>

	<body>
<?php
include './config.php';


if(isset($_SERVER["channel"])) {
	$channel = $_SERVER["channel"];
} else {
	$channel = "#quoratest123";
}

if(isset($_SERVER["date"])) {
	$stmt = $db->prepare("SELECT * FROM Chatlines WHERE target = ? AND ? = FROM_UNIXTIME(time, '%Y-%m-%d');");
	$stmt->bind_param("ss", $channel, $_SERVER["date"]);
} else {
	if (!($stmt = $db->prepare("SELECT * FROM Chatlines WHERE target = ?"))) {
		die("Prepare failed: (" . $db->errno . ") " . $db->error);
	}
	$stmt->bind_param("s", $channel);
}
?>
	<nav class="light-blue lighten-1" role="navigation">
		<div class="nav-wrapper container"><a id="logo-container" href="#" class="brand-logo">Tulpa.im</a>
		</div>
	</nav>
	<div class="section no-pad-bot" id="index-banner">
		<div class="container">
			<br><br>
			<h1 class="header center orange-text">Logmon</h1>
			<br><br>
		</div>
	</div>

	<table>
		<tr><td>id</td><td>date</td><td>nick</td><td>message</td></tr>
<?php
if (!$stmt->execute()) {
	die("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
}
?>
	</table>

		<!--Import jQuery before materialize.js-->
		<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.96.1/js/materialize.min.js"></script>
	</body>
</html>
