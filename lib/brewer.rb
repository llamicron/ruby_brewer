require_relative "autoload"

class Brewer

  attr_reader :base_path
  attr_accessor :out, :temps

  def initialize
    @base_path = Dir.home + '/.brewer'
    # Output of adaptibrew
    @out = []
    @temps = {}
  end

  public

  # Brewer methods ------------------------------------------------------
  # general utilities for the brewer class

  def wait(time=30)
    sleep(time.to_f)
    true
  end

  # Runs an adaptibrew script
  # Output will be stored in @out
  # you may see `echo` quite a bit. This will almost always be directly after calling a script
  # It will be set to the output of the last script. I can't just return the output because i need to return self
  def script(script, params=nil)
    @out.unshift(`python #{@base_path}/adaptibrew/#{script}.py #{params}`.chomp)
    @out.first
  end

  def clear
    @out = []
  end

  # Adaptibrew methods ----------------------------------------------
  # for working with the rig

  def pump(state=0)
    if state.to_b
      return script("set_pump_on")
    else
      if pid['pid_running'].to_b
        pid(0)
        echo
      end
      return script("set_pump_off")
    end
  end

  # Turns PID on or off, or gets state if no arg is provided
  def pid(state="status")
    if state == "status"
      return {
        'pid_running' => script("is_pid_running"),
        'sv_temp' => sv,
        'pv_temp' => pv
      }
    end

    if state.to_b
      script('set_pid_on')
      pump(1)
      return "Pump and PID are now on"
    elsif !state.to_b
      return script("set_pid_off")
    end
  end

  def sv(temp=nil)
    if temp
      return script('set_sv', temp).to_f
    end
    script('get_sv').to_f
  end

  def pv
    script('get_pv').to_f
  end

  def relay(relay, state)
    # If you try to turn the relay to a state that it is already in, this skips the wait
    if relay_status(relay).to_b == state.to_b
      return true
    end
    script("set_relay", "#{relay} #{state}")
    wait(10)
    true
  end

  def all_relays_status
    script("get_relay_status_test")
    puts @out.first.split('\n')
    @out.shift
    true
  end

  # TODO: Fix the return value here
  def relay_status(relay)
    script("get_relay_status", "#{relay}")
    if @out.include? "on"
      return "on"
    else
      return "off"
    end
  end

  # :nocov:
  def watch
    until pv >= sv do
      wait(2)
    end
    self
  end
  # :nocov:

  def rims_to(location)
    if location == "mash"
      # we ended up swapping this relay, so the name is backwards
      relay($settings['rimsToMashRelay'], 0)
    elsif location == "boil"
      relay($settings['rimsToMashRelay'], 1)
    end
    self
  end

  def hlt_to(location)
    if location == "mash"
      relay($settings['spargeToMashRelay'], 0)
    elsif location == "boil"
      relay($settings['spargeToMashRelay'], 1)
    end
    self
  end

  def hlt(state)
    if state.to_b
      relay($settings['spargeRelay'], 1)
    elsif !state.to_b
      relay($settings['spargeRelay'], 0)
    end
    self
  end

end
