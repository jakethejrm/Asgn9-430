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

class newEnv #had to be called newEnv because calling it env prevented env(new_bindings) from working, i think because env was already in scope by inter(a, env)
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

class ClosV
    var args, body, env
    def init(args, body, env)
        self.args = args
        self.body = body
        self.env = env
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
        return ClosV(a.args, a.body, env)
	elif classof(a) == AppC
		var val = interp(a.fun, env)
		if isinstance(val, ClosV)
			if size(val.args) == size(a.args)
                var new_bindings = list()
                for i : range(0, val.args.size() - 1)
					var arg_value = interp(a.args[i], env)
                    new_bindings.push(Binding(val.args[i], arg_value))
				end

				if(isinstance(val.env, newEnv)) #if lambsa are nested val.env is recognized as a "newEnv" class
					for binding : val.env.bindings
						new_bindings.push(binding)
					end
				else  #otherwise its recognized as a list (despite interp being called with a "newEnv" class ???) 
					for binding : val.env
						new_bindings.push(binding)
					end
				end

                var new_env = newEnv(new_bindings)
                return interp(val.body, new_env)
            else
                return env.lookup('error')
			end
		elif isinstance(val, Primop)
			return val.call(interp(a.args[0], env), interp(a.args[1], env))
		end
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
	
var my_env = newEnv(top_env) #initialize top env

var add_test = AppC(IdC('+'), [NumC(2), NumC(3)])
print("add test", interp(add_test, my_env)) # 5

var sub_test = AppC(IdC('-'), [NumC(5), NumC(3)])
print("sub test", interp(sub_test, my_env)) # 2

var mult_test = AppC(IdC('*'), [NumC(4), NumC(3)])
print("mult test", interp(mult_test, my_env))  # 12

var div_test = AppC(IdC('/'), [NumC(10), NumC(2)])
print("div test", interp(div_test, my_env))  # 5

var ifc_t = IfC(AppC(IdC('equal?'), [NumC(5), NumC(5)]), NumC(10), NumC(20))
print("ifc #t test", interp(ifc_t, my_env))  # 10

var ifc_f = IfC(AppC(IdC('equal?'), [NumC(5), NumC(7)]), NumC(10), NumC(20))
print("ifc #f test ", interp(ifc_f, my_env))  # 20

var gre_t = IfC(AppC(IdC('<='), [NumC(10), NumC(7)]), NumC(10), NumC(20))
print("<= #t test", interp(gre_t, my_env))  # 20

var gre_f = IfC(AppC(IdC('<='), [NumC(5), NumC(7)]), NumC(10), NumC(20))
print("<= #f test", interp(gre_f, my_env))  # 10

var bool_t = IfC(IdC('true'), NumC(10), NumC(20))
print("#t test", interp(bool_t, my_env))  # 10

var bool_f = IfC(IdC('false'), NumC(10), NumC(20))
print("#f test", interp(bool_f, my_env))  # 20

var lam_func = LamC(['x'], IdC('x'))
var lam_app = AppC(lam_func, [NumC(5)])
print("lam test", interp(lam_app, top_env)) # 5

var mult_lam = LamC(['x', 'y'], AppC(IdC('*'), [IdC('x'), IdC('y')]))
var mult_app = AppC(mult_lam, [NumC(3), NumC(4)])
print("mult lam test", interp(mult_app, top_env)) # 12

var cond_lam = LamC(['x'], IfC(AppC(IdC('<='), [IdC('x'), NumC(10)]), NumC(1), NumC(0)))
var cond_app_t = AppC(cond_lam, [NumC(5)])
print("cond lam test #t", interp(cond_app_t, top_env)) # 1

var cond_app_f = AppC(cond_lam, [NumC(15)])
print("cond lam test #f", interp(cond_app_f, top_env)) # 0

var nested_lam = LamC(['x'], LamC(['y'], AppC(IdC('+'), [IdC('x'), IdC('y')])))
var nested_app = AppC(AppC(nested_lam, [NumC(5)]), [NumC(3)])
print("nested lam test", interp(nested_app, top_env)) # 8

