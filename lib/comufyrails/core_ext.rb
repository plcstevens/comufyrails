
String.class_eval do
  def to_comufy_time
    time = DateTime.parse(self)
    time.strftime("%Y-%m-%d %H:%M:%S")
  end
end

DateTime.class_eval do
  def to_comufy_time
    self.strftime("%Y-%m-%d %H:%M:%S")
  end
end

if defined?(Rails) and defined?(ActiveSupport)
  ActiveSupport::TimeWithZone.class_eval do
    def to_comufy_time
      self.strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
