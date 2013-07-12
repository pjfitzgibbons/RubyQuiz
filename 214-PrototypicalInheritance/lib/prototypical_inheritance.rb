module PrototypicalInheritance
  module Hash::Prototype
    def prototype=(value)
      @persisted_method_missing = false
      self.replace(value.merge(self))
    end

    def persisted_prototype=(value)
      @persisted_method_missing = true
      self.replace(value.merge(self))
    end

    def method_missing(symbol, *args, &block)
      ## courtesy of http://www.goodercode.com/wp/convert-your-hash-keys-to-object-properties-in-ruby/
      if @persisted_method_missing then
        Hash.send :define_method, symbol do
          return self[symbol] if key? symbol
          return self[symbol.to_s] if key? symbol.to_s
          return nil
        end
      else
        return self[symbol] if key? symbol
        return self[symbol.to_s] if key? symbol.to_s
        return nil
      end
    end

  end

  Hash.send :include, Hash::Prototype

end