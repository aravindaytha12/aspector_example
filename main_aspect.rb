$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'aspector'
require 'logger'
require 'date'

Logger.new('application_test.log', 20, 'daily') 
$LOG = Logger.new('log_file_test.log', 'daily')
$LOG.formatter = proc do |severity, datetime, progname, msg|
  "#{msg}\n"
end


class LoggingAspect < Aspector::Base
  ALL_METHODS = /.*/
  #ALL_CLASSES = /.*/
  around ALL_METHODS, method_arg: true do |method, proxy, *args, &block|
    class_method = "#{self.class} :: #{method}"
    cur_date = Time.now
    my_thread_id = Thread.current.object_id

    $LOG.debug("#{DateTime.now.strftime('%Q')} :: #{my_thread_id} :: #{class_method} :: STARTED")
    cur_date1 = Time.now
    result = proxy.call(*args, &block)
    $LOG.debug("#{DateTime.now.strftime('%Q')} :: #{my_thread_id} :: #{class_method} :: ENDED")
    result
  end
end