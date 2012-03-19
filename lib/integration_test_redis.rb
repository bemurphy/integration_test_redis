require "singleton"
require "tempfile"
require "redis"

class IntegrationTestRedis
  include ::Singleton

  class DatabaseNotEmpty < RuntimeError
    def initialize(msg = "Database not empty, aborting!")
      super
    end
  end

  PORT    = 9737
  PIDFILE = Tempfile.new('integration-test-redis-pid')
  DIR     = Dir.mktmpdir('integration-test-redis')

  def self.start
    instance.start
  end

  def self.stop
    instance.stop
  end

  def self.client
    instance.client
  end

  def start
    install_at_exit_handler
    system("echo '#{options}' | redis-server -")
    sleep 0.1 # allow a grace period for starting
    enforce_empty_db
    true
  end

  def stop
    pid = File.read(PIDFILE).to_i
    return false unless pid > 0

    begin
      !! Process.kill("QUIT", pid)
    rescue Errno::ESRCH
      false
    end
  end

  def client
    ::Redis.new(:port => PORT, :db => 15)
  end

  private

  def options
    {
      'daemonize' => 'yes',
      'pidfile'   => PIDFILE.path,
      'bind'      => '127.0.0.1',
      'port'      => PORT,
      'timeout'   => 300,
      'dir'       => DIR,
      'loglevel'  => 'debug',
      'logfile'   => 'stdout',
      'databases' => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
  end

  def enforce_empty_db
    raise DatabaseNotEmpty unless client.dbsize == 0
  end

  def install_at_exit_handler
    at_exit {
      IntegrationTestRedis.instance.stop
    }
  end
end
