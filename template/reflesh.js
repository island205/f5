var socket = io.connect(location.hostname);
var pathname = location.pathname;   // a prefix
socket.on('reload', function ($data) {
    pathname = decodeURIComponent( pathname );
    console.log( pathname,$data.slice(1) );
    if( pathname === $data.slice(1) ){       // $data prefix a dot("."), remove it
        window.location.reload();
    } else{
        document.title = "!"+document.title;
        attchers = getFileAttchers();
        for(var i = 0; i < attchers.length; ++i){
            var url = location.protocol + "//" + location.host + "/" + $data.slice(2);
            console.log( "FULL",url );
            //console.log( 'url:',url,'data:',$data,'file:',attchers[i].file);

            if(url == attchers[i].file){
                reloadTag( attchers[i] );
                console.log( "match!!" );
                break;
            }
        }
    }
});

var getFileAttchers = function(){
    var tags,
        results = [],
        tagSize,
        attchers = [];

    if( document.querySelectorAll ){
        tags = document.querySelectorAll("*[href],*[src]");
    } else{
        tags = document.getElementsByTagName("*");
    }

    var localHref = location.href;
    tagSize = tags.length;
    for( var i = 0;i < tagSize; ++i ){
        var tag = tags[i];
        if( tag.src ){
            results.push({
                element:tag,
                file:  decodeURIComponent(tag.src)
            })
        }
        if( tag.href && tag.href !== localHref + "#" ){
            results.push({
                element:tag,
                file:  decodeURIComponent(tag.href)
            });
        }
    }

    var resultsSize = results.length;
    attchers = results;
    return attchers;
}

var reloadTag = function( attcher ){
    var element = attcher.element;
    console.log( 'reloading !!!' )
    if( !!element.href ){
        var href = element.href;
        element.href = href;
        return;         // done;
    } else {
        var src = element.src;
        element.src = src;
    }
}

;(function(){
    setTimeout(function(){
    document.title = "hh";
    },100);
})();

