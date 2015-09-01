FROM ricarus/rpi-raspbian-elixir
ADD . /fluffy_home
ENV PATH /elixir/bin:$PATH
ENV LC_ALL en_US.UTF-8
ENV MIX_ENV prod
ENV PORT 80
EXPOSE 80
WORKDIR /fluffy_home
RUN mix deps.get --only prod
RUN mix compile
RUN brunch build --production
RUN MIX_ENV=prod mix phoenix.digest
CMD mix phoenix.server
