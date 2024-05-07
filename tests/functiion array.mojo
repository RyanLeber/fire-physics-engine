





fn main():

    @parameter
    fn print_0():
        print(0)

    @parameter
    fn print_1():
        print(1)

    @parameter
    fn print_2():
        print(2)

    @parameter
    fn print_3():
        print(3)

    @parameter
    fn print_4():
        print(4)

    var demos = List[fn() capturing -> None](print_0, print_1, print_2, print_3, print_4)
    # alias demos = List(print_0, print_1)

    @parameter
    fn call_fn(i: Int):
        var demo = demos[i]

        demo()


    call_fn(2)

    # _ = demos
    _ = print(0)
    _ = print_1
    _ = print_2