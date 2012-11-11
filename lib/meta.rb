# @author Paul McKibbin based on meta definitions by _why_the_lucky_stiff_
module Meta
  def meta_self
    class << self
      self
    end
  end

  def meta_def name, &blk
    meta_self.instance_eval { define_method name, &blk }
  end
end
