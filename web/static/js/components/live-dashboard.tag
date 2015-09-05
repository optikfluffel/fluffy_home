require('./live-value')
require('./loading-placeholder')
<live-dashboard>
  <h2>{opts.name}: Live</h2>

  <section>
    <loading-placeholder if={loading}></loading-placeholder>
    <live-value if={!loading} each={values} value={value} type={name} class={name} />
  </section>

  <script>
    var self = this;
    this.values = opts.values;
    this.loading = true;

    this.on('mount', function() {
      opts.channel.on("live:living-room", function(payload) {
        self.update({values: payload.values})
      })
    })

    this.on('update', function() {
      if (self.loading) {
        self.loading = self.values.length === 0;
      }
    })
  </script>
</live-dashboard>
