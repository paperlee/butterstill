$(function(){
	$(".bgbox").height(window.screen.availHeight);
	//console.log(window.screen.availHeight);

	// check if in phone
	//console.log($("div.bigbox").css("marginTop"));
	if ($("div.bigbox").css("marginTop") == "420px"){
		console.log("Yes in phone");
		$("div.bigbox").css("marginTop",window.screen.availHeight-320);
	}
});