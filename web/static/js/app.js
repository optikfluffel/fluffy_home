// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "deps/phoenix_html/web/static/js/phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket";

require('./components/live-dashboard');
require('./components/charts');
require('./components/line-chart');

// Helper functions
function ready(fn) {
  if (document.readyState != 'loading') {
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}
String.prototype.titleize = function() {
  var words = this.split('_');
  var array = [];
  for (var i=0; i<words.length; ++i) {
    array.push(words[i].charAt(0).toUpperCase() + words[i].toLowerCase().slice(1));
  }
  return array.join(' ');
};

let App = {
  init() {
    var channel = socket.channel("rooms:living-room", {});

    channel.join()
      .receive("ok", _ => {console.log("Connected to phoenix channel.");})
      .receive("error", _ => {console.log("Unabled to connect to phoenix channel.");});

    // set Chart.js setting
    // Chart.defaults.global.responsive = true

    let name = 'Living Room';

    // init empty live dashboard
    riot.mount('live-dashboard', {name: name,
                                  values: [],
                                  channel: channel});

    // init line charts
    riot.mount('charts', {name: name,
                          measurements: [
                            {name: "temperature"},
                            {name: "humidity"},
                            {name: "air_quality"}
                          ]});
  }
};

ready(App.init());

export default App;
