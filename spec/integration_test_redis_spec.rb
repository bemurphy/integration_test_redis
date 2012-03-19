require 'rspec'

require 'integration_test_redis'

module ServerSpecHelpers
  def assert_server_running
    server_pid.should > 0
    lambda {
      Process.getpgid(server_pid)
    }.should_not raise_error
  end

  def refute_server_running
    lambda {
      Process.getpgid(server_pid)
    }.should raise_error(Errno::ESRCH)
  end

  def allow_server_grace
    sleep 0.1
  end

  def start_server
    IntegrationTestRedis.start
    allow_server_grace
  end

  def stop_server
    IntegrationTestRedis.stop && allow_server_grace
    @server_pid = nil
  end

  def server_pid
    @server_pid ||= File.read(IntegrationTestRedis::PIDFILE).to_i
  end
end

describe IntegrationTestRedis do
  include ServerSpecHelpers

  after do
    stop_server
  end

  it "acts as a singleton to protect access" do
    lambda { IntegrationTestRedis.new }.should raise_error(NoMethodError)
  end

  it "can start a redis server" do
    start_server
    assert_server_running
  end

  it "can stop the running redis server" do
    start_server
    stop_server
    refute_server_running
  end

  it "provides a working client to the server" do
    start_server
    client = IntegrationTestRedis.client
    client.del "foo"
    client.set "foo", "bar"
    client.get("foo").should == "bar"
  end

  it "doesn't persist data after stop" do
    start_server
    client = IntegrationTestRedis.client
    client.set "fizz", "buzz"
    stop_server
    start_server
    client = IntegrationTestRedis.client
    client.dbsize.should == 0
  end

  context "when the server starts and data is present" do
    it "raises IntegrationTestRedis::DatabaseNotEmpty" do
      redis = mock("redis")
      Redis.stub(:new).and_return(redis)
      redis.should_receive(:dbsize).and_return(42)
      lambda {
        start_server
      }.should raise_error(IntegrationTestRedis::DatabaseNotEmpty)
    end
  end

  # it "is killed off at exit" do
  #   pending("find a way to test this, fork it?")
  # end
end
