include("./main.jl")

using Sockets
using JSON
using .solver
# adapted from http://blog.leahhanson.us/post/julia/julia-sockets.html
function start_server(port)
    server = listen(port)
    while true
    conn = accept(server)
    @async begin
        try
        while true
            line = readline(conn)
            j = JSON.parse(line)
            print(j)
            results = solve_qp(j["objective"], j["constraints"])
            json_result = JSON.json(results)
            write(conn, json_result)
        end
        catch err
        print("connection ended with error $err")
        end
    end
    end
end


start_server(8081)