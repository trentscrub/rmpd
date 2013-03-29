class NilHash < Hash

  def method_missing(name, *args, &block)
    super
  rescue NoMethodError
    if 0 == args.size
      self[name]
    end
  end

end
