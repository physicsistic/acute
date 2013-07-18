var screen1 = [];
var screen3 = {"timings":[0.697,0.684,0.373,1.077,1.243,0.463,0.589,1.477,0.969,0.839,0.442,0.511,0.822,1.209,0.94,0.967,0.525,0.381,0.769,0.603,1.359,0.873,0.621,0.979,1.303,0.58,0.505,0.708,0.513,0.839,1.486,0.576,0.634,0.573,0.869,0.568,0.739,0.41,0.647,0.385,0.442,0.45,0.982,0.508,0.886,0.408,0.822,0.459],"moods":[7,6,7,3,4,7,5,2,7,5,7,2,7,7,7,7,7,7,5,6,6,7,2,4,7,7,7,6,7,5,7,7,7,6,6,6,7,7,7,7,7,7,6,7,7,7,7,7]};
var latestReactionTime = 0.535655;


function round(num, places) {
    var multiplier = Math.pow(10, places);
    return Math.round(num * multiplier) / multiplier;
}
 

 if (screen1.length == 0) {
 	// no sleep data
 	$(".bottom").remove();
 	$("#justNowScore").html("");
 	$(".pane1 h3").html("Buy an UP to log your sleep and learn more about how your sleep affects your mental acuity.");
 	$(".pane1 h3").attr("style", "font-size: 18px; line-height: 140%;");
 	$(".pane1 h1").append("<img src='moon.png' />");

 }
 else {
 	$('#justNowScore').html(round(latestReactionTime, 3));
$('#moreSleepScore').html(round(screen1["moreSleep"], 3));
$('#lessSleepScore').html(round(screen1["lessSleep"], 3));
 }
 var scatterData = [];
 for (var i = 0; i < screen3["timings"].length; i++) {
 	var temp = [];
 	temp.push(screen3["timings"][i]);
 	temp.push(screen3["moods"][i]);
 	scatterData.push(temp);
 }
