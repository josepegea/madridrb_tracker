var mymap = L.map('mapid').setView([51.505, -0.09], 13);

// L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png?{foo}', {foo: 'bar', attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'}).addTo(mymap);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
	maxZoom: 18,
	attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
		'<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
		'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
	id: 'mapbox.streets'
}).addTo(mymap);

function showLayer(day) {
  let url = "map.json";
  if (day) {
    url += "?day=" + day;
  }
  
  let xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (xmlhttp.readyState == XMLHttpRequest.DONE && xmlhttp.status == 200) {
      let geoJsonData = JSON.parse(xmlhttp.responseText);
      let layer = L.geoJSON(geoJsonData.path);
      layer.addTo(mymap);
      let stepsLayer = L.geoJSON(geoJsonData.steps, { pointToLayer: plotSteps } );
      stepsLayer.addTo(mymap);
      mymap.fitBounds(layer.getBounds());
    }
  };

  xmlhttp.open("GET", url, true);
  xmlhttp.send();
}

function getDay() {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get('day');
}

function plotSteps(feature, latlng) {
  return L.circleMarker(latlng, { radius: 4, color: "#a66" } );
}

showLayer(getDay());
