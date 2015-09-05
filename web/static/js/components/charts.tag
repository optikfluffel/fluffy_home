require('./line-chart')
<charts>
  <h2>{opts.name}: Last hour</h2>

  <section>
    <line-chart each={measurements} type={name} class={name}></line-chart>
  </section>

  <script>
    this.measurements = opts.measurements;
    riot.mount('line-chart');
  </script>
</charts>
