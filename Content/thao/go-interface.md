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
``` java

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
* Nhưng có một nhược điểm là tính flexible, chính vì việc cần đặc tả interface mà một class đang implement sẽ dẫn đến việc refactor code sẽ không hề dễ dàng hay có thể nói là khó khăn khi ứng dụng của chúng ta phát triển và thay đổi theo thời gian. Có thể nhìn vào đoạn code trên giả sử chúng ta đang có Writer Interface import từ một thư viện vào đó, và tại thời điểm chúng ta quyết định dùng nó mọi thứ rất tuyệt vời. Sau đó một thời gian chúng ta có thêm requirement rằng tôi muốn ghi dữ liệu ra file .proto (một loại file mới xuất hiện gần đây) mà class FileWriter chưa support, vậy bây giờ làm sao để chúng ta có thể hiện thực được hàm ghi ra file .proto nhưng vẫn tận dụng được interface hiện có, ức là ở class Client chúng ta không cần phải thay đổi bất kỳ một dòng code nào ?

### 1.2 Python Duck Typing