var toggleFold = function (obj) { // toggle fold by toggle className
    var cn = obj.parentNode.className;
    if (/\bfolded\b/.test(cn)) { // if folded
        cn = cn.replace(/\bfolded\b/, '') + ' unfold';
    } else {
        cn = cn.replace(/\bunfold\b/g, '') + ' folded'; // if unfold
    }
    obj.parentNode.className = cn.replace("  ", " ")
}

//-----------------------------------------
var fileLi = document.querySelectorAll("ul li:not(.subdir)");
var seletedClassName = "seleted_item"
var fileNum = fileLi.length;

var selectHandleFunc = function(){
    for(var i = 0;i < fileNum;i ++){
        //console.log( fileLi[i]);
        (function( index ){
            fileLi[index].addEventListener("click",function(){
                rmSelect()
                selectItem( fileLi[index] )
            });
        })(i);
    }
}
var selectItem = function( item ){
    item.className = item.className + " " + seletedClassName;
    var urlString = item.getElementsByTagName("a")[0].href;
    setUrlContainer(urlString)
}

var rmSelect = function(){
    for(var i = 0;i < fileNum;i ++){
        (function(index){
            var cn = fileLi[index].className;
            fileLi[index].className = cn.replace(seletedClassName,"");
        })(i);
    }
}
var setUrlContainer = function( url ){
    var base = location.hostname;
    var container = document.getElementById("urlContainer");
    container.value = url;
    container.select();
}
selectHandleFunc();
