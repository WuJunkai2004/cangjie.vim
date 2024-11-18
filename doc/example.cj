class console {
    static public func say(msg: String): String{
        const hello = "Hello, ";
        return hello + msg;
    }
    init(){
        println("Console initialized");
    }
    ~init(){
        println("Console destroyed");
    }
    public func sayHello(): Unit{
        println("Hello, World!");
    }
    public func log<T>(msg: T): Unit{
        println((msg as String)??"Converted failed");
    }
}


main(){
    let printer = console();
    printer.sayHello();
    printer.log("Hello, World 2");
    printer.log("你好，世界");
    printer.log(123);
    printer.log('你');
    printer.log('uua"ad\'');
    if(console.say("World") == "Hello, World"){
        println("Test passed");    
    } else {
        println("Test failed");
    }
    printer.
}
