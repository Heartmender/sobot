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
	if (!($stmt = $db->prepare("SELECT id, time, nick, line FROM Chatlines WHERE target = ? AND ? = FROM_UNIXTIME(time, '%Y-%m-%d');"))) {
		die("Prepare failed: (" . $db->errno . ") " . $db->error);
	}
	if (!($stmt->bind_param("ss", $channel, $_SERVER["date"]))) {
		die("Bind failed: (" . $db->errno . ") " . $db->error);
	}
} else {
	if (!($stmt = $db->prepare("SELECT id, time, nick, line FROM Chatlines WHERE target = ?"))) {
		die("Prepare failed: (" . $db->errno . ") " . $db->error);
	}
	if (!($stmt->bind_param("s", $channel))) {
		die("Bind failed: (" . $db->errno . ") " . $db->error);
	}
}
?>
	<nav class="light-blue lighten-1" role="navigation">
		<div class="nav-wrapper container"><a id="logo-container" href="/" class="brand-logo">Tulpa.im</a>
		</div>
	</nav>
	<div class="section no-pad-bot" id="index-banner">
		<div class="container">
			<h1 class="header center orange-text">Logmon</h1>
			<br><br>
			<table>
				<tr><td>id</td><td>date</td><td>nick</td><td>message</td></tr>
<?php
if (!$stmt->execute()) {
	die("Execute failed: (" . $stmt->errno . ") " . $stmt->error);
}

$id = null;
$date = null;
$nick = null;
$line = null;

if(!($stmt->bind_result($id, $date, $nick, $line))) {
	die("bind_result failed: (" . $stmt->errno . ") " . $stmt->error);
}

while($stmt->fetch()) {
	$datetime = new DateTime();
	$datetime->setTimestamp($date);
	$datestr = $datetime->format('Y-m-d H:i:s');

	echo "<tr><td>$id</td><td>$datestr</td><td>$nick</td><td>$line</td></tr>";
}
?>
			</table>
		</div>
	</div>

		<!--Import jQuery before materialize.js-->
		<script type="text/javascript" src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
		<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/materialize/0.96.1/js/materialize.min.js"></script>
	</body>
</html>
