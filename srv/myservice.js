const myservice = function(srv){
    srv.on('hello',(req) => {
        return "HELLO" + req.data.to + "!";
    });
}
module.exports = myservice;