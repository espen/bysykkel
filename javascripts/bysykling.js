Array.prototype.contains = function (element) {
    for (var i = 0; i < this.length; i++) 
    {
        if (this[i] == element) {
            return true;
        }
    }
    return false;
};

if(typeof(console) === 'undefined') {
    var console = {}
    console.log = console.error = console.info = console.debug = console.warn = console.trace = console.dir = console.dirxml = console.group = console.groupEnd = console.time = console.timeEnd = console.assert = console.profile = function() {};
}
localStorage.removeItem("racks");
  
function listAll() {
    $( '#all div[data-role="content"] ul' ).remove();
	$.getJSON('http://bysykling.heroku.com/api/bysykkel/v1/racks/?callback=?', function(data) {
        listed = localStorage.getItem("racks") ? localStorage.getItem("racks").split(';') : [];
        list = $( "<ul>", { 
    			"class": "ui-listbox-list",
    		}).appendTo( '#all div[data-role="content"]' );

		data.racks.forEach( function(rack,i) {
		    if ( !listed.contains(rack.id) ) {
    		    writeRack('all', rack,false);
		    }
		});
        list.listview();
	});
}

function listNearby() {
    $( '#nearby div[data-role="content"] ul' ).remove();
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition( function(position) {
            current_location = new LatLon( position.coords.latitude, position.coords.longitude );
            list = $( "<ul>", { 
        			"class": "ui-listbox-list",
        		}).appendTo( '#nearby div[data-role="content"]' );
            
            $.getJSON('http://bysykling.heroku.com/api/bysykkel/v1/racks/live/?callback=?', function(data) {
                nearRacks = [];
        		data.racks.forEach( function(rack,i) {
        		    rack_location = new LatLon( parseFloat( rack.geo.coordinates[1] ), parseFloat( rack.geo.coordinates[0] ) );
    		        rack.distance = parseFloat( current_location.distanceTo(rack_location ) );
        		    if ( rack.distance < 0.5 ) {
            		    nearRacks.push( [ parseFloat( current_location.distanceTo(rack_location ) ), rack ] );
        		    }
        		});
        		nearRacks.sort( function(a,b) {
        		    return a[0] - b[0];
        		} );
        		nearRacks.forEach( function(item,i) {
            		writeRack('nearby', item[1] );
    		    });
    		    list.listview();
        	});
        	
        } );
    }
}

function listRacks() {
    var racks = localStorage.getItem("racks") ? localStorage.getItem("racks").split(';') : [];
	var count = racks.length;
    $( '#favorites div[data-role="content"] ul' ).remove();
    list = $( "<ul>", { 
			"class": "ui-listbox-list",
		}).appendTo( '#favorites div[data-role="content"]' );
	racks.forEach( function(rack,i) {
		$.getJSON('http://bysykling.heroku.com/api/bysykkel/v1/racks/' + rack + '?callback=?', function(data) {
		    writeRack('favorites', data.racks[0]);
			if (!--count) {
                list.listview();
			}
		});
	});
}

function writeRack(page, rack,showAvailability) {
    showAvailability = (typeof showAvailability == "undefined" ? true : false);
    $('#' + page + ' ul').append( '<li data-id="' + rack.id + '" data-lat="' + rack.geo.coordinates[1] + '" data-lng="' + rack.geo.coordinates[0] + '"' + (typeof rack.distance != "undefined" ? (' data-distance="' + rack.distance + '"'):  '') + '>' +
            '<a href="#favorites">' + rack.name + 
            (typeof rack.distance != "undefined" ? (' (' + parseInt( rack.distance * 1000 ) + ' m.)'):  '') +
            (showAvailability ? '<br>' +
			(rack.ready_bikes == 0 ? 'Ingen' : rack.ready_bikes) + ' ledige sykler. ' +
			(rack.empty_locks == 0 ? 'Ingen' : rack.empty_locks) + ' ledige låser.'
			:'') +
			'</a></li>');
}

function addRack() {
    console.log('add rack');
    if ( $(this).length != 1 || !parseInt( $(this).attr('data-id') ) ) {
        return;
    }
    console.log('adding...');
	var racks = localStorage.getItem("racks") ? localStorage.getItem("racks").split(';') : [];
	racks.push( $(this).attr('data-id') );
	localStorage.setItem( "racks", racks.join(';')  );
}

function removeRack(e) {
	var racks = localStorage.getItem('racks').split(';'), updated_racks = [];
	var id = $(this).closest('li').attr('data-id');
	racks.forEach(function(rack, i) {
	    if (rack && rack != id ) {
    	    updated_racks.push( rack );
	    }
	});
	localStorage.setItem( "racks", updated_racks.join(';') );
	$(this).closest('li').hide()
	$(this).closest('li').remove();
}


window.applicationCache.addEventListener(
    'updateready',
    function(){
        window.applicationCache.swapCache();
        window.location.reload(true);
    },
    false
);
    //window.addEventListener('unload', function() { $('body').hide(); } );
    //document.addEventListener('touchmove', function(e) { e.preventDefault(); } );

$(document).ready( function() {
    $('#all li').live('click', addRack );
    $('#nearby li').live('click', addRack );
    $('#all').bind('beforepageshow', function() {
        console.log('show all');
        listAll();
    });
    $('#nearby').bind('beforepageshow', function() {
        console.log('show nearby');
        listNearby();
    });
    $('#favorites').bind('beforepageshow', function() {
        console.log('show racks');
        listRacks();
    });

    
	var current_location;
	if ( !window.navigator.onLine ) {
    	$('#all div[data-role="content"]').html('Du må enten være online eller gå til et bysykkelstativ for å se om det er ledige sykler.');
	}
	else {
    	if ( localStorage.getItem("racks") || !localStorage.getItem('racks') == null ) {
    	    $.changePage( $('#all'),$('#favorites') );
    	} else {
    	    listAll();
    	}
	}
});