server.addRoute("/path/to/route", "METHOD", method, []const Middleware);
server.addRoute("/users", "GET", getUsers, &.{});
