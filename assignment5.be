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

	def lookup(name)
        for b : self.bindings
            if b.name == name 
                return b.val
			end
		end
        return nil 
    end
end

class mtEnv
	var bindings
	def init()
		self.bindings = nil
	end 
end

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
	if r != 0
		return l / r;
	else
		#handle error
	end
end

def LessEq(l, r)
	return l <= r;
end

def Eq(l, r)
	return l == r;
end

def ErrorOp()
	return #handle error
end

class Primop
    var op_func
    def init(op)
        if op == 'Add' 
            self.op_func = Add
        elif op == 'Sub' 
            self.op_func = Sub
        elif op == 'Mult' 
            self.op_func = Mult
        elif op == 'Div' 
            self.op_func = Div
        elif op == 'LessEq' 
            self.op_func = LessEq
        elif op == 'Eq' 
            self.op_func = Eq
        elif op == 'error' 
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
    Binding('*', Primop("Mult")),
    Binding('/', Primop('Div')),
    Binding('<=', Primop('LessEq')),
    Binding('equal?', Primop('Eq')),
    Binding('true', true),
    Binding('false', false), 
    Binding('error', Primop('error'))
)

def interp(a, env)
	if classof(a) == NumC
		return a.n
	elif classof(a) == LamC
		#Needs handling
		return
	elif classof(a) == AppC
		var val = interp(a.fun, env)
		if isinstance(val, Primop)
			return val.call(interp(a.args[0]), interp(a.args[1]))
		end
		#Also handle closure
	elif classof(a) == IfC
		var result = interp(a.a, env)
		if type(result) == "bool"
			if result
				return interp(a.t, env)
			else
				return interp(a.f, env)
			end
		else
			# Handle error for if not boolean
		end
	elif classof(a) == IdC
		return env.lookup(a.sym)
	else
		# Handle error for bad type
	end
end
	
var my_env = env(top_env) #initialize top env

#add tests

var add_test5 = AppC(IdC('+'), [NumC(2), NumC(3)])
print("add test0", interp(add_test5, my_env)) # 5

var add_test0 = AppC(IdC('+'), [NumC(0), NumC(0)])
print("add test0", interp(add_test0, my_env)) # 0

var add_test99999 = AppC(IdC('+'), [NumC(99999), NumC(99999)])
print("add test199998", interp(add_test99999, my_env)) # 199998


#sub tests

var sub_test2 = AppC(IdC('-'), [NumC(5), NumC(3)])
print("sub test2", interp(sub_test2, my_env)) # 2

var sub_test3 = AppC(IdC('-'), [NumC(0), NumC(3)])
print("sub test-3", interp(sub_test3, my_env)) # -3

var sub_test0 = AppC(IdC('-'), [NumC(0), NumC(0)])
print("sub test0", interp(sub_test0, my_env)) # 0

# mult tests

var mult_test12 = AppC(IdC('*'), [NumC(4), NumC(3)])
print("mult test12", interp(mult_test12, my_env))  # 12

var mult_test0 = AppC(IdC('*'), [NumC(0), NumC(0)])
print("mult test0", interp(mult_test0, my_env))  # 0

var mult_test6 = AppC(IdC('*'), [NumC(3), NumC(-2)])
print("mult test6", interp(mult_test6, my_env))  # -6

#div tests

var div_test = AppC(IdC('/'), [NumC(10), NumC(2)])
print("div test", interp(div_test, my_env))  # 5

var div_test0 = AppC(IdC('/'), [NumC(10), NumC(0)])
print("div test0", interp(div_test0, my_env))  # nil

var div_test5 = AppC(IdC('/'), [NumC(10), NumC(-2)])
print("div test5", interp(div_test5, my_env))  # -5


#if tests

var ifc_t = IfC(AppC(IdC('equal?'), [NumC(5), NumC(5)]), NumC(10), NumC(20))
print("ifc #t test", interp(ifc_t, my_env))  # 10

var ifc_f = IfC(AppC(IdC('equal?'), [NumC(5), NumC(7)]), NumC(10), NumC(20))
print("ifc #f test ", interp(ifc_f, my_env))  # 20

#gre tests

var gre_t = IfC(AppC(IdC('<='), [NumC(10), NumC(7)]), NumC(10), NumC(20))
print("<= #t test", interp(gre_t, my_env))  # 20

var gre_f = IfC(AppC(IdC('<='), [NumC(5), NumC(7)]), NumC(10), NumC(20))
print("<= #f test", interp(gre_f, my_env))  # 10

#bool tests

var bool_t = IfC(IdC('true'), NumC(10), NumC(20))
print("#t test", interp(bool_t, my_env))  # 10

var bool_f = IfC(IdC('false'), NumC(10), NumC(20))
print("#f test", interp(bool_f, my_env))  # 20