#! ./berry


class ExprC	
	end

class NumC : ExprC
	var n
	def init(n)
        self.n = n
		end
	end
	
class StrC : ExprC
	var s
	def init(s)
        self.s = s
		end
	end
	
class AppC : ExprC
	var args
	var fun
	def init(fun, args)
		self.fun = fun
		self.args = args
		end
	end
	
class IdC : ExprC
	var sym
	def init(sym)
		self.sym = sym
		end
	end
	
class IfC : ExprC
	var a, t, f
	def init(a, t, f)
		self.a = a
		self.f = f
		self.t = t
		end
	end

object = NumC(5)
print(object.n)