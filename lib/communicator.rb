require_relative "autoload"

class Communicator

  attr_accessor :slack, :brewer

  def initialize
    @slack = configure_slack
    @brewer = Brewer.new
  end

  def configure_slack
    slack_file = Dir.home + "/.brewer/.slack.yml"
    if !File.file?(slack_file)
      store = YAML::Store.new slack_file
      print "Enter your Slack webhook url: "
      webhook_url = gets.chomp
      store.transaction { store['webhook_url'] = webhook_url }
    end
    return Slack::Notifier.new YAML.load(File.open(slack_file))['webhook_url']
  end

  def ping(message="ping at #{Time.now}")
    if message.is_a? Array
      final = message.join("\n")
      @slack.ping(final)
    end
    @slack.ping(message)
  end

  # TODO: test these methods
  def slack_monitor(delay=10)
    while true do
      before_temp = @brewer.pv
      @brewer.wait(to_seconds(delay))
      diff = @brewer.pv - before_temp

      ping([
        "Current Temperature: #{@brewer.pid['pv_temp']} F",
        "Set Value Temperature: #{@brewer.pid['sv_temp']} F",
        "Current temperature has climed #{diff} F since #{delay} minute(s) ago",
        "Sent at #{Time.now.strftime("%H:%M")}",
        ""
      ])
    end
    true
  end

  def monitor
    while true do
      status_table_rows = [
        ["Item", "Status"],
        ["Current Temp", @brewer.pv],
        ["Set Value Temp", @brewer.sv],
        ["PID is: ", @brewer.pid['pid_running'].to_b ? "on" : "off"]
        ["Pump is: ", @brewer.pump]
      ]

      status_table = Terminal::Table.new :rows => status_table_rows

      clear_screen
      puts status_table
      sleep(1)
    end
  end

end
