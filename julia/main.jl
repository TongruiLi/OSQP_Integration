using JuMP, OSQP

SEP_CHAR = "*"
function get_variable_names(var_dict)
    """
        @param var_dict: {key: value} pair
        @return: a set of keys
    """
    key_set = Set()
    for (k, v) in var_dict
        if occursin(SEP_CHAR, k)
            # two variable case
            v1, v2 = split(k, SEP_CHAR)
            push!(key_set, v1)
            push!(key_set, v2)
        else 
            # one variable case
            push!(key_set, k)
        end
    end
    return key_set
end

function get_expr(model, var_dict, var_string_to_name)
    # construct expr for objective
    expr = @expression(model, 0)
    for (k, v) in var_dict
        if occursin(SEP_CHAR, k)
            # two variable case
            v1, v2 = split(k, SEP_CHAR)
            expr += v * var_string_to_name[v1] * var_string_to_name[v2]
        else 
            # one variable case
            expr += v * var_string_to_name[k]
        end
    end    
    return expr
end

function solve_qp(var_dict, constraint_list, warm_start_list)
    """
        @param var_dict: {key: value} pair:
            key is of "var" or "vara*varb", latter indicates that the variables are multiplied together
            value is the coefficient.
            Example:
            {"x0*x1": 5, "x0": 2, "x1": 3}
            = 5x0*x1 + 2x0 +3x1
        @param constraint_list: [[{key: value}, op, bound], ...]
            where {key: value} is a dictionary same as above. OP defines the operation, and bound defines the bound.
            Example:
            [[{"x": 2}, "<=", 3]
            2x <= 3
        @param warm_start_list: 
    """
    var_set = get_variable_names(var_dict)
    var_num = length(var_set) # number of variables
    println(var_num)

    var_string_to_name = Dict()
    model = Model(OSQP.Optimizer)
    set_silent(model)

    # initialize variable
    for name in var_set
        var = @variable(model, base_name = name)
        var_string_to_name[name] = var
    end

    obj_expr = get_expr(model, var_dict, var_string_to_name)
    for c in constraint_list
        cons_expr = get_expr(model, c[1], var_string_to_name)
        op = c[2]
        if op == ">="
            @constraint(model, cons_expr >= c[3])
        elseif op == "<="
            @constraint(model, cons_expr <= c[3])
        end
    end
    @objective(model, Min, obj_expr)
    optimize!(model)
    println(termination_status(model))
    println(value(var_string_to_name["x"]))


end
    

vars = Dict([("x", 1), ("y", 2)])
cons1 = [Dict([("x", 1)]), ">=", 0]
cons2 = [Dict([("y", 1)]), ">=", 0]

solve_qp(vars, [cons1, cons2])