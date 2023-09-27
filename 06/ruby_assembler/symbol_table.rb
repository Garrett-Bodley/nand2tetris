class SymbolTable

  def initialize()
    @dict = {
      "SP" => 0,
      "LCL" => 1,
      "ARG" => 2,
      "THIS" => 3,
      "THAT" => 4,
      "R0" => 0,
      "R1" => 1,
      "R2" => 2,
      "R3" => 3,
      "R4" => 4,
      "R5" => 5,
      "R6" => 6,
      "R7" => 7,
      "R8" => 8,
      "R9" => 9,
      "R10" => 10,
      "R11" => 11,
      "R12" => 12,
      "R13" => 13,
      "R14" => 14,
      "R15" => 15,
      "SCREEN" => 16384,
      "KBD" => 24576
    }
    @new_var_address = 16
  end

  def add_variable(string)
    raise `Error: Provided variable name has already been used\nAttempted Add String: #{string}` if self.contains(string)
    @dict[string] = Integer(@new_var_address)
    @new_var_address += 1
    self.get_address(string)
  end

  def add_label(string, address)
    raise `Error: Provided label name has already been used\nAttempted Add String: #{string}` if self.contains(string)
    @dict[string] = Integer(address)
    self.get_address(string)
  end

  def contains(string)
    @dict.include?(string)
  end

  def get_address(string)
    raise "Provided string was not found in the SymbolTable (Provided string: #{string})" unless self.contains(string)
    @dict[string]
  end

  def get_binary_address(string)
    address = self.get_address(string)
    address.to_s(2).rjust(15, "0")
  end
end
