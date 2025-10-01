server.get("/path/to/route", method, []const Middleware);
server.get("/users", getUsers, &.{});
server.post("/users", addUser, &.{});
server.delete("/users", deleteUser, &.{});
