
import benchmark

from src.engine_utils import Vec2


alias size: Int = 1_000_000


fn create_vec_list(size: Int) -> List[Vec2]:
    var vec_list = List[Vec2]()

    for i in range(size):
        vec_list.append(Vec2(i, i))
    return vec_list


fn test_getitem():
    var vec_list = create_vec_list(size)
    for vec in vec_list:
        _ = vec[][0]
        _ = vec[][1]


fn test_getattr():
    var vec_list = create_vec_list(size)
    for vec in vec_list:
        _ = vec[].x
        _ = vec[].y


fn main():
    # var report1 = benchmark.run[test_getitem]()
    # var report2 = benchmark.run[test_getattr]()

    # report1.print()
    # report2.print()


    var vec = Vec2(2,3)

    print(vec.x, vec.y)

    # vec.x = Float32(3)

    print(vec.e)



