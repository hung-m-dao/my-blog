---
date: 2022-03-24 16:55
description: Go interface - The distinction makes the power and grace of Go
tags: Vietnamese, Golang, Go, Go-Interface, ThaoPosts
---
# GO INTERFACE

Giống như các ngôn ngữ lập trình khác, nơi mà chúng ta đều có thể tìm kiếm những khái niệm liên quan đến “Interface", với những ngôn ngữ hướng đối tượng kiểu tĩnh như Java, C# … thì cũng chính là interface, vơi những ngôn ngữ kiểu động thì có một khái niệm gần sát là “Duck Tying". Go interface cũng mang trong mình những đặc tính đó, nếu hiểu interface trong Java là “explicit interface" thì đối với Go nó là “implicit interface", trên hệ quy chiếu của các ngôn ngữ kiểu động thì có thể gọi Go Interface là Type-Safe Duck Typing. Điều đó nói lên điều gì ? Go không nghiêng về hẳn về một bên nào, mà ngược lại như một kẻ trung lập đứng ở giữa và chấp nhận quan điểm của cả hai trường phái, điều đó giúp cho Interface trong Go trở nên thật mạnh mẽ nhưng cũng thật tao nhã.

## 1. Interface là gì và nó đang tồn tại như thể nào ?
Để định nghĩa chính xác interface là gì không hề dễ, đây là một khái niệm gây confuse và được mô tả khác nhau ở các ngôn ngữ. Nhưng nó vẫn dựa trên một nền tảng chung nó là một kiểu thể hiện sự tổng quát hóa và trừu tượng hóa dựa trên các hành vi của các kiểu khác. Để hiểu rõ hơn ở đây mình sẽ dùng interface ở trong Java và Duck Typing trong python để làm rõ vấn đề ở trên ở mức độ ngôn ngữ

### 1.1 Java Interface là Explicit Interface
```java
public interface Writer {
    void write(String data);
}

public class FileWriter implements Writer {
    public void write(String data) {
    // write string data to text file 
    }
}

public class Client {
    private final Writer writer;
    // this type is the interface, not the implementation

    public Client(Writer writer) {
      this.writer = writer;
    }

    public void program() {
        // get data from somewhere
        this.writer.write(data);
    }
}

public static void main(String[] args) {
    Writer writer = new FileWriter();
    Client client = new Client(writer);
    client.program();
}
```

* Trong Java khi một class muốn hiện thực một interface, thì cần phải đặc tả một cách “explicit" interface mà class đó muốn hiện thực. 
* Điều này có ưu điểm là tính readability cao giúp cho mọi người có thể nhanh chóng nắm bắt code đang muốn nói gì và đặc biệt với những người mói tiếp cận project. 
* Nhưng có một nhược điểm là tính flexible, chính vì việc cần đặc tả interface mà một class đang implement sẽ dẫn đến việc refactor code sẽ không hề dễ dàng hay có thể nói là khó khăn khi ứng dụng của chúng ta phát triển và thay đổi theo thời gian. Có thể nhìn vào đoạn code trên, giả sử chúng ta đang có `Writer` interface được import từ một thư viện vào đó, và tại thời điểm quyết định dùng nó mọi thứ rất tuyệt vời. Một thời gian sau, chúng ta có thêm requirement rằng hệ thống cần phải thêm chức năng ghi dữ liệu ra file .proto (một loại file mới xuất hiện gần đây) mà thư viện của writer interface chưa support. Vậy giải pháp ở đây là gì ? Chúng ta cần một thư viện mới hiện đại hơn có thể dùng được cho các loại file mới hơn và cũng như support các loại file đã tồn tại ở trong `Writer`, mình tạm gọi nó là `ModernWriter` interface. Tưởng chừng bài toán đã được giải quyết nhưng thật không may, nếu chuyển qua sử dụng thư viện mới này thì các đoạn code liên quan đến client cần phải được refactor để chuyển sang sử dụng interface mới hay có thể nói một cách vĩ mô hơn là client đang phụ thuộc vào các dependencies điều này đang đi ngược với nguyên tác Dependency Inversion của Uncle Bob trong SOLID, vì mỗi lần ta cần chuyển sang sử dụng thư viện mới ta lại phải can thiệp vào code của client và đó không phải là một ý kiến hay, vậy câu hỏi được đặt ra ở đây là có cách nào để giải quyết bài toán này một cách dễ dàng nhất trong Java ?

### 1.2 Duck Typing với Python
Duck Typing rất phổ biến trong các ngôn ngữ kiểu động, nó được định nghĩa là một phương pháp lập trình từ ý tưởng của duck test ("If it looks like a duck, swims like a duck, and quacks like a duck, then it probably is a duck" - tạm dịch là nếu một thứ nào đó trông giống một con vịt, bơi như một con vịt, và kêu quạc quạc như vịt thì nó có thể là một con vịt). Nó có nghĩa việc lập trình của chúng ta bây giờ sẽ hướng tới hành vi của đối tượng hơn là kiểu của chúng. Vậy để hiểu rõ hơn về duck typing, mình sẽ dùng chính ví dụ ở trên được viết lại bằng Python để minh họa rõ hơn

```python
class FileWriter:
    def write():
        #TODO: write string data to text file

class Client:
    def __init__(self, writer):
        self.writer = writer

    def program():
        # get data from somewhere
        self.writer.write(data);

file_writer = FileWriter()
client = Client(file_writer)
client.program()
```

Qua đoạn code trên ta có thể thấy rõ việc ngôn ngữ sử dụng duck-typing không hề quan tâm đến type của `writer` là gì,  nó sẽ cố gắng tìm xem `writer` object được truyền vào có hiện thực method `write` hay không và tiến hành gọi hàm. Nghe tới đây thì ta có thể nhận ra rằng Python nói riêng và các ngôn ngữ kiểu động có thể dễ dàng giải quyết vấn đề mà các ngôn ngữ kiểu tĩnh như Java ở phần trước đã gặp phải ngay trong code. Quay lại requirement được thêm vào ở phần trên, ta cần thêm chức năng ghi ra file `.proto`, với python ta chỉ cần dễ dàng thêm (import) thư viện mà ta muốn dùng để ghi file `.proto` và truyền nó vào constructor của `Client` khi cần sử dụng.

```python
class ProtoFileWriter:
    def write():
        #TODO: write string data to .proto file

# handle for .proto file writing
proto_file_writer = ProtoFileWriter()
client = Client(proto_file_writer)
client.program()
```

Nhưng không có gì là hoàn hảo, vấn đề của duck typing chính là type safeguard, vì nó không quan tâm đến kiểu của object mà thay vào đó là cố gắng đi tìm xem method đó có được hiện thực bởi object cho trước tại thời điểm runtime dẫn đén trường hợp một object gọi một method không được định nghĩa cùng với kiểu của nó sẽ dẫn tới bug. Cùng với ví dụ trên, giả sử một anh lập trình viên nào đó cũng tìm được một thư viện khác hỗ trợ việc ghi ra file proto nhưng lại không đọc kỹ docs hay vì một lý do nào đó không biết hàm mà thư viện đó cung cấp tên là `write_to_proto` chẳng hạn thay vì `wirte` nên dẫn đến chương trình bị lỗi. Điều này rất nguy hiểm vì chúng ta không có cách nào nhận ra dễ dàng tại thời điểm compile vì nó chỉ xảy ra tại thời điểm runtime, chưa kể nếu những đoạn code này không được test một cách kỹ càng thì thật sự nó sẽ thành thảm họa.

```python
class OtherProtoFileWriter:
    def write_to_proto():
        #TODO: write string data to .proto file
        
# handle for .proto file writing
proto_file_writer = OtherProtoFileWriter()
client = Client(proto_file_writer)
client.program() # <-- crashed here at runtime
```

## 2. Go Interface
Trong phần trước chúng ta đã có cái nhìn tổng thể về sự hiện diện của interface trong các ngôn ngữ lập trình như thế nào. Go cũng không phải là một ngoại lệ, vì Go được ra đời sau nên nó thừa kế được những điểm mạnh của các ngôn ngữ đi trước. Go chấp nhận cả hai tư tưởng ở trên vì rõ ràng các trường hợp đó xuất hiện hằng ngày trong lúc chúng ta lập trình. Vậy Go đã đưa ra giải pháp thế nào cho việc tận dụng điểm mạnh của cả hai ? Và đó là lúc implicit interface xuất hiện

### 2.1 Go Interface là Implicit Interface
