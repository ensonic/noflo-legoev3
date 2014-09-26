fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# https://github.com/ev3dev/ev3dev/wiki/Using-Sound

class Beep extends noflo.Component
  description: 'Play beep tones'
  icon: 'music'

  constructor: ->
    @volume = 50
    @base = '/sys/devices/platform/snd-legoev3/'

    @inPorts = new noflo.InPorts
      frequency:
        datatype: 'int'
        description: 'Should be between 100 and 10000, 0 for stop'
      volume:
        datatype: 'int'
        description: 'From 0 to 100'

    @inPorts.frequency.on 'data', (data) =>
      fs.writeFile @base + 'tone', 0
      fs.writeFile @base + 'volume', @volume
      fs.writeFile @base + 'tone', data

    @inPorts.volume.on 'data', (data) =>
      @volume = data
   
exports.getComponent = -> new Beep

