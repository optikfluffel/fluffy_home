<line-chart>
  <h3>{title}</h3>
  <div class="ct-chart ct-double-octave" id="ct-chart-{opts.type}"></div>

  <!-- logic -->
  <script>
    var self = this;
    this.title = opts.type.titleize();

    this.on("mount", function() {
      fetch('/api/living-room/' + opts.type)
        .then(function(response) {
          return response.json();

        }).then(function(json) {
          var results = json.filter(function(x) {
            return x.value !== null;
          });

          if (results.length > 0) {
            var data = {
              labels: results.map(function(x) {return moment(x.date).format("H:mm")}),
              series: [
                results.map(function(x) {return x.value})
              ]
            };

            // default suffix
            var suffix = "";
            var low = 0;
            var high = 100;
            switch (opts.type) {
              case "temperature":
                suffix += "°C";
                low = 10;
                high = 30;
                break;
              case "humidity":
                suffix += "%";
                break;
            }

            var options = {
              low: low,
              high: high,
              showArea: true,
              axisY: {
                showLabel: false,
                showGrid: false
              },
              plugins: [
                Chartist.plugins.ctPointLabels({
                  labelInterpolationFnc: function(value) {
                    return value.toFixed(1) + suffix;
                  }
                })
              ]
            };

            var chartId = '#ct-chart-' + opts.type;
            new Chartist.Line(chartId, data, options);
          }
        }).catch(function(ex) {
          console.log('something went wrong', ex);
        })
    })
  </script>

</line-chart>
