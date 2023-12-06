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

class LamC : ExprC
	var args, body
	def init(args, body)
		self.args = args
		self.body = body
	end
end

class Binding
	var name, val
	def init(name, val)
		self.name = name
		self.val = val
	end
end

class env 
	var bindings
	def init(bindings)
		self.bindings = bindings
	end
end

class mt-env
	var bindings
	def init()
		self.bindings = nil
	end 
end

class Primop
    var op_func

    def init(op)
        if op == 'Add' then
            self.op_func = Add
        elif op == 'Sub' then
            self.op_func = Sub
        elif op == 'Mult' then
            self.op_func = Mult
        elif op == 'Div' then
            self.op_func = Div
        elif op == 'LessEq' then
            self.op_func = LessEq
        elif op == 'Eq' then
            self.op_func = Eq
        elif op == 'error' then
            self.op_func = ErrorOp
        end
    end

    def call(l, r)
        return self.op_func(l, r)
    end
end

var top_env = list(
    Binding('+', Primop("Add")),
    Binding('-', Primop("Sub")),
    Binding('*', PrimopC("Mult")),
    Binding('/', PrimopC('Div')),
    Binding('<=', PrimopC('LessEq')),
    Binding('equal?', PrimopC('Eq')),
    Binding('true', BoolV(true)), #need to handle these
    Binding('false', BoolV(false)), #this
    Binding('error', PrimopC('error'))
)


def Add(l, r)
	return l + r;
end
def Sub(l, r)
	return l - r; 
end
def Mult(l, r)
	return l * r;
end
def Div(l, r)
	if r !== 0
		return l / r;
	#handle error
	end
end
end
def LessEq(l, r)
	return l <= r;
end
def Eq(l, r)
	return l = r;
end



# All chat below - should be looked at 
def interp(a, env)
	if type(a) == NumC.type
		return a.n
	elif type(a) == LamC.type
		return {'args': a.args, 'body': a.body, 'env': env}
	elif type(a) == AppC.type
		var val = interp(a.fun, env)
		if type(val) == 'table'  # Assuming closures are represented as tables
			var arg_values = list.map(a.args, def (arg) return interp(arg, env) end)
			if size(val['args']) == size(arg_values)
				var new_env = env + list.zip(val['args'], arg_values)  # Simplified environment handling
				return interp(val['body'], new_env)
			else
				# Handle error
			end
		elif val.contains('op') 
			var arg_values = list.map(a.args, def (arg) return interp(arg, env) end)
        	return primop_execute(val['op'], arg_values)
		end
	elif type(a) == IfC.type
		var result = interp(a.a, env)
		if type(result) == 'boolean'
			if result
				return interp(a.t, env)
			else
				return interp(a.f, env)
			end
		else
			# Handle error
		end
	elif type(a) == IdC.type
		# Implement lookup logic for identifiers
	else
		# Handle error for unrecognized types
	end
end
	

var lam = LamC(['x'], ((PrimopC "+") (IdC('x'), NumC(1))))
var app = AppC(lam, [NumC(2)])
print(interp(app, {}))
