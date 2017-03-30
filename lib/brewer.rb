require_relative 'helpers'
require_relative 'adaptibrew'

include Helpers

class Brewer

  attr_reader :base_path
  attr_accessor :out, :log

  def initialize
    @base_path = Dir.pwd
    # Output of adaptibrew
    @out = []
    @log = @base_path + '/logs/output'
  end

  public

  # General methods

  def wait(time=30)
    sleep(time)
    self
  end

  # Runs an adaptibrew script
  # Output will be stored in @out
  def script(script, params=nil)
    @out.unshift(`python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp)
    self
  end

  # Clears the @out array
  # Writes current @out to log
  def clear
    write_log(@log, @out)
    @out = []
    self
  end


  # Adaptibrew methods

  # This should be run on system power on
  def boot
    pid(0)
    pump(0)
    relay(2, 1)
    all_relays_status
    relay_status(2)
  end

  def pump(state=0)
    if state == 1
      state_string = "on"
    else
      state_string = "off"
    end
    script("set_pump_#{state_string}")
    self
  end

  def relay(relay, state)
    script("set_relay", "#{relay} #{state}")
    self
  end

  def pid(state=0)
    if state == 1
      state_string = "on"
    else
      state_string = "off"
    end
    script("set_pid_#{state_string}")
    self
  end

  def all_relays_status
    script("get_relay_status_test")
    puts @out.first.split('\n')
  end

  def relay_status(relay)
    script("get_relay_status", "#{relay}")
    puts @out.first
  end

end
