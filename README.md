# Distributed-Project
Phát triển phần mềm phân tán.
App nhắn tin (messenger)
Chức năng: 
> - Nhắn tin realtime 1 - 1.
> - Push notification.
> - Video call 1 - 1.
> - Gửi tin nhắn với các định dạng text, png, jpg,..

Công nghệ sử dụng
> - WebRTC, vapor swift on server-side, swift.
> - IDE: Xcode(App), visual studio (Server).

IDE: Build app và server trên Xcode 12.0.
Folder App: app iOS.
Folder Social-Messaging-Server: Server, Database.

Hướng dẫn build docker image:
> ## Note: This file is intended for testing and does not
> ## implement best practices for a production deployment.
> ##
> ## Learn more: https://docs.docker.com/compose/reference/
> ##
> ##   Build images: docker-compose build
> ##      Start app: docker-compose up app
> ## Start database: docker-compose up db
> ## Run migrations: docker-compose run migrate
> ##       Stop all: docker-compose down (add -v to wipe db)

Hướng dẫn build app. (Yêu cầu máy có phần mềm Xcode)
> 1. Clone link git
> 2. Mở file có extend: .xcodeproj
> 3. Chọn simulator và run.

Hướng dân build server. (Tham khảo: https://swift.org/package-manager/)
(Yêu cầu: MacOS, ubuntu)
> 1. cd vào folder Social-Messaging-Server.
> 2. run $ docker compose-up trên terminal để tạo database. (Yêu cầu cài docker)
> 3. run $ swift build trên terminal để build package cho project.
> 4. run $ swift run trên terminal để run server trên localhost với port 8080.

> - Yêu cầu khi tham gia làm bài tập nhóm: 
> - Thành viên nhớ gửi yêu cầu chỉnh sửa link git khi muốn push code để phân quyền hoặc gửi tài khoản mail đăng kí tài khoản github để được phân quyền.
> - Commit code hàng ngày lên link git của project này.
> - Tài khoản commit sử dụng mail cá nhân, có tên của mình.
> - Không đợi đến gần khi bảo vệ mới push hết code lên git.
> - Pull về trước khi code.
> - Phần app code dễ hiểu và dễ xây dựng hơn phần server, tham khảo https://developer.apple.com/documentation/uikit và đọc tài liệu hướng dẫn. (Nên xây dựng app trước, phần server hiện đã có api đăng kí đăng nhập, load tin nhắn, nhắn tin, kết bạn,..).
> update: phần server hiện tại đã hoàn thiện, mọi người chạy thử server và call thử api và ghép vào code.
> - Trong mỗi project app và server đều có file README.md, hướng dẫn build, và có tài liệu tham khảo.

Tài liệu tham khảo:
https://developer.apple.com/documentation/uikit/view_controllers
Swift package manager: https://swift.org/package-manager/
Swift UI framework - UIKit: https://developer.apple.com/documentation/uikit

Liên hệ:
> Đạt - vuwit16b: 0899081299 - vudat081299@gmail.com

