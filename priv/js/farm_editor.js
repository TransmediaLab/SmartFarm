/**
 * @license
 * SmartFarm
 *
 * Copyright 2015 Department of Computing and Information Sciences
 * Kansas State University
 * https://cis.ksu.edu
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview Farm Editor controls for SmartFarm.
 * @author nhbean@ksu.edu (Nathan H. Bean)
 */
jQuery(function(){

  var farm = {}, 
      location, locationMapMarker, locationMap,
      field, fieldCount, fieldMapMarker, fieldMap,
      id = window.location.pathname.split('/')[2],
      ws = new WebSocket("ws://" + window.location.host + "/farms/" + id + "/ws");

  ws.onmessage = function(msg) {
    msg = JSON.parse(msg.data),
        path = [],
        fields = [],
        fieldCount = 0;
    switch(msg["type"]) {
      case "not-logged-in":
        $(document).trigger('log-in-to-save');
        break;
      case "new-id":
        window.history.pushState("", "", "/farms/" + msg["data"]);
        break;
      case "farm":
        farm = msg["data"];
        $('#farm-name').val(farm.name);
        $('#farm-description').val(farm.description);
        $('#farm-latitude').val(farm.latitude);
        $('#farm-longitude').val(farm.longitude);
        location = new google.maps.LatLng(
          farm.latitude,
          farm.longitude,
          false
        );
        farm.fields.forEach( function(field, i) {
          addField(new google.maps.Polygon({
            map: fieldMap,
            paths: field,
            fillColor: '#00ff00',
            strokeColor: '#00cc00',
            draggable: true,
            editable: true
          }));
        });
        panMap();
        break;
    }
  }

  ws.onclose = function() {
    alert('Connection with the server was lost.  Please refresh the page to re-establish it');
  }

  $(document).on('logged-in', function(event, user_id, token){
    ws.send(JSON.stringify({type: 'logged-in', data: {user_id: user_id, token: token}}));
  });

  $(document).on('logged-out', function(event){
    ws.send(JSON.stringify({type: 'logged-out'}));
  });


  function panMap() {
    $('#farm-latitude').val(location.lat());
    $('#farm-longitude').val(location.lng());
    locationMapMarker.setPosition(location);
    locationMap.panTo(location);
    fieldMapMarker.setPosition(location);
    fieldMap.panTo(location);
  }

  /* Location map controls & data */

  var geocoder = new google.maps.Geocoder();

  location = new google.maps.LatLng(
    39.2113, 
    -96.5992,
    true
  );

  locationMap = new google.maps.Map( $('#location-map')[0],{
    center: location,
    zoom: 14,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  });

  locationMapMarker = new google.maps.Marker({
    map: locationMap,
    title: "Farm Location",
    position: location,
    draggable: true
  });

  google.maps.event.addListener(locationMapMarker, 'drag', function() {
    location = locationMapMarker.getPosition();
    $('#farm-latitude').val(location.lat());
    $('#farm-longitude').val(location.lng());
  });

  google.maps.event.addListener(locationMapMarker, 'dragend', function() {
    panMap();
  });

  $('#location-search').on('click', function(event){
    event.preventDefault();
    geocoder.geocode({address: $('#location-address').val()}, 
      function(result, status){
        if(status == google.maps.GeocoderStatus.OK) {
          location = result[0].geometry.location;
          panMap();
        }
        else { alert(status); }
      }
    );
  });

  $('#location-capture').on('click', function(event){
    event.preventDefault();
    navigator.geolocation.getCurrentPosition( function(position) {
      location = new google.maps.LatLng(
        position.coords.latitude,
        position.coords.longitude,
        false
      );
      panMap();
    });
  });

  /* Field map controls & data */
 
  fieldMap = new google.maps.Map( $('#field-map')[0], {
    center: location,
    zoom: 14,
    mapTypeId: google.maps.MapTypeId.TERRAIN
  });

  fieldMapMarker = new google.maps.Marker({
    map: fieldMap,
    title: "Farm Location",
    position: location
  });

  drawingOptions = {
    drawingMode: google.maps.drawing.OverlayType.POLYGON,
    drawingControls: true,
    drawingControlOptions: {
      position: google.maps.ControlPosition.TOP_CENTER,
      drawingModes: [ google.maps.drawing.OverlayType.POLYGON ]
    },
    polygonOptions: {
      fillColor: '#00ff00'
    }
  }
  var drawingManager = new google.maps.drawing.DrawingManager(drawingOptions);
  drawingManager.setMap(fieldMap);

  $('body').on('click', '.field-row', function(row) {
    alert(row.data('index'));
  });

  google.maps.event.addListener(drawingManager, 'polygoncomplete', function(polygon) {
    addField(polygon);
    sendFields();
  });


  function addField(polygon) {
    var row = $('<li class="field-row list-group-item"></li>'),
        remove = $('<a href="#" class="pull-right">&times;</a>');
    row.on('mouseover', function(event) {
      polygon.setOptions({fillColor: '#fffacd'});
    });
    row.on('mouseout', function(event) {
      polygon.setOptions({fillColor: '#00ff00'});
    });
    remove.on('click', function(event) {
      event.preventDefault();
      polygon.setMap(null);
      row.remove();
      sendFields();
    });
    row.append(remove);
    polygon.getPath().forEach(function(latLng){
      var point = $('<span class="point"></span>'),
          lat = $('<span class="input-group input-group-sm"></span>'),
          lng = $('<span class="input-group input-group-sm"></span>');
      lat.append('<span class="input-group-addon">lat</input>');
      lat.append('<input type="text" class="form-control coord lat" value="' + latLng.lat() + '"/>');
      lng.append('<span class="input-group-addon">lng</input>');
      lng.append('<input type="text" class="form-control coord lng" value="' + latLng.lng() + '"/>');
      point.append(lat);
      point.append(lng);
      row.append(point);
    });
    $('#farm-fields').append(row);
  }

  function sendFields() {
    var fieldData = []
    $('#farm-fields li').each( function(i, field) {
      corners = []
      $(field).children('.point').each( function (j, point) {
        corners.push({
          lat: parseFloat($(point).find('.lat').first().val()), 
          lng: parseFloat($(point).find('.lng').first().val())
        });
      });
      fieldData.push(corners)
    });
    ws.send(JSON.stringify({"type":"fields","data":fieldData}));
  }


  /* Saving */

  $('#farm-name').on('change', function() {
    ws.send(JSON.stringify({"type":"name","data":$('#farm-name').val()}));
  });

  $('#farm-description').on('change', function() {
    ws.send(JSON.stringify({"type":"description","data":$('#farm-description').val()}));
  });

  $('#farm-save').on('click', function(){
    ws.send(JSON.stringify({"type":"save"}));
  });  

});

