snowAPI = "https://api.turku.fi/street-maintenance/v1/vehicles/"
activePolylines = []
map = null

initializeGoogleMaps = (callback, time)->
  turkuCenter = new google.maps.LatLng(60.4629060928519, 22.259694757206415)

  mapOptions =
    center: turkuCenter
    zoom: 13
    disableDefaultUI: true
    zoomControl: true
    zoomControlOptions:
      style: google.maps.ZoomControlStyle.SMALL
      position: google.maps.ControlPosition.RIGHT_BOTTOM

  styles = [
    "stylers": [
      { "invert_lightness": true }
      { "hue": "#00bbff" }
      { "weight": 0.4 }
      { "saturation": 80 }
    ]
  ,
    "featureType": "road.arterial"
    "stylers": [
      { "color": "#00bbff" }
      { "weight": 0.1 }
    ]
  ,
    "elementType": "labels"
    "stylers": [ "visibility": "off" ]
  ,
    "featureType": "road.local"
    "elementType": "labels.text.fill"
    "stylers": [
      { "visibility": "on" }
      { "color": "#2b8aa9" }
    ]
  ,
    "featureType": "administrative.locality"
    "stylers": [ "visibility": "on" ]
  ,
    "featureType": "administrative.neighborhood"
    "stylers": [ "visibility": "on" ]
  ,
    "featureType": "administrative.land_parcel"
    "stylers": [ "visibility": "on" ]
  ]

  map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions)
  map.setOptions({styles: styles})

  callback(time)

getPlowJobColor = (job)->
  switch job
    when "kv" then "#8dd3c7"
    when "au" then "#ffffb3"
    when "su" then "#bebada"
    when "hi" then "#fb8072"
    when "hj" then "#ffffff"
    when "hn" then "#fdb462"
    when "hs" then "#b3de69"
    when "ps" then "#ccebc5"
    when "pe" then "#aaaaff"
    else "#6cf0ff"

addMapLine = (plowData, plowJobId)->
  plowTrailColor = getPlowJobColor(plowJobId)
  polylinePath = _.reduce(plowData, ((accu, x)->
    accu.push(new google.maps.LatLng(x.coords[1], x.coords[0]))
    accu), [])

  strokeWeight = 2
  opacity = 0.8
  arr = []
  for ind in [0...plowData.length-1] by 1
    arr.push(polylinePath[ind])
    distance=google.maps.geometry.spherical.computeDistanceBetween(polylinePath[ind],polylinePath[ind+1])
    if 200<distance
      polyline = new google.maps.Polyline(
        path: arr
        geodesic: true
        strokeColor: plowTrailColor
        strokeWeight: strokeWeight
        strokeOpacity: opacity
      )
      activePolylines.push(polyline)
      polyline.setMap map
      arr = []
  polyline = new google.maps.Polyline(
    path: arr
    geodesic: true
    strokeColor: plowTrailColor
    strokeWeight: strokeWeight
    strokeOpacity: opacity
  )
  activePolylines.push(polyline)
  polyline.setMap map

clearMap = ->
  _.map(activePolylines, (polyline)-> polyline.setMap(null))

displayNotification = (notificationText)->
  $notification = $("#notification")
  $notification.empty().text(notificationText).slideDown(800).delay(5000).slideUp(800)

getActivePlows = (time, callback)->
  $("#load-spinner").fadeIn(400)
  $.getJSON("#{snowAPI}?since=#{time}&location_history=1")
    .done((json)->
      if json.length isnt 0
        callback(time, json)
      else
        displayNotification("Ei näytettävää valitulla ajalla")
      $("#load-spinner").fadeOut(800)
    )
    .fail((error)-> console.error("Failed to fetch active snowplows: #{JSON.stringify(error)}"))


createIndividualPlowTrail = (time, plowId, historyData)->
  $("#load-spinner").fadeIn(800)
  $.getJSON("#{snowAPI}#{plowId}?since=#{time}&temporal_resolution=4")
    .done((json)->
      if json.length isnt 0
        _.map(json, (oneJobOfThisPlow)->
          plowHasLastGoodEvent = oneJobOfThisPlow? and oneJobOfThisPlow[0]? and oneJobOfThisPlow[0].events? and oneJobOfThisPlow[0].events[0]?
          if plowHasLastGoodEvent
            addMapLine(oneJobOfThisPlow, oneJobOfThisPlow[0].events[0]))
        $("#load-spinner").fadeOut(800)
    )
    .fail((error)-> console.error("Failed to create snowplow trail for plow #{plowId}: #{JSON.stringify(error)}"))

createPlowsOnMap = (time, json)->
  _.each(json, (x)->
    createIndividualPlowTrail(time, x.id, json)
  )

populateMap = (time)->
  clearMap()
  getActivePlows("#{time}hours+ago", (time, json)-> createPlowsOnMap(time, json))


$(document).ready ->
  clearUI = ->
    $("#notification").stop(true, false).slideUp(200)
    $("#load-spinner").stop(true, false).fadeOut(200)

  $("#info").addClass("off") if localStorage["auratkartalla.userHasClosedInfo"]

  initializeGoogleMaps(populateMap, 8)

  $("#time-filters li").on("click", (e)->
    e.preventDefault()
    clearUI()

    $("#time-filters li").removeClass("active")
    $(e.currentTarget).addClass("active")
    $("#visualization").removeClass("on")

    populateMap($(e.currentTarget).data("hours"))
  )

  $("#info-close, #info-button").on("click", (e)->
    e.preventDefault()
    $("#info").toggleClass("off")
    localStorage["auratkartalla.userHasClosedInfo"] = true
  )
  $("#visualization-close, #visualization-button").on("click", (e)->
    e.preventDefault()
    $("#visualization").toggleClass("on")
  )
