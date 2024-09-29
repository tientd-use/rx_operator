import 'package:rxdart/rxdart.dart';

void main() {
  // forkJoin

  final observable1 = TimerStream("hello", Duration(seconds: 1));
  final observable2 = TimerStream("world", Duration(seconds: 2));
  final observable3 = TimerStream("!!!", Duration(seconds: 3));

  // sau 3s thì fokJoin sẽ gửi ra 1 list chứa 3 giá trị của 3 observable
  // có thể đổi type String sang dynamic để chứa mọi kiểu dữ liệu
  // khi mà obvervalbe 3 đang chạy delay, thì observable 1 và 2 đã emit ra giá trị rồi, và nó phải đợi observable 3 emit ra giá trị mới thì forkJoin mới emit ra giá trị
  // forkJoin bắt buộc phải complete thì mới chạy được.
  // giá trị mà chạy sớm trong forkJoin sẽ bị nuốt vì forkJoin chỉ emit ra gi trị cuối cùng.
  // ForkJoinStream.list<String>([observable1, observable2, observable3]).listen(
  //   (data) => print(data),
  //   onDone: () => print("done"),
  //   onError: (error) => print(error),
  // );

  // ForkJoin có thể cung cấp 1 combine trước khi emit ra giá trị
  // sau khi tạo thành 1 array thì hàm combine sẽ biến đổi giá trị values trước khi emit chúng
  ForkJoinStream([observable1, observable2, observable3],
      (values) => values.join().toUpperCase());

  // giá trị value cuối cùng sẽ bị biến đổi bởi hàm combine
  // Rx forkJoin2 - forkJoin9 support
  Rx.forkJoin3(
    TimerStream(1, Duration(seconds: 1)),
    TimerStream(2, Duration(seconds: 1)),
    TimerStream(3, Duration(seconds: 1)),
    (a, b, c) => a + b + c,
  );

  // combineLatest
  // combine stream chưa chắc complete
  /// mỗi khi bất kì 1 stream nào tạo ra giá trị mới combineLatest cập nhật lại giá trị mới nhất cho stream cuối cùng.
  CombineLatestStream.list([
    Stream.periodic(Duration(seconds: 2), (index) => "Stream 1: $index"),
    Stream.periodic(Duration(seconds: 1), (index) => "Stream 2: $index"),
    Stream.periodic(Duration(seconds: 3), (index) => "Stream 3: $index"),
  ]); //.listen((data) => print("Kết quả: $data tại thời điểm: ${DateTime.now()}"));
  // Kết quả: [Stream 1: 0, Stream 2: 1, Stream 3: 0] tại thời điểm: 2024-09-29 11:04:58.424533   // tại 0-1 s
  // Kết quả: [Stream 1: 0, Stream 2: 2, Stream 3: 0] tại thời điểm: 2024-09-29 11:04:58.427318   // tại 1-2 s
  // Kết quả: [Stream 1: 1, Stream 2: 2, Stream 3: 0] tại thời điểm: 2024-09-29 11:04:59.416926   // tại 2-3 s
  // Kết quả: [Stream 1: 1, Stream 2: 3, Stream 3: 0] tại thời điểm: 2024-09-29 11:04:59.417296   // tại 2-3 s
  // Kết quả: [Stream 1: 1, Stream 2: 4, Stream 3: 0] tại thời điểm: 2024-09-29 11:05:00.417724   // tại 3s
  // Kết quả: [Stream 1: 2, Stream 2: 4, Stream 3: 0] tại thời điểm: 2024-09-29 11:05:01.416185   // tại 4s
  // Kết quả: [Stream 1: 2, Stream 2: 4, Stream 3: 1] tại thời điểm: 2024-09-29 11:05:01.416306   // tại 4s
  // Kết quả: [Stream 1: 2, Stream 2: 5, Stream 3: 1] tại thời điểm: 2024-09-29 11:05:01.416342
  // Kết quả: [Stream 1: 2, Stream 2: 6, Stream 3: 1] tại thời điểm: 2024-09-29 11:05:02.418086

  // Zip
  // ghép các cặp stream
  // ghép cặp event

  ZipStream.list([
    Stream.fromIterable([1, 2, 3]),
    Stream.fromIterable([4, 5, 6]),
    Stream.fromIterable([7, 8, 9]),
  ]); //.listen((value) => print(value));

  final age$ = Stream.fromIterable([15, 25, 30]);
  final name$ = Stream.fromIterable(["Tien", "Duc", "Tran"]);
  final isMale$ = Stream.fromIterable([true, false, true]);

  ZipStream.list([age$, name$, isMale$]).map((value) => {
        "age": value[0],
        "name": value[1],
        "isMale": value[2],
      });
  //.listen((value) => print(value));
  // [15, Tien, true]
  // [25, Duc, false]
  // [30, Tran, true]

  // concat
  // đợi tất cả các stream hoàn thành mới complete

  // thứ tự là quan trọng
  ConcatStream([
    Stream.periodic(Duration(seconds: 1), (index) => index).take(3),
    Stream.periodic(Duration(milliseconds: 500), (index) => index).take(5),
  ]); //.listen((value) => print(value));

  // Merge
  // Observable sẽ emit thì merge sẽ emit luôn
  // không quan tâm thứ tự
  MergeStream([
    Stream.periodic(Duration(seconds: 1), (index) => "first ${index}").take(3),
    Stream.periodic(Duration(milliseconds: 500), (index) => "second ${index}")
        .take(5),
  ]); //.listen((value) => print(value));

  // Race
  // emit giá trị của stream nào emit trước
  // giá trị của stream sau sẽ bị bỏ qua
  // nhanh thì emit trc  first sẽ bị bỏ qua  trong case dưới.
  RaceStream([
    Stream.periodic(Duration(seconds: 1), (index) => "first : ${index}")
        .take(3),
    Stream.periodic(Duration(milliseconds: 500), (index) => "second : ${index}")
        .take(5),
  ]); //.listen((value) => print(value));

  // withLatestFrom

  // lấy giá trị cuối cùng của stream other khác, tại thời điểm source emit (xảy ra)
  final source =
      Stream.periodic(Duration(seconds: 10), (index) => index).take(1);
  final other = Stream.periodic(
          Duration(seconds: 1), (index) => "need lastest from value ${index}")
      .take(5);

  source.withLatestFrom(
      other, (source, other) => "Source : ${source}, other : ${other}");
  // .listen(
  //   (value) => print(value),
  // );

  // startWith
  // emit sẵn 1 giá trị trước khi emit giá trị từ stream sau
  // stream trong startWith đc coi là base stream, tức stream init

  // emit bắt đầu từ -1
  final per =
      Stream.periodic(Duration(seconds: 1), (index) => "outer obs ${index}")
          .startWith("start with value");
  // .listen(
  //       (value) => print(value),
  //     );
  //

  // mergeAll, concatAll, switchAll
  per.concatWith([
    Stream.periodic(Duration(seconds: 1), (index) => "inner obs ${index}")
  ]).listen((val) => print(val));
}

class ApiResponse<T> {
  final T? data;
  final bool isLoading;
  final String error;

  ApiResponse({
    required this.data,
    required this.isLoading,
    required this.error,
  });

  Stream<ApiResponse<T>> getApiResult<T>(Stream apiCall) {
    return apiCall
        .startWith(ApiResponse<T>(data: null, isLoading: true, error: ""))
        .map((data) => ApiResponse<T>(data: data, isLoading: false, error: ""))
        .handleError((error) => ApiResponse<T>(
            data: null, isLoading: false, error: error.toString()));
  }
}
