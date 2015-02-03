fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# https://github.com/ev3dev/ev3dev/wiki/Using-Motors
# https://github.com/ev3dev/ev3dev/wiki/Using-Motors-Run-Forever

LOG_PREFIX = 'legoev3/Motor:'

class Motor extends noflo.Component
  description: 'Control Motor'
  icon: 'car'

  constructor: ->
    @updateBase 'A'

    @inPorts = new noflo.InPorts
      speed:
        datatype: 'integer'
        description: '-100 to 100'
      port:
        datatype: 'string'
        values: ['A', 'B', 'C', 'D']
        description: 'Motor port'

    @inPorts.speed.on 'data', (speed) =>
      return unless @base
      # run_mode = forever
      # regulation_mode:
      #   off -> duty_cycle_sp (-100 ... +100
      #   on  -> pulses_per_second_sp (range depends on motor type)
      # run = 1
      fs.writeFile @base + 'run_mode', 'forever'
      fs.writeFile @base + 'regulation_mode', 'off'
      fs.writeFile @base + 'duty_cycle_sp', speed
      fs.writeFile @base + 'run', if (speed == 0) then '0' else '1'
      #console.log "#{LOG_PREFIX} setting speed: #{speed}"

    @inPorts.port.on 'data', (data) =>
      @updateBase data

  updateBase: (port) ->
    dir = "/sys/bus/legoev3/devices/out#{port}:motor/tacho-motor/"
    try
      files = fs.readdirSync dir
      files = (file for file in files when file.slice(0, 11) is 'tacho-motor')
      return unless files.length == 1
      @base = dir + files[0] + '/'
      console.log "#{LOG_PREFIX} new base: #{@base}"
    catch err
      console.log "#{LOG_PREFIX} readdir failed: #{err}"

  shutdown: ->
    return unless @base
    fs.writeFile @base + 'run', '0'

exports.getComponent = -> new Motor

