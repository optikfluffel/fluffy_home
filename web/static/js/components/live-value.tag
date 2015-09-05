<live-value> <!-- TODO: onclick={show_chart} -->
  <span class={iconCssClasses}></span>
  <span>{roundedValue}</span>

  <script>
    this.on('update', function() {
      this.roundedValue = opts.value.toFixed(1)
    })

    var iconFor = {
      air_quality: 'entypo-air',
      humidity: 'entypo-droplet',
      temperature: 'entypo-thermometer'
    }
    if (iconFor[opts.type]) {
      this.iconCssClasses = 'icon ' + iconFor[opts.type]
    }
  </script>
</live-value>
