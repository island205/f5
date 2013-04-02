var socket = io.connect(location.hostname);
var pathname = location.pathname;   // a prefix
socket.on('reload', function ($data) {
    if( if pathname === $data.slice(1) ){       // $data prefix a "/", remove it
        window.location.reload();
    } else{
        attchers = getFileAttchers()
        for(var i = 0; i < attchers.length; ++i){
            if((  localhost.hostname + $data) == attchers.file){
                reloadTag( attchers[i] );
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

    tagSize = tags.length;
    for( var i = 0;i < tagSize; ++i ){
        var tag = tags[i];
        if( tag.href || tag.src && ( tag.href && tag.href[0] !== "#" ) ){
            results.push( tag );
        }
    }

    var resultsSize = results.length;
    console.log( resultsSize );
    for( var i = 0;i < resultsSize;++i ){

        attchers[i] = {
            element:results[i],
            file:   results[i].href || results.src
        }

    }
    return attchers;
}

var reloadTag = function( attcher ){
    var element = attcher.element;
    if( element.href ){
        var href = element.href;
        element.href = href;
        return;         // done;
    } else {
        var src = element.src;
        element.src = src;
    }
}
