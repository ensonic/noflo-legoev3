fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# http://www.ev3dev.org/docs/sensors/lego-ev3-color-sensor/

LOG_PREFIX = 'legoev3/ColorSensor:'
ENC = { encoding: 'utf8' }

class ColorSensor extends noflo.Component
  description: 'Detect colors/brightness.'
  icon: 'tint'

  constructor: ->
    #console.log "#{LOG_PREFIX} creating new component"

    @last_value = null
    @in_read_file = false
    @base = null

    @modes =
      'refletive': 'COL-REFLECT'
      'ambient': 'COL-AMBIENT'
      'color': 'COL-COLOR'

    @updateBase 1
    @updateMode @modes['refletive']

    @inPorts = new noflo.InPorts
      kick:
        datatype: 'bang'
        description: 'Probe the sensor'
      port:
        datatype: 'int'
        values: [1,2,3,4]
        description: 'Sensor port'
      mode:
        # values: /sys/class/msensor/sensorX/modes
        datatype: 'string'
        values: ['reflective','ambient', 'color']
        description: 'Sensor mode'

    @outPorts = new noflo.OutPorts
      value:
        datatype: 'int'
        description: 'Sends the color when changed'

    @inPorts.kick.on 'data', =>
      return if @in_read_file or @base is null
      @in_read_file = true
      new_value = parseInt (fs.readFileSync @base + '/value0', ENC)
      # Only send messages on change
      if new_value isnt @last_value
        #console.log "#{LOG_PREFIX} read: #{new_value}"
        @last_value = new_value
        @outPorts.value.send new_value
      @in_read_file = false

    @inPorts.mode.on 'data', (data) =>
      @updateMode data

    @inPorts.port.on 'data', (data) =>
      @updateBase data

    #console.log "#{LOG_PREFIX} created new component"

  updateMode: (mode) ->
    return if @base is null
    fs.writeFile @base + '/mode', @modes[mode]

  updateBase: (port) ->
    dir = '/sys/class/msensor/'
    try
      files = fs.readdirSync dir
      files = (file for file in files when file.slice(0, 6) is 'sensor')
      wanted = 'in' + port
      console.log "#{LOG_PREFIX} searching for #{wanted} in #{files.length} entries"
      for file in files
        path = dir + file
        port_name = fs.readFileSync path + '/port_name', ENC
        if port_name.trim() is wanted
          type_id = fs.readFileSync path + '/type_id', ENC
          if type_id.trim() is "29"
            @base = path
            console.log "#{LOG_PREFIX} new base: #{@base}"
            @outPorts.value.connect()
          else
            console.log "#{LOG_PREFIX} wrong sensor type: #{type_id} != 29"
          break
    catch err
      console.log "#{LOG_PREFIX} readdir failed: #{err}"

exports.getComponent = -> new ColorSensor

